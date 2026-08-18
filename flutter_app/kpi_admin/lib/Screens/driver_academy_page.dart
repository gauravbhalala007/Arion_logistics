import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/privacy_camera/privacy_camera_content.dart';
import '../data/privacy_camera/privacy_camera_repository.dart';
import '../data/privacy_camera/privacy_camera_texts.dart';
import '../data/safety_training/academy_texts.dart';
import '../data/safety_training/operating_instructions.dart';
import '../data/safety_training/privacy_data.dart';
import '../data/safety_training/safety_training_data.dart';
import 'driver_driving_safety_page.dart';
import 'driver_green_book_page.dart';
import 'driver_green_book_training_page.dart';
import 'driver_operating_instructions_page.dart';
import 'driver_privacy_camera_course_page.dart';
import 'driver_privacy_center_page.dart';
import 'driver_privacy_training_page.dart';
import 'driver_ride_along_page.dart';
import 'driver_safety_training_page.dart';

/// Vorwarnzeit: so viele Tage vor Ablauf gilt eine Schulung als
/// „bald fällig" (gelbe Statuszeile statt grüner).
const int kAcademyDueSoonDays = 30;

class DriverAcademyPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverAcademyPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverAcademyPage> createState() => _DriverAcademyPageState();
}

class _DriverAcademyPageState extends State<DriverAcademyPage> {
  /// Alle Ergebnis-Dokumente, die für die Statuszeilen gebraucht werden.
  ///
  /// Bewusst EIN gebündelter Ladevorgang (`Future.wait`) statt eines
  /// Streams je Kachel: die Dokumente ändern sich nur, wenn der Fahrer
  /// selbst eine Schulung abschließt — dann wird nach der Rückkehr aus
  /// der Schulungsseite neu geladen (siehe [_open]).
  static const List<String> _statusTestIds = <String>[
    kGreenBookTestId,
    kRideAlongTestId,
    kSafetyTrainingTestId,
    kPrivacyTestId,
    kDrivingSafetyTrainingId,
    kOperatingInstructionsTestId,
    kPrivacyCameraTestId,
  ];

  /// testId -> Ergebnisdokument. `null` = noch nicht geladen bzw. Ladefehler;
  /// dann bleiben die Statuszeilen aus, statt „Noch offen" zu behaupten.
  Map<String, Map<String, dynamic>>? _results;

