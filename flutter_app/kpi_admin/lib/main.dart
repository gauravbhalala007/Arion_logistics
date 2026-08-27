import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_options.dart';
import 'widgets/auth_gate.dart';
import 'Screens/login_page.dart';
import 'Screens/signup_page.dart';
import 'Screens/verify_email_page.dart';
import 'Screens/driver_dashboard_page.dart';
import 'Screens/admin_shell_page.dart';
import 'Screens/admin_inventory_detail_page.dart';
import 'Screens/recruiting_agency_form_page.dart';
import 'Screens/recruiting_form_page.dart';
import 'Screens/public_review_page.dart';
import 'Screens/dispatcher_review_page.dart';
import 'Screens/public_plan_page.dart';
import 'Screens/owner_insights_page.dart';
import 'services/recruiting_slug_service.dart';
import 'models/recruiting_application.dart';
import 'widgets/app_side_menu.dart'; // for AppNav

import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization/app_localizations.dart';
import 'theme/app_theme.dart';

/// Use emulators only in debug/profile, never in release.
bool get useEmulators => !kReleaseMode;

/// Global Storage instance bound to the bucket from firebase_options.dart.
late final FirebaseStorage storage;

Future<void> _connectToEmulators() async {
  FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  await storage.useStorageEmulator('127.0.0.1', 9199);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  // TEMP logs
  // ignore: avoid_print
  // print('🔧 projectId: ${Firebase.app().options.projectId}');
  // ignore: avoid_print
  // print(
  //   '🔧 storageBucket (from options): ${DefaultFirebaseOptions.currentPlatform.storageBucket}',
  // );

  final bucket = DefaultFirebaseOptions.currentPlatform.storageBucket!;
  storage = FirebaseStorage.instanceFor(bucket: 'gs://$bucket');

  // ignore: avoid_print
  // print('🔧 storage.bucket runtime: ${storage.bucket}');

  // if (useEmulators) {
  //   await _connectToEmulators();
  // }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  Widget _wrapSelectable(Widget child) => SelectionArea(child: child);

  @override
  Widget build(BuildContext context) {
    // 🔑 AnimatedBuilder listens to the global localeController.
    // Whenever localeController.setLocale(...) is called,
    // MaterialApp is rebuilt with the new locale → entire app language updates.
    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'DSP CODRIVER',
          debugShowCheckedModeBanner: false,
          // 🌍 Current app locale (null = use system locale)
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(),

          home: _wrapSelectable(const AuthGate()),
          onGenerateRoute: (settings) {
            if (settings.name == '/inventory/item') {
              final id = (settings.arguments ?? '').toString();
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => _wrapSelectable(
                  AdminInventoryDetailPage(itemId: id),
                ),
              );
            }
            // Public recruiting form.
            //   /jobs/<slug>             → local channel (current path)
            //   /jobs/<slug>/visa        → visa channel
            //   /apply/<slug>[…]         → legacy alias (still works)
            //   /apply?dsp=<uid>&type=…  → legacy long-UID fallback
            // No auth wrapper — anyone with the link can fill it. Each
            // rename of the public path forces any stale browser cache
            // to fetch a fresh JS bundle from index.html → the working
            // version that hits the right Storage bucket.
            final name = settings.name ?? '';
            // Public, link-only review page (Sterne + Text). No auth.
            //   /bewertung  ·  /review
            final namePath = Uri.parse(name).path;
            // Monatliche Fahrerbewertung durch Dispatcher (Link + Token)
            //   /fahrerbewertung?t=<token>
            if (namePath == '/fahrerbewertung' ||
                namePath == '/driver-review') {
              final token = Uri.parse(name).queryParameters['t'] ?? '';
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => DispatcherReviewPage(token: token),
              );
            }
            if (namePath == '/bewertung' || namePath == '/review') {
              // Mit Token ist es eine Fahrerbewertung, ohne Token die
              // oeffentliche Sterne-Seite der Landingpage. So bleiben
              // bereits verschickte /review?t=…-Links gueltig.
              final token = Uri.parse(name).queryParameters['t'] ?? '';
              if (token.trim().isNotEmpty) {
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => DispatcherReviewPage(token: token),
                );
              }
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => _wrapSelectable(const PublicReviewPage()),
              );
            }
            // Private, password-gated owner usage dashboard. Unlisted route;
            // the callable it uses is additionally locked to owner UIDs.
            //   /insights
            if (namePath == '/insights') {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => _wrapSelectable(const OwnerInsightsPage()),
              );
            }
            // Public, link-only plan viewer (wave/shift plan). No auth —
            // the share ID is unguessable and the doc is world-readable.
            //   /plan/<shareId>
            // IMPORTANT: also match the bare '/plan' segment — Flutter
            // resolves deep initial routes segment by segment ('/', '/plan',
            // '/plan/<id>'); if any segment fails the WHOLE deep link falls
            // back to '/' (login).
            if (namePath == '/plan' || namePath.startsWith('/plan/') ||
                namePath == '/p' || namePath.startsWith('/p/')) {
              // '/p/<id>' ist der SPA-Alias: /plan/** beantwortet seit den
              // Link-Vorschauen die Cloud Function planPreview (OG-Tags
              // fuer WhatsApp & Co.) und leitet Browser hierher weiter.
              final segs = Uri.parse(name).pathSegments;
              final shareId = segs.length >= 2 ? segs[1] : '';
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) =>
                    _wrapSelectable(PublicPlanPage(shareId: shareId)),
              );
            }
            final isJobs = name.startsWith('/jobs');
            final isApply = name.startsWith('/apply');
            if (isJobs || isApply) {
              final uri = Uri.parse(name);
              final segs = uri.pathSegments;
              // pathSegments for "/jobs/arion/visa" → ['jobs','arion','visa']
              final slug = segs.length >= 2 ? segs[1] : '';
              final pathType = segs.length >= 3 ? segs[2] : '';
              final queryType = uri.queryParameters['type'] ?? '';
              final typeRaw =
                  (pathType.isNotEmpty ? pathType : queryType).toLowerCase();
              final channel = typeRaw == 'visa'
                  ? RecruitingChannel.visa
                  : RecruitingChannel.local;
              // Staffing-agency form — same loader, different page. It
              // submits on the `visa` channel (the Firestore rule pins
              // the public create to local|visa) but is flagged via
              // customAnswers.viaAgency.
              final isAgency = typeRaw == 'agency';
              final legacyUid = uri.queryParameters['dsp'] ?? '';

              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => _wrapSelectable(
                  _RecruitingFormLoader(
                    slug: slug,
                    legacyAdminUid: legacyUid,
                    channel: channel,
                    isAgency: isAgency,
                  ),
                ),
              );
            }
            return null;
          },
          routes: {
            '/login': (_) => _wrapSelectable(const LoginPage()),
            '/signup': (_) => _wrapSelectable(const SignupPage()),
            '/verify-email': (_) => _wrapSelectable(const VerifyEmailPage()),
            '/profile': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.profile),
            ),

            // ✅ all side-menu destinations go through the shell
            '/home': (_) =>
                _wrapSelectable(const AdminShellPage(initialNav: AppNav.home)),
            '/dashboard': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.dashboard),
            ),
            '/pod-quality': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.podQuality),
            ),
            '/concessions': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.concessions),
            ),
            '/cdf': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.cdf),
            ),
            '/dwc': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.dwc),
            ),
            '/contact-compliance': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.contactCompliance),
            ),
            '/drivers': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.drivers),
            ),
            '/recruiting': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.recruiting),
            ),
            '/waveplan': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.waveplan),
            ),
            '/calendar': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.calendar),
            ),
            '/fleet-status': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.fleetStatus),
            ),
            '/tasks': (_) =>
                _wrapSelectable(const AdminShellPage(initialNav: AppNav.tasks)),
            '/shift-absence': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.shiftAbsence),
            ),
            '/da-requests': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.daRequests),
            ),
            '/safety-training': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.safetyTraining),
            ),
            '/incident-reports': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.incidentReports),
            ),
            '/vehicle-check': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.vehicleCheck),
            ),
            '/contacts': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.contacts),
            ),
            '/academy': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.academy),
            ),
            '/dispatcher-pill': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.dispatcherPill),
            ),
            '/notifications': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.notifications),
            ),
            '/app-updates': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.appUpdates),
            ),
            '/feedback': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.feedback),
            ),
            '/faqs': (_) =>
                _wrapSelectable(const AdminShellPage(initialNav: AppNav.faqs)),
            '/admin-approvals': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.adminApprovals),
            ),
            '/inventory': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.inventory),
            ),
            '/cart': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.cart),
            ),
            '/shift-plan': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.shiftPlan),
            ),
            '/payment-check': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.paymentCheck),
            ),
            '/monthly-plan': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.monthlyPlan),
            ),

            '/coming-soon': (_) =>
                _wrapSelectable(const _PlaceholderPage(title: 'Coming Soon')),
          },
        );
      },
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Resolves a recruiting slug (e.g. "arion") to the long admin UID
/// before handing off to [RecruitingFormPage]. Falls back to the
/// legacy `?dsp=<uid>` query if no slug is given.
class _RecruitingFormLoader extends StatefulWidget {
  final String slug;
  final String legacyAdminUid;
  final RecruitingChannel channel;

  /// `?type=agency` → render the staffing-agency form instead of the
  /// driver application form.
  final bool isAgency;

  const _RecruitingFormLoader({
    required this.slug,
    required this.legacyAdminUid,
    required this.channel,
    this.isAgency = false,
  });

  @override
  State<_RecruitingFormLoader> createState() => _RecruitingFormLoaderState();
}

class _RecruitingFormLoaderState extends State<_RecruitingFormLoader> {
  String? _resolvedUid;
  bool _loading = true;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    // 1) Legacy long-UID URL — use directly, no Firestore round-trip.
    if (widget.slug.isEmpty && widget.legacyAdminUid.isNotEmpty) {
      setState(() {
        _resolvedUid = widget.legacyAdminUid;
        _loading = false;
      });
      return;
    }
    // 2) Slug path — look up in recruiting_slugs collection.
    if (widget.slug.isNotEmpty) {
      final uid = await RecruitingSlugService.resolveAdminUid(widget.slug);
      if (!mounted) return;
      setState(() {
        _resolvedUid = uid;
        _notFound = uid == null;
        _loading = false;
      });
      return;
    }
    setState(() {
      _notFound = true;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_notFound || _resolvedUid == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Invalid application link.\n\n'
              'Please ask your contact at the company for the correct URL.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
        ),
      );
    }
    if (widget.isAgency) {
      return RecruitingAgencyFormPage(adminUid: _resolvedUid!);
    }
    return RecruitingFormPage(
      adminUid: _resolvedUid!,
      channel: widget.channel,
    );
  }
}