  /// Kursinhalte des Kamera-Datenschutzmoduls — gebraucht wird daraus nur
  /// die Prüfsumme der aktuellen Fassung, um „neue Fassung" zu erkennen.
  /// Assets, daher nach dem ersten Laden im Prozess gecacht.
  PrivacyCourseBundle? _privacyCameraBundle;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  @override
  void didUpdateWidget(covariant DriverAcademyPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dspUid != widget.dspUid ||
        oldWidget.driverTransporterId != widget.driverTransporterId) {
      _loadStatuses();
    }
  }

  Future<void> _loadStatuses() async {
    final uid = widget.dspUid.trim();
    final tid = widget.driverTransporterId.trim();
    if (uid.isEmpty || tid.isEmpty) {
      if (mounted) setState(() => _results = const {});
      return;
    }
    final base = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('academy_test_results');
    try {
      // Verglichen wird gegen die deutsche (verbindliche) Fassung — ein
      // Sprachwechsel des Fahrers darf keine Wiedervorlage auslösen.
      _privacyCameraBundle ??= await PrivacyCourseBundle.load(
        kPrivacyBindingLanguage,
      );
    } catch (_) {
      // Ohne Inhalte keine Statuszeile für das Kameramodul.
    }
    try {
      final snaps = await Future.wait(
        _statusTestIds.map(
          (testId) => base.doc(testId).collection('drivers').doc(tid).get(),
        ),
      );
      final out = <String, Map<String, dynamic>>{};
      for (var i = 0; i < _statusTestIds.length; i++) {
        final data = snaps[i].data();
        if (data != null) out[_statusTestIds[i]] = data;
      }
      if (!mounted) return;
      setState(() => _results = out);
    } catch (_) {
      // Ohne Daten lieber gar keine Statuszeile als eine falsche.
    }
  }

  /// Öffnet eine Schulungsseite und aktualisiert danach die Statuszeilen.
  Future<void> _open(Widget Function(BuildContext) builder) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: builder));
    if (!mounted) return;
    await _loadStatuses();
  }

  // ── Statusermittlung ──────────────────────────────────────────────

  static DateTime? _toDate(Object? value) =>
      value is Timestamp ? value.toDate() : null;

  static String _fmt(DateTime at) => DateFormat('dd.MM.yyyy').format(at);

  /// Status einer Schulung mit Abschlusstest.
  ///
  /// [validity] / [validMonths] werden nur als Rückfallebene benutzt, wenn
  /// das Ergebnisdokument kein `validUntil` mitschreibt. Sind beide `null`,
  /// gilt die Schulung als Schulung ohne Ablauf.
  _StatusInfo? _testStatus(
    String locale,
    String testId, {
    Duration? validity,
    int? validMonths,
  }) {
    final results = _results;
    if (results == null) return null;

    final data = results[testId];
    final passedAt = _toDate(data?['passedAt']);
    if (passedAt == null) {
      return _StatusInfo.neutral(academyText(locale, 'status_open'));
    }

    var due = _toDate(data?['validUntil']);
    if (due == null && validity != null) due = passedAt.add(validity);
    if (due == null && validMonths != null) {
      due = DateTime(
        passedAt.year,
        passedAt.month + validMonths,
        passedAt.day,
        passedAt.hour,
        passedAt.minute,
      );
    }

    final done = _fmt(passedAt);
    if (due == null) {
      return _StatusInfo.ok(
        academyText(locale, 'status_done', vars: {'done': done}),
      );
    }

    final now = DateTime.now();
    final dueStr = _fmt(due);
    if (!due.isAfter(now)) {
      return _StatusInfo.alert(
        academyText(locale, 'status_expired', vars: {'due': dueStr}),
      );
    }
    if (due.difference(now).inDays <= kAcademyDueSoonDays) {
      return _StatusInfo.warn(
        academyText(
          locale,
          'status_due_soon',
          vars: {'done': done, 'due': dueStr},
        ),
      );
    }
    return _StatusInfo.ok(
      academyText(
        locale,
        'status_done_due',
        vars: {'done': done, 'due': dueStr},
      ),
    );
  }

  /// Betriebsanweisungen kennen keinen Test, sondern Lesebestätigungen —
  /// deshalb „x von y bestätigt" statt eines Fälligkeitsdatums.
  _StatusInfo? _opsStatus(String locale) {
    final results = _results;
    if (results == null) return null;

    final ids = operatingInstructionsFor(
      locale,
    ).map((i) => i.id).toSet();
    if (ids.isEmpty) return null;

    final raw = results[kOperatingInstructionsTestId]?['acknowledged'];
    final acknowledged = raw is Map ? raw : const {};
    final done = ids.where((id) => acknowledged[id] != null).length;

    if (done >= ids.length) {
      return _StatusInfo.ok(academyText(locale, 'status_ack_all'));
    }
    final label = academyText(
      locale,
      'status_ack_progress',
      vars: {'n': '$done', 'total': '${ids.length}'},
    );
    return done == 0 ? _StatusInfo.neutral(label) : _StatusInfo.warn(label);
  }

  /// Kameras im Fahrzeug — Kenntnisnahme statt Test.
  ///
  /// Wiedervorlage NUR bei geänderter Fassung/Prüfsumme, bewusst ohne
  /// Jahresfrist. Eine Verweigerung („declined") ist ein gültiger
  /// Nachweis der Aushändigung und deshalb NEUTRAL, nicht rot — sie ist
  /// kein Fehlerfall.
  _StatusInfo? _privacyCameraStatus(String locale) {
    final results = _results;
    final bundle = _privacyCameraBundle;
    if (results == null || bundle == null) return null;

    final data = results[kPrivacyCameraTestId];
    if (data == null || data['outcome'] == null) {
      return _StatusInfo.neutral(
        privacyCameraText(locale, 'status_open'),
      );
    }

    final ack = PrivacyCameraAck.fromMap(data);
    if (!ack.matchesDocument(bundle.primaryDocument)) {
      return _StatusInfo.warn(privacyCameraText(locale, 'status_update'));
    }
    final date = _fmt(ack.occurredAt);
    if (ack.isAcknowledged) {
      return _StatusInfo.ok(
        privacyCameraText(locale, 'status_ack', vars: {'date': date}),
      );
    }
    return _StatusInfo.neutral(
      privacyCameraText(locale, 'status_declined', vars: {'date': date}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid.trim())
          .collection('academy_tests')
          .orderBy('order')
          .snapshots(),
      builder: (context, snap) {
        final locale = Localizations.localeOf(
          context,
        ).languageCode.toLowerCase();
        final docs = snap.data?.docs ?? const [];
        final categories =
            docs
                .map((doc) => _AcademyCategory.fromDoc(doc))
                .where((c) => c.enabled)
                .toList()
              ..sort((a, b) {
                if (a.order != b.order) return a.order.compareTo(b.order);
                return a
                    .titleFor(locale)
                    .toLowerCase()
                    .compareTo(b.titleFor(locale).toLowerCase());
              });
        final visibleCategories = categories
            .where((c) => c.id.trim().toLowerCase() != 'green_book')
            .toList(growable: false);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: widget.onBack,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    academyText(locale, 'page_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (snap.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AcademyTile(
                      title: academyText(locale, 'green_book_title'),
                      subtitle: academyText(locale, 'green_book_subtitle'),
                      icon: Icons.menu_book_rounded,
                      iconColor: const Color(0xFF22AF66),
                      iconBg: const Color(0xFFE9F7EF),
                      // Green Book: nur `passedAt`, keine Gültigkeitsdauer
                      // im Code hinterlegt → Schulung ohne Ablauf.
                      status: _testStatus(locale, kGreenBookTestId),
                      onTap: () => _open(
                        (_) => DriverGreenBookPage(
                          dspUid: widget.dspUid,
                          driverTransporterId: widget.driverTransporterId,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  // Ride Along — Vorbereitung auf die zweitägige
                  // Begleitfahrt mit einem Trainer, mit Abschlusstest.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AcademyTile(
                      title: academyText(locale, 'ride_along_title'),
                      subtitle: academyText(locale, 'ride_along_subtitle'),
                      icon: Icons.supervisor_account_rounded,
                      iconColor: const Color(0xFF2A5FB0),
                      iconBg: const Color(0xFFEAF1FB),
                      // Ride Along: nur `passedAt`, keine Gültigkeitsdauer
                      // im Code hinterlegt → Schulung ohne Ablauf.
                      status: _testStatus(locale, kRideAlongTestId),
                      onTap: () => _open(
                        (_) => DriverRideAlongPage(
                          dspUid: widget.dspUid,
                          driverTransporterId: widget.driverTransporterId,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  // Sicherheitsunterweisung — jährliche Arbeitsschutz-
                  // Unterweisung mit Test + Nachweis-PDF.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AcademyTile(
                      title: safetyText(locale, 'training_title'),
                      subtitle: safetyText(locale, 'training_subtitle'),
                      icon: Icons.health_and_safety_rounded,
                      iconColor: const Color(0xFF1D7F5A),
                      iconBg: const Color(0xFFE4F5EC),
                      status: _testStatus(
                        locale,
                        kSafetyTrainingTestId,
                        validity: kSafetyTrainingValidity,
                      ),
                      onTap: () => _open(
                        (_) => DriverSafetyTrainingPage(
                          dspUid: widget.dspUid,
                          driverTransporterId: widget.driverTransporterId,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  // Datenschutz — DSGVO-Grundschulung mit Abschlusstest
                  // und Unterschrift, jährlich zu wiederholen.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AcademyTile(
                      title: academyText(locale, 'privacy_title'),
                      subtitle: academyText(locale, 'privacy_subtitle'),
                      icon: Icons.privacy_tip_rounded,
                      iconColor: const Color(0xFF5C4B99),
                      iconBg: const Color(0xFFEFECF9),
                      status: _testStatus(
                        locale,
                        kPrivacyTestId,
                        validity: kPrivacyValidity,
                      ),
                      onTap: () => _open(
                        (_) => DriverPrivacyTrainingPage(
                          dspUid: widget.dspUid,
                          driverTransporterId: widget.driverTransporterId,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  // Kameras im Fahrzeug – Datenschutz. Kenntnisnahme der
                  // Datenschutzerklärung zur Verkehrssicherheits-
                  // technologie — KEINE Einwilligung, kein App-Gate.
                  //
                  // Solange [kPrivacyCameraDriverEnabled] false ist, sind
                  // beide Kacheln wie die übrigen noch nicht
                  // freigeschalteten Trainings als „Kommt bald" gesperrt.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AcademyTile(
                      title: privacyCameraText(locale, 'tile_title'),
                      subtitle: privacyCameraText(locale, 'tile_subtitle'),
                      icon: Icons.photo_camera_outlined,
                      iconColor: const Color(0xFF2A5FB0),
                      iconBg: const Color(0xFFEAF1FB),
                      disabled: !kPrivacyCameraDriverEnabled,
                      badge: kPrivacyCameraDriverEnabled
                          ? null
                          : academyText(locale, 'badge_coming_soon'),
                      status: kPrivacyCameraDriverEnabled
                          ? _privacyCameraStatus(locale)
                          : null,
                      onTap: !kPrivacyCameraDriverEnabled
                          ? null
                          : () => _open(
                              (ctx) => DriverPrivacyCameraCoursePage(
                                dspUid: widget.dspUid,
                                driverTransporterId:
                                    widget.driverTransporterId,
                                onBack: () => Navigator.of(ctx).pop(),
                              ),
                            ),
                    ),
                  ),
                  // Dauerhafter Datenschutz-Bereich: Volltexte und
                  // Kontakt — zwei Taps vom Fahrer-Home.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AcademyTile(
                      title: privacyCameraText(locale, 'center_tile_title'),
                      subtitle: privacyCameraText(
                        locale,
                        'center_tile_subtitle',
                      ),
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF3B5A80),
                      iconBg: const Color(0xFFEFF4FA),
                      disabled: !kPrivacyCameraDriverEnabled,
                      badge: kPrivacyCameraDriverEnabled
                          ? null
                          : academyText(locale, 'badge_coming_soon'),
                      onTap: !kPrivacyCameraDriverEnabled
                          ? null
                          : () => _open(
                              (ctx) => DriverPrivacyCenterPage(
                                dspUid: widget.dspUid,
                                driverTransporterId:
                                    widget.driverTransporterId,
                                onBack: () => Navigator.of(ctx).pop(),
                              ),
                            ),
                    ),
                  ),
                  // Fahrsicherheitstraining — eigenständige Schulung mit
                  // Modul-Quiz, Abschlusstest und Zertifikat.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AcademyTile(
                      title: academyText(locale, 'driving_title'),
                      subtitle: academyText(locale, 'driving_subtitle'),
                      icon: Icons.drive_eta_rounded,
                      iconColor: const Color(0xFF1D7F5A),
                      iconBg: const Color(0xFFE4F5EC),
                      status: _testStatus(
                        locale,
                        kDrivingSafetyTrainingId,
                        validMonths: kDrivingCertificateMonths,
                      ),
                      onTap: () => _open(
                        (_) => DriverDrivingSafetyPage(
                          dspUid: widget.dspUid,
                          driverTransporterId: widget.driverTransporterId,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  // Betriebsanweisungen — Sammelordner aller BAWs,
                  // zusätzlich aus den Schulungskapiteln verlinkt.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AcademyTile(
                      title: academyText(locale, 'ops_title'),
                      subtitle: academyText(locale, 'ops_subtitle'),
                      icon: Icons.menu_book_outlined,
                      iconColor: const Color(0xFF3B5A80),
                      iconBg: const Color(0xFFEFF4FA),
                      status: _opsStatus(locale),
                      onTap: () => _open(
                        (_) => DriverOperatingInstructionsPage(
                          dspUid: widget.dspUid,
                          driverTransporterId: widget.driverTransporterId,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  // FAQ Training — quiz built on top of the existing
                  // FAQ entries (`users/{dspUid}/faqs`). Sits next to
                  // the Green Book at the top of the academy list.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AcademyTile(
                      title: academyText(locale, 'faq_title'),
                      subtitle: academyText(locale, 'faq_subtitle'),
                      icon: Icons.fact_check_rounded,
                      iconColor: const Color(0xFFFF8A1F),
                      iconBg: const Color(0xFFFFF0E4),
                      disabled: true,
                      badge: academyText(locale, 'badge_coming_soon'),
                      onTap: null,
                    ),
                  ),
                  ...visibleCategories.map((category) {
                  final title = category.titleFor(locale);
                  final subtitle = category.subtitleFor(locale);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AcademyTile(
                      title: title,
                      subtitle: subtitle,
                      icon: _iconForCategory(category.id),
                      iconColor: const Color(0xFF3E82F7),
                      iconBg: const Color(0xFFE9F1FE),
                      disabled: true,
                      badge: academyText(locale, 'badge_coming_soon'),
                      onTap: null,
                    ),
                  );
                  }),
                  if (visibleCategories.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFDDE3E7),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        academyText(locale, 'empty_categories'),
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
            ],
          ),
        );
      },
    );
  }

  IconData _iconForCategory(String categoryId) {
    final id = categoryId.trim().toLowerCase();
    if (id.contains('green')) return Icons.menu_book_rounded;
    if (id.contains('safety')) return Icons.shield_outlined;
    if (id.contains('delivery') || id.contains('amazon')) {
      return Icons.local_shipping_outlined;
    }
    if (id.contains('app')) return Icons.phone_android_rounded;
    return Icons.school_outlined;
  }
}

/// Fertig formatierte Statuszeile einer Kachel (Text + Farbwelt + Icon).
@immutable
class _StatusInfo {
  final String label;
  final Color fg;
  final Color bg;
  final IconData icon;

  const _StatusInfo({
    required this.label,
    required this.fg,
    required this.bg,
    required this.icon,
  });

  /// Noch offen — bewusst zurückhaltend, kein Alarm.
  factory _StatusInfo.neutral(String label) => _StatusInfo(
    label: label,
    fg: const Color(0xFF6B7280),
    bg: const Color(0xFFF1F3F5),
    icon: Icons.radio_button_unchecked_rounded,
  );

  /// Erledigt und gültig.
  factory _StatusInfo.ok(String label) => _StatusInfo(
    label: label,
    fg: const Color(0xFF16704F),
    bg: const Color(0xFFE4F5EC),
    icon: Icons.check_circle_rounded,
  );

  /// Läuft demnächst ab bzw. noch nicht vollständig bestätigt.
  factory _StatusInfo.warn(String label) => _StatusInfo(
    label: label,
    fg: const Color(0xFF9A5B00),
    bg: const Color(0xFFFFF3E0),
    icon: Icons.schedule_rounded,
  );

  /// Abgelaufen.
  factory _StatusInfo.alert(String label) => _StatusInfo(
    label: label,
    fg: const Color(0xFFB3261E),
    bg: const Color(0xFFFDECEA),
    icon: Icons.error_outline_rounded,
  );
}

class _AcademyCategory {
  final String id;
  final int order;
  final bool enabled;
  final Map<String, String> titleByLocale;
  final Map<String, String> subtitleByLocale;

  const _AcademyCategory({
    required this.id,
    required this.order,
    required this.enabled,
    required this.titleByLocale,
    required this.subtitleByLocale,
  });

  factory _AcademyCategory.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return _AcademyCategory(
      id: doc.id,
      order: (data['order'] as num?)?.toInt() ?? 0,
      enabled: data['enabled'] != false,
      titleByLocale: _collectLocalized(data, 'title'),
      subtitleByLocale: _collectLocalized(data, 'subtitle'),
    );
  }

  String titleFor(String locale) {
    final code = locale.trim().toLowerCase();
    final direct = (titleByLocale[code] ?? '').trim();
    if (direct.isNotEmpty) return direct;
    final en = (titleByLocale['en'] ?? '').trim();
    if (en.isNotEmpty) return en;
    return id;
  }

  String subtitleFor(String locale) {
    final code = locale.trim().toLowerCase();
    final direct = (subtitleByLocale[code] ?? '').trim();
    if (direct.isNotEmpty) return direct;
    final en = (subtitleByLocale['en'] ?? '').trim();
    if (en.isNotEmpty) return en;
    return '';
  }

  static Map<String, String> _collectLocalized(
    Map<String, dynamic> data,
    String prefix,
  ) {
    final out = <String, String>{};
    for (final entry in data.entries) {
      if (!entry.key.startsWith('${prefix}_')) continue;
      final code = entry.key.substring(prefix.length + 1).trim().toLowerCase();
      if (code.isEmpty) continue;
      final value = (entry.value ?? '').toString().trim();
      if (value.isNotEmpty) out[code] = value;
    }
    final plain = (data[prefix] ?? '').toString().trim();
    if (plain.isNotEmpty && !out.containsKey('en')) {
      out['en'] = plain;
    }
    return out;
  }
}

class _AcademyTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback? onTap;
  final bool disabled;
  final String? badge;

  /// Erledigt-/Fälligkeitszeile unter dem Untertitel. `null` = keine Zeile
  /// (noch nicht geladen oder Kachel ohne Nachweis).
  final _StatusInfo? status;

  const _AcademyTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
    this.disabled = false,
    this.badge,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final st = status;
    final tile = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: disabled ? null : onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDDE3E7), width: 1.4),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8699),
                        ),
                      ),
                    ],
                    if (st != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: st.bg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(st.icon, size: 13, color: st.fg),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  st.label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    height: 1.25,
                                    fontWeight: FontWeight.w700,
                                    color: st.fg,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (disabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 13,
                        color: Color(0xFF7A8699),
                      ),
                      if ((badge ?? '').trim().isNotEmpty) ...[
                        const SizedBox(width: 5),
                        Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7A8699),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF7A8699),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
    return disabled ? Opacity(opacity: 0.62, child: tile) : tile;
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDDE3E7), width: 1),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1F2937)),
        ),
      ),
    );
  }
}
