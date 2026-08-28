import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/incident_attachments.dart';
import '../services/incident_reports.dart';
import '../services/incident_share_service.dart';
import '../services/vehicle_check_service.dart' show kVehicleCheckKind;
import '../widgets/admin_scope.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';
import '../widgets/incident_photo_gallery.dart';
import '../widgets/mobile_filter_controls.dart';
import '../widgets/pill_tab_bar.dart';
import 'admin_incident_form_page.dart';
import 'incident_faq_dialog.dart';

/// Ab hier greift die aufgeräumte Mobile-Fassung (gleiche Schwelle wie im
/// Fleet Hub): kompakte Titelzeile mit Erfassen-Button, keine Sektions-
/// Überschriften, Suchfeld + Filter-Icon statt gestapelter Dropdowns.
const double kIncidentMobileBreakpoint = 700;

/// Öffnet das Erfassungs-/Bearbeitungsformular und bestätigt den Erfolg.
/// Wird sowohl von der Mobile-Titelzeile als auch aus den Listen-Tabs
/// benutzt, damit es nur einen Weg in das Formular gibt.
Future<void> openIncidentForm(
  BuildContext context, {
  required String dspUid,
  required String category,
  String? docId,
  Map<String, dynamic>? initialData,
}) async {
  if (dspUid.isEmpty) return;
  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AdminIncidentFormPage(
      dspUid: dspUid,
      category: category,
      docId: docId,
      initialData: initialData,
    ),
  );
  if (saved != true || !context.mounted) return;
  final de = Localizations.localeOf(context).languageCode == 'de';
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        docId == null
            ? (de ? 'Vorfall gespeichert.' : 'Incident saved.')
            : (de ? 'Änderungen gespeichert.' : 'Changes saved.'),
      ),
    ),
  );
}

/// Incident-Center des Admins.
///
/// Zwei klar getrennte Bereiche:
///   • **Unfälle & Schäden (Fahrzeug)** — alles am Fahrzeug.
///   • **Arbeitsunfälle (Person)** — Personenschaden am Arbeitsplatz,
///     BG-relevant; ausdrücklich *nicht* dasselbe wie ein Fahrzeug-Unfall.
///
/// Ablauf: Vorfall zuerst hier erfassen, danach den fertigen Bericht per
/// Kopier-Button in die WhatsApp-Gruppe einfügen.
class AdminIncidentReportsPage extends StatefulWidget {
  const AdminIncidentReportsPage({super.key, this.initialPlate});

  /// Vorbelegter Fahrzeug-Filter. Wird gesetzt, wenn die Seite aus der
  /// Fahrzeug-Detailseite heraus geoeffnet wird ("Schäden"-Kachel) —
  /// dann zeigt die Liste nur die Vorfaelle dieses Fahrzeugs statt der
  /// ganzen Flotte. Der Filter laesst sich in der Liste loeschen.
  final String? initialPlate;

  @override
  State<AdminIncidentReportsPage> createState() =>
      _AdminIncidentReportsPageState();
}

class _AdminIncidentReportsPageState extends State<AdminIncidentReportsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  String? _resolvedDspUid;
  bool _resolving = true;

  String? get _authUid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  String? get _scopeUid {
    final uid = _authUid;
    if (uid == null) return null;
    final scoped = (_resolvedDspUid ?? '').trim();
    return scoped.isEmpty ? uid : scoped;
  }

  @override
  void initState() {
    super.initState();
    // Der Erfassen-Button der Mobile-Titelzeile hängt am aktiven Tab —
    // ohne Listener behielte er Label und Kategorie des ersten Tabs.
    _tabs.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveScope());
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _resolveScope() async {
    final uid = _authUid;
    if (uid == null) {
      if (mounted) setState(() => _resolving = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final dspUid = (snap.data()?['dspUid'] ?? '').toString().trim();
      if (!mounted) return;
      setState(() {
        _resolvedDspUid = dspUid.isEmpty ? uid : dspUid;
        _resolving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resolvedDspUid = uid;
        _resolving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';

    if (_authUid == null) {
      return Center(
        child: Text(
          de
              ? 'Melde dich als Admin an, um Vorfälle zu sehen.'
              : 'Sign in as an admin to see incidents.',
          style: const TextStyle(color: kIncidentMuted),
        ),
      );
    }

    return CoStateSwitcher(
      child: _resolving
          ? const Center(
              key: ValueKey('resolving'),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(kIncidentFocus),
              ),
            )
          : _buildLoaded(de),
    );
  }

  Widget _buildLoaded(bool de) {
    final scope = _scopeUid ?? '';
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < kIncidentMobileBreakpoint;
        return Padding(
          key: const ValueKey('loaded'),
          padding: isMobile
              ? const EdgeInsets.fromLTRB(12, 16, 12, 0)
              : const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFC2410C),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      de ? 'Vorfälle' : 'Incidents',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: kIncidentText,
                      ),
                    ),
                  ),
                  // Leitfaden für den Unfall-Anruf. Steht bewusst vor dem
                  // Erfassen-Button: gefragt wird zuerst, erfasst danach.
                  const SizedBox(width: 8),
                  IncidentFaqButton(compact: isMobile),
                  // Mobil sitzt die Erfassen-Aktion kompakt in der Titelzeile;
                  // der vollbreite Button in der Sektions-Kopfzeile entfällt
                  // dort (siehe `_IncidentListTabState._header`).
                  if (isMobile && _tabs.index != 2) ...[
                    const SizedBox(width: 8),
                    _MobileCreateButton(
                      label: _tabs.index == 1
                          ? (de ? 'Arbeitsunfall' : 'Work accident')
                          : (de ? 'Vorfall' : 'Incident'),
                      tooltip: _tabs.index == 1
                          ? (de
                                ? 'Arbeitsunfall erfassen'
                                : 'Log work accident')
                          : (de ? 'Vorfall erfassen' : 'Log incident'),
                      onTap: () => openIncidentForm(
                        context,
                        dspUid: scope,
                        category: _tabs.index == 1
                            ? kIncidentWorkAccident
                            : kIncidentVehicle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              PillTabBar(
                controller: _tabs,
                isScrollable: true,
                tabs: [
                  de ? 'Unfälle & Schäden' : 'Accidents & damage',
                  de ? 'Arbeitsunfälle' : 'Work accidents',
                  de ? 'Einstellungen' : 'Settings',
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _IncidentListTab(
                      key: const ValueKey('vehicle'),
                      dspUid: scope,
                      category: kIncidentVehicle,
                      initialPlate: widget.initialPlate,
                    ),
                    _IncidentListTab(
                      key: const ValueKey('work_accident'),
                      dspUid: scope,
                      category: kIncidentWorkAccident,
                    ),
                    _IncidentSettingsTab(dspUid: scope),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Kompakter grüner „+ Vorfall"-Button der Mobile-Titelzeile (44 px hoch).
class _MobileCreateButton extends StatelessWidget {
  const _MobileCreateButton({
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: kMobileAccent,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 44,
            constraints: const BoxConstraints(maxWidth: 172),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// Liste je Bereich
// ═════════════════════════════════════════════════════════════════════════

/// Deckel für die Live-Liste. Wird er erreicht, weist `_TruncationNotice`
/// darauf hin, dass ältere Vorfälle fehlen.
const int _kListLimit = 800;

class _IncidentListTab extends StatefulWidget {
  const _IncidentListTab({
    super.key,
    required this.dspUid,
    required this.category,
    this.initialPlate,
  });

  final String dspUid;
  final String category;

  /// Siehe [AdminIncidentReportsPage.initialPlate].
  final String? initialPlate;

  @override
  State<_IncidentListTab> createState() => _IncidentListTabState();
}

class _IncidentListTabState extends State<_IncidentListTab> {
  final _searchCtrl = TextEditingController();

  /// Eigener Controller: `primary: false` löst die Liste vom
  /// PrimaryScrollController — sonst fänden im Zwei-Spalten-Layout beide
  /// Listen denselben Controller, und die Scrollbar hinge an nichts.
  final _listScrollCtrl = ScrollController();
  String _query = '';
  String _typeFilter = 'all';
  String _responsibilityFilter = 'all';
  int? _yearFilter;

  /// Statistik-Panel: 'driver' | 'plate'. Im Arbeitsunfall-Tab immer
  /// 'driver' — dort gibt es keine Fahrzeug-Dimension.
  String _statsMode = 'driver';

  /// Aus der Statistik angeklickter Fahrer bzw. Fahrzeug. Filtert die
  /// rechte Liste, wirkt aber bewusst **nicht** auf die Statistik selbst.
  _StatFocus? _focus;

  /// Nur im gestapelten Layout relevant: Statistik startet zugeklappt,
  /// damit die Vorfallsliste oben steht.
  bool _statsExpanded = false;

  bool get _isWorkAccident => widget.category == kIncidentWorkAccident;

  @override
  void initState() {
    super.initState();
    // Aus der Fahrzeug-Detailseite geoeffnet: sofort auf dieses Fahrzeug
    // filtern. Dafuer gibt es den Fokus-Mechanismus schon — bisher wurde
    // er nur durch einen Klick in der Statistik gesetzt, weshalb die
    // Liste trotz Titel "Vorfaelle · KENNZEICHEN" die ganze Flotte zeigte.
    final plate = (widget.initialPlate ?? '').trim();
    if (plate.isNotEmpty && !_isWorkAccident) {
      _focus = _StatFocus(
        kind: 'plate',
        key: plateKeyOf(plate),
        label: plate.toUpperCase(),
      );
      // Damit der Nutzer die Fahrzeug-Verteilung neben der Liste sieht.
      _statsMode = 'plate';
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _listScrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _openForm({String? docId, Map<String, dynamic>? initialData}) {
    return openIncidentForm(
      context,
      dspUid: widget.dspUid,
      category: widget.category,
      docId: docId,
      initialData: initialData,
    );
  }

  /// Dropdown-Filter und Suche. Die Statistik rechnet **nur** hiermit —
  /// der Klickfilter bleibt außen vor, sonst bliebe nach dem ersten Klick
  /// genau ein Eintrag stehen und das Panel wäre als Navigation tot.
  bool _matchesBaseFilters(Map<String, dynamic> data) {
    if (incidentCategoryOf(data) != widget.category) return false;

    if (!_isWorkAccident) {
      if (_typeFilter != 'all' && incidentTypeOf(data) != _typeFilter) {
        return false;
      }
      if (_responsibilityFilter != 'all' &&
          incidentResponsibilityOf(data) != _responsibilityFilter) {
        return false;
      }
    }

    if (_yearFilter != null) {
      final occurredAt = incidentOccurredAt(data);
      if (occurredAt == null || occurredAt.year != _yearFilter) return false;
    }

    if (_query.isEmpty) return true;
    final haystack = <String>[
      incidentDriverName(data),
      incidentDriverTid(data),
      incidentPlate(data),
      incidentAddress(data),
      incidentDescription(data),
      (data['damage'] ?? '').toString(),
      (data['notes'] ?? '').toString(),
      incidentInjuryType(data),
      incidentBodyPart(data),
      incidentActivityAtTime(data),
      incidentWitnesses(data),
      incidentDoctorText(data),
      (data['damageType'] ?? '').toString(),
      incidentDamageTypeLabel(data, de: true),
      incidentDamageTypeLabel(data, de: false),
    ].join(' ').toLowerCase();
    return haystack.contains(_query);
  }

  /// Zusätzlicher Klickfilter aus der Statistik.
  bool _matchesFocus(Map<String, dynamic> data) {
    final focus = _focus;
    if (focus == null) return true;
    return focus.kind == 'plate'
        ? incidentPlateGroupKey(data) == focus.key
        : incidentDriverGroupKey(data) == focus.key;
  }

  void _toggleFocus(_StatFocus candidate) {
    setState(() {
      final current = _focus;
      final same =
          current != null &&
          current.kind == candidate.kind &&
          current.key == candidate.key;
      _focus = same ? null : candidate;
    });
  }

  void _resetFilters() {
    setState(() {
      _searchCtrl.clear();
      _query = '';
      _typeFilter = 'all';
      _responsibilityFilter = 'all';
      _yearFilter = null;
      _focus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';

    if (widget.dspUid.isEmpty) {
      return _EmptyState(
        icon: Icons.link_off_rounded,
        title: de ? 'Kein DSP-Zugriff' : 'No DSP scope',
        message: de
            ? 'Für dieses Konto ist kein DSP hinterlegt.'
            : 'This account has no DSP assigned.',
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // Serverseitig nach `occurredAt` sortiert und gedeckelt, damit das
      // Limit die *neuesten* Vorfälle liefert statt einer beliebigen
      // Auswahl. Voraussetzung: jedes Dokument trägt `occurredAt` — Import
      // und Admin-Formular schreiben es, die Fahrer-App seit dem
      // Kennzeichen-Update ebenfalls.
      stream: incidentReportsCol(
        widget.dspUid,
      ).orderBy('occurredAt', descending: true).limit(_kListLimit).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _ListLoading();
        }
        if (snap.hasError) {
          return _EmptyState(
            icon: Icons.wifi_off_rounded,
            title: de ? 'Vorfälle nicht geladen' : 'Incidents not loaded',
            message: de
                ? 'Die Verbindung zu Firestore ist fehlgeschlagen. Lade die Seite neu.'
                : 'The connection to Firestore failed. Reload the page.',
          );
        }

        final all = (snap.data?.docs ?? const [])
            // Soft-gelöschte Vorfälle sind für den Admin weg — das
            // Dokument bleibt (Haftung), taucht aber weder in der Liste
            // noch in der Statistik oder den Jahres-Zählern auf.
            .where((d) => !isIncidentDeleted(d.data()))
            // Sicherheitsnetz: Fahrzeug-Checks liegen zwar unter
            // `users/{dsp}/drivers/{TID}/incident_reports` und damit gar
            // nicht in diesem Stream — falls das Pfad-TODO in
            // `vehicle_check_service.dart` je umgestellt wird, dürfen sie
            // hier trotzdem nicht als Vorfall auftauchen (und schon gar
            // nicht über den Löschweg dieser Seite verschwinden).
            .where((d) => !_isVehicleCheckDoc(d.data()))
            .where((d) => incidentCategoryOf(d.data()) == widget.category)
            .toList();
        final years = <int>{
          for (final d in all)
            if (incidentOccurredAt(d.data()) != null)
              incidentOccurredAt(d.data())!.year,
        }.toList()..sort((a, b) => b.compareTo(a));

        // Basis für die Statistik: alles außer dem Klickfilter.
        final statsSource = all
            .where((d) => _matchesBaseFilters(d.data()))
            .toList();
        final visible =
            statsSource.where((d) => _matchesFocus(d.data())).toList()
              ..sort((a, b) {
                final da = incidentOccurredAt(a.data());
                final db = incidentOccurredAt(b.data());
                if (da == null && db == null) return b.id.compareTo(a.id);
                if (da == null) return 1;
                if (db == null) return -1;
                return db.compareTo(da);
              });

        final thisYear = DateTime.now().year;
        final thisYearCount = all
            .where((d) => incidentOccurredAt(d.data())?.year == thisYear)
            .length;

        final payloads = statsSource.map((d) => d.data()).toList();
        final groups = _statsMode == 'plate'
            ? groupIncidentsByPlate(payloads)
            : groupIncidentsByDriver(payloads);

        return LayoutBuilder(
          builder: (context, outer) {
            final isMobile = outer.maxWidth < kIncidentMobileBreakpoint;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(de, all.length, thisYearCount, isMobile: isMobile),
                if ((snap.data?.docs.length ?? 0) >= _kListLimit) ...[
                  const SizedBox(height: 12),
                  _TruncationNotice(limit: _kListLimit),
                ],
                SizedBox(height: isMobile ? 12 : 16),
                if (isMobile)
                  _mobileFilterBar(de, years)
                else
                  _filterBar(de, years),
                if (_focus != null) ...[
                  const SizedBox(height: 12),
                  _ActiveFocusChip(
                    label: _focus!.label,
                    onClear: () => setState(() => _focus = null),
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final listArea = _listArea(de, visible, all.isEmpty);
                      // Ab 1000 px nebeneinander; darunter gestapelt mit
                      // einklappbarer Statistik, damit die Liste oben bleibt.
                      final wide = constraints.maxWidth >= 1000;
                      final panel = _StatsPanel(
                        groups: groups,
                        mode: _statsMode,
                        showModeToggle: !_isWorkAccident,
                        onModeChanged: (mode) => setState(() {
                          _statsMode = mode;
                          _focus = null;
                        }),
                        activeKey: _focus?.kind == _statsMode
                            ? _focus?.key
                            : null,
                        onSelect: (group) => _toggleFocus(
                          _StatFocus(
                            kind: _statsMode,
                            key: group.key,
                            label: group.label,
                          ),
                        ),
                        collapsible: !wide,
                        expanded: wide || _statsExpanded,
                        onToggleExpanded: () =>
                            setState(() => _statsExpanded = !_statsExpanded),
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(width: 360, child: panel),
                            const SizedBox(width: 20),
                            Expanded(child: listArea),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          panel,
                          const SizedBox(height: 16),
                          Expanded(child: listArea),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _listArea(
    bool de,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> visible,
    bool nothingAtAll,
  ) {
    return CoStateSwitcher(
      child: visible.isEmpty
          ? _emptyForState(de, nothingAtAll)
          : Scrollbar(
              key: const ValueKey('list'),
              controller: _listScrollCtrl,
              child: ListView.separated(
                controller: _listScrollCtrl,
                primary: false,
                padding: const EdgeInsets.only(bottom: 24, right: 4),
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final doc = visible[i];
                  return _IncidentCard(
                    data: doc.data(),
                    onOpen: () => _openDetails(doc),
                  );
                },
              ),
            ),
    );
  }

  Widget _emptyForState(bool de, bool nothingAtAll) {
    if (nothingAtAll) {
      return _EmptyState(
        key: const ValueKey('empty'),
        icon: _isWorkAccident
            ? Icons.personal_injury_outlined
            : Icons.car_crash_outlined,
        title: de ? 'Noch keine Vorfälle' : 'No incidents yet',
        message: de
            ? 'Erfasse den ersten Vorfall — den fertigen Bericht kannst du danach als Text kopieren.'
            : 'Log the first incident — you can copy the finished report as text afterwards.',
        action: CoButton(
          onPressed: () => _openForm(),
          icon: Icons.add_rounded,
          label: _isWorkAccident
              ? (de ? 'Arbeitsunfall erfassen' : 'Log work accident')
              : (de ? 'Vorfall erfassen' : 'Log incident'),
        ),
      );
    }
    return _EmptyState(
      key: const ValueKey('nomatch'),
      icon: Icons.filter_alt_off_outlined,
      title: de ? 'Kein Treffer' : 'No matches',
      message: de
          ? 'Kein Vorfall passt zu Suche und Filtern.'
          : 'No incident matches your search and filters.',
      action: CoButton(
        onPressed: _resetFilters,
        label: de ? 'Filter zurücksetzen' : 'Reset filters',
        variant: CoButtonVariant.secondaryOutlined,
      ),
    );
  }

  Widget _header(bool de, int total, int thisYear, {required bool isMobile}) {
    final counterOnly = de
        ? '$total ${total == 1 ? 'Vorfall' : 'Vorfälle'} · davon $thisYear dieses Jahr'
        : '$total ${total == 1 ? 'incident' : 'incidents'} · $thisYear this year';

    // Mobil trägt die Titelzeile der Seite bereits Überschrift und
    // Erfassen-Button — hier bleibt nur die Zählerzeile stehen.
    if (isMobile) {
      return Text(
        counterOnly,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: kIncidentMuted,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      );
    }

    final title = _isWorkAccident
        ? (de ? 'Arbeitsunfälle (Person)' : 'Work accidents (person)')
        : (de
              ? 'Unfälle & Schäden (Fahrzeug)'
              : 'Accidents & damage (vehicle)');
    final subtitle = _isWorkAccident
        ? (de
              ? 'Personenschaden am Arbeitsplatz — BG-relevant.'
              : 'Injury to a person at work — reportable to the BG.')
        : (de
              ? 'Alles rund um Fahrzeugschäden, Bergungen und Fremdschäden.'
              : 'Everything about vehicle damage, recoveries and third-party damage.');

    final counter = de
        ? '$total ${total == 1 ? 'Vorfall' : 'Vorfälle'} · davon $thisYear dieses Jahr'
        : '$total ${total == 1 ? 'incident' : 'incidents'} · $thisYear this year';

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: kIncidentText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: kIncidentMuted),
        ),
        const SizedBox(height: 8),
        Text(
          counter,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kIncidentMuted,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );

    final createButton = CoButton(
      onPressed: () => _openForm(),
      icon: Icons.add_rounded,
      label: _isWorkAccident
          ? (de ? 'Arbeitsunfall erfassen' : 'Log work accident')
          : (de ? 'Vorfall erfassen' : 'Log incident'),
    );

    // Unter ~640 px wandert die Aktion unter den Text, statt zu überlaufen.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [texts, const SizedBox(height: 12), createButton],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: texts),
            const SizedBox(width: 16),
            createButton,
          ],
        );
      },
    );
  }

  /// `true`, sobald einer der drei Dropdown-Filter vom Default abweicht.
  bool get _hasActiveFilters =>
      _typeFilter != 'all' ||
      _responsibilityFilter != 'all' ||
      _yearFilter != null;

  /// Mobile Filterzeile: dominantes 48px-Suchfeld, daneben ein einzelner
  /// Sammel-Filter-Button. Alle drei Filtergruppen (Art, Schuldfrage, Jahr)
  /// liegen im Bottom-Sheet — im Arbeitsunfall-Tab bleibt dort nur „Jahr",
  /// weil es die anderen beiden Dimensionen dort nicht gibt.
  Widget _mobileFilterBar(bool de, List<int> years) {
    return Row(
      children: [
        Expanded(child: _searchField(de, isMobile: true)),
        const SizedBox(width: 8),
        MobileIconButton(
          icon: Icons.tune,
          tooltip: de ? 'Filter' : 'Filters',
          active: _hasActiveFilters,
          onTap: () => _showFilterSheet(de, years),
        ),
      ],
    );
  }

  Future<void> _showFilterSheet(bool de, List<int> years) async {
    await showMobileSheet<void>(
      context: context,
      title: de ? 'Filter' : 'Filters',
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void apply(VoidCallback change) {
            setState(change);
            setSheet(() {});
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isWorkAccident) ...[
                MobileSheetSection(label: de ? 'Art' : 'Type'),
                MobileSheetOption(
                  label: de ? 'Alle Arten' : 'All types',
                  selected: _typeFilter == 'all',
                  onTap: () => apply(() => _typeFilter = 'all'),
                ),
                for (final type in kVehicleIncidentTypes)
                  MobileSheetOption(
                    label: incidentTypeLabel(type, de: de),
                    selected: _typeFilter == type,
                    onTap: () => apply(() => _typeFilter = type),
                  ),
                MobileSheetSection(
                  label: de ? 'Schuldfrage' : 'Responsibility',
                ),
                MobileSheetOption(
                  label: de ? 'Jede Schuldfrage' : 'Any responsibility',
                  selected: _responsibilityFilter == 'all',
                  onTap: () => apply(() => _responsibilityFilter = 'all'),
                ),
                for (final value in kResponsibilityValues)
                  MobileSheetOption(
                    label: responsibilityLabel(value, de: de),
                    selected: _responsibilityFilter == value,
                    onTap: () => apply(() => _responsibilityFilter = value),
                  ),
              ],
              if (years.isNotEmpty) ...[
                MobileSheetSection(label: de ? 'Jahr' : 'Year'),
                MobileSheetOption(
                  label: de ? 'Alle Jahre' : 'All years',
                  selected: _yearFilter == null,
                  onTap: () => apply(() => _yearFilter = null),
                ),
                for (final year in years)
                  MobileSheetOption(
                    label: '$year',
                    selected: _yearFilter == year,
                    onTap: () => apply(() => _yearFilter = year),
                  ),
              ],
              if (_hasActiveFilters)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: TextButton.icon(
                    onPressed: () {
                      _resetFilters();
                      Navigator.of(ctx).pop();
                    },
                    icon: const Icon(Icons.restart_alt, size: 18),
                    style: TextButton.styleFrom(foregroundColor: kMobileSubtle),
                    label: Text(
                      de ? 'Filter zurücksetzen' : 'Reset filters',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Suchfeld und Filter-Dropdowns in einer Zeile; auf schmalen Screens
  /// bricht der Wrap um. Die „Alle …"-Einträge sind der Default.
  Widget _filterBar(bool de, List<int> years) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Feste Breiten auf den verfügbaren Platz deckeln, damit bei 320 px
        // nichts über den Rand läuft.
        final available = constraints.maxWidth;
        double fit(double want) => want > available ? available : want;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(width: fit(320), child: _searchField(de)),
            if (!_isWorkAccident) ...[
              _FilterDropdown<String>(
                value: _typeFilter,
                onChanged: (v) => setState(() => _typeFilter = v ?? 'all'),
                icon: Icons.category_outlined,
                width: fit(200),
                items: [
                  DropdownMenuItem<String>(
                    value: 'all',
                    child: Text(de ? 'Alle Arten' : 'All types'),
                  ),
                  for (final type in kVehicleIncidentTypes)
                    DropdownMenuItem<String>(
                      value: type,
                      child: Text(incidentTypeLabel(type, de: de)),
                    ),
                ],
              ),
              _FilterDropdown<String>(
                value: _responsibilityFilter,
                onChanged: (v) =>
                    setState(() => _responsibilityFilter = v ?? 'all'),
                icon: Icons.gavel_rounded,
                width: fit(220),
                items: [
                  DropdownMenuItem<String>(
                    value: 'all',
                    child: Text(de ? 'Jede Schuldfrage' : 'Any responsibility'),
                  ),
                  for (final value in kResponsibilityValues)
                    DropdownMenuItem<String>(
                      value: value,
                      child: Text(responsibilityLabel(value, de: de)),
                    ),
                ],
              ),
            ],
            if (years.isNotEmpty)
              _FilterDropdown<int?>(
                value: _yearFilter,
                onChanged: (v) => setState(() => _yearFilter = v),
                icon: Icons.event_outlined,
                width: fit(180),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(de ? 'Alle Jahre' : 'All years'),
                  ),
                  for (final year in years)
                    DropdownMenuItem<int?>(value: year, child: Text('$year')),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _searchField(bool de, {bool isMobile = false}) {
    final field = TextField(
      controller: _searchCtrl,
      style: const TextStyle(fontSize: 14, color: kIncidentText),
      decoration: incidentInputDecoration(
        isDense: true,
        hintText: de
            ? 'Fahrer, Kennzeichen oder Text suchen'
            : 'Search driver, plate or text',
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 18,
          color: kIncidentMuted,
        ),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                onPressed: () => setState(() {
                  _searchCtrl.clear();
                  _query = '';
                }),
                icon: const Icon(Icons.close_rounded, size: 16),
                color: kIncidentMuted,
                // Sichtbar klein, Tap-Ziel volle 44 pt.
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                tooltip: de ? 'Suche leeren' : 'Clear search',
              ),
      ),
      onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
    );
    // Mobil bekommt das Feld die volle 48er-Höhe der Icon-Buttons daneben.
    return isMobile ? SizedBox(height: 48, child: field) : field;
  }

  void _openDetails(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    showDialog<void>(
      context: context,
      builder: (_) => _IncidentDetailDialog(
        docRef: doc.reference,
        initialData: doc.data(),
        onEdit: () => _openForm(docId: doc.id, initialData: doc.data()),
        onDelete: () => _deleteIncident(doc.reference, doc.data()),
      ),
    );
  }

  // ── Löschen (Soft-Delete + Undo) ───────────────────────────────────────

  /// Bestätigt und blendet einen Vorfall aus.
  ///
  /// Bewusst **kein** `delete()`: Unfall- und Arbeitsunfalldaten sind
  /// haftungs- und versicherungsrelevant (Regress, Gegenpartei,
  /// BG-Meldung). Gesetzt wird nur [kIncidentDeletedField]; das Dokument
  /// samt Fotos bleibt erhalten und lässt sich über die Undo-Snackbar
  /// (5 s) sofort zurückholen.
  ///
  /// Rechte: identisch zum Rest der Seite. `users/{dsp}/incident_reports`
  /// ist per Rules für den DSP selbst schreibbar und über die
  /// Blanket-Regel `match /{document=**}` auch für seine Dispatcher — wer
  /// die Seite öffnen kann, darf hier auch löschen. `deletedBy` hält die
  /// tatsächlich handelnde Auth-UID fest.
  Future<void> _deleteIncident(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final messenger = ScaffoldMessenger.of(context);

    if (_isVehicleCheckDoc(data)) {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            de
                ? 'Fahrzeug-Checks werden hier nicht gelöscht.'
                : 'Vehicle checks cannot be deleted here.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: kIncidentDanger,
          size: 28,
        ),
        title: Text(
          de ? 'Vorfall löschen?' : 'Delete incident?',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECDCA)),
              ),
              child: Text(
                _deleteSubject(data, de),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB42318),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              de
                  ? 'Unfalldaten sind haftungs- und versicherungsrelevant. '
                        'Der Vorfall verschwindet aus allen Listen, Statistiken '
                        'und Schadenzählern.'
                  : 'Incident data is liability and insurance relevant. '
                        'The incident disappears from every list, statistic and '
                        'damage counter.',
              style: const TextStyle(
                fontSize: 13,
                color: kIncidentMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              de
                  ? 'Du kannst das direkt danach 5 Sekunden lang rückgängig '
                        'machen.'
                  : 'You can undo this for 5 seconds afterwards.',
              style: const TextStyle(
                fontSize: 13,
                color: kIncidentMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: de ? 'Abbrechen' : 'Cancel',
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: Icons.delete_outline_rounded,
            label: de ? 'Löschen' : 'Delete',
            variant: CoButtonVariant.destructive,
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final actorUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      await setIncidentDeleted(ref, deleted: true, by: actorUid);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: kIncidentDanger,
          content: Text(
            de ? 'Löschen fehlgeschlagen: $e' : 'Delete failed: $e',
          ),
        ),
      );
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        content: Text(de ? 'Vorfall gelöscht.' : 'Incident deleted.'),
        action: SnackBarAction(
          label: de ? 'Rückgängig' : 'Undo',
          onPressed: () async {
            try {
              await setIncidentDeleted(ref, deleted: false);
            } catch (e) {
              messenger.showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: kIncidentDanger,
                  content: Text(
                    de
                        ? 'Wiederherstellen fehlgeschlagen: $e'
                        : 'Restore failed: $e',
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  /// „Fahrer · Datum" für den Bestätigungsdialog — der Admin muss sehen,
  /// **welchen** Vorfall er gerade wegklickt.
  static String _deleteSubject(Map<String, dynamic> data, bool de) {
    final driver = incidentDriverName(data);
    final occurredAt = incidentOccurredAt(data);
    final plate = incidentPlate(data);
    final parts = <String>[
      driver.isEmpty ? (de ? 'Fahrer unbekannt' : 'Driver unknown') : driver,
      if (occurredAt != null)
        DateFormat('dd.MM.yyyy').format(occurredAt)
      else
        (de ? 'ohne Datum' : 'no date'),
      if (plate.isNotEmpty) plate.toUpperCase(),
    ];
    return parts.join(' · ');
  }
}

/// Fahrzeug-Check statt echter Vorfallmeldung (Marker `kind`).
bool _isVehicleCheckDoc(Map<String, dynamic> data) =>
    (data['kind'] ?? '').toString().trim() == kVehicleCheckKind;

// ═════════════════════════════════════════════════════════════════════════
// Karte
// ═════════════════════════════════════════════════════════════════════════

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({required this.data, required this.onOpen});

  final Map<String, dynamic> data;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final workAccident = isWorkAccident(data);
    final occurredAt = incidentOccurredAt(data);
    final driverName = incidentDriverName(data);
    final plate = incidentPlate(data);
    final description = incidentDescription(data);
    final photoCount = incidentPhotoCount(data);
    final docCount = incidentAttachmentCount(data);

    return CoPressable(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kIncidentBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateBlock(occurredAt: occurredAt, timeText: _timeOf(data)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        driverName.isEmpty
                            ? (de ? 'Fahrer unbekannt' : 'Driver unknown')
                            : driverName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: driverName.isEmpty
                              ? kIncidentMuted
                              : kIncidentText,
                        ),
                      ),
                      if (plate.isNotEmpty) _PlateBadge(plate: plate),
                      if (workAccident)
                        _TypeBadge(
                          label: de ? 'Arbeitsunfall' : 'Work accident',
                          bg: const Color(0xFFE7F0FF),
                          fg: const Color(0xFF1D4ED8),
                        )
                      else
                        _TypeBadge(
                          label: incidentTypeLabel(
                            incidentTypeOf(data),
                            de: de,
                          ),
                          bg: _typeBg(incidentTypeOf(data)),
                          fg: _typeFg(incidentTypeOf(data)),
                        ),
                      if (photoCount > 0) IncidentPhotoBadge(count: photoCount),
                      if (docCount > 0) _DocumentBadge(count: docCount),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: kIncidentMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _CopyReportButton(data: data, compact: true),
          ],
        ),
      ),
    );
  }

  static String _timeOf(Map<String, dynamic> data) {
    final text = (data['timeText'] ?? '').toString().trim();
    if (text.isNotEmpty) return text;
    final occurredAt = incidentOccurredAt(data);
    if (occurredAt == null) return '';
    if (occurredAt.hour == 0 && occurredAt.minute == 0) return '';
    return DateFormat('HH:mm').format(occurredAt);
  }

  static Color _typeBg(String type) {
    switch (type) {
      case 'accident':
        return const Color(0xFFFEE4E2);
      case 'recovery':
        return const Color(0xFFFEF0C7);
      case 'wear_defect':
        return const Color(0xFFEFF1F5);
      case 'third_party_damage':
        return const Color(0xFFEDE9FE);
      case 'withdrawn':
        return const Color(0xFFECFDF3);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  static Color _typeFg(String type) {
    switch (type) {
      case 'accident':
        return const Color(0xFFB42318);
      case 'recovery':
        return const Color(0xFFB45309);
      case 'wear_defect':
        return const Color(0xFF475467);
      case 'third_party_damage':
        return const Color(0xFF6941C6);
      case 'withdrawn':
        return const Color(0xFF067647);
      default:
        return const Color(0xFF374151);
    }
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.occurredAt, required this.timeText});

  final DateTime? occurredAt;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    if (occurredAt == null) {
      return _shell(
        top: '—',
        middle: de ? 'ohne Datum' : 'no date',
        bottom: '',
      );
    }
    return _shell(
      top: DateFormat('dd').format(occurredAt!),
      middle: '${_month(occurredAt!.month, de)} ${occurredAt!.year}',
      bottom: timeText,
    );
  }

  // Handgepflegte Kurzmonate: `initializeDateFormatting` läuft in dieser App
  // nicht, ein lokalisiertes `DateFormat('MMM', 'de')` würde werfen.
  static const List<String> _monthsDe = <String>[
    'Jan',
    'Feb',
    'Mär',
    'Apr',
    'Mai',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Okt',
    'Nov',
    'Dez',
  ];
  static const List<String> _monthsEn = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _month(int month, bool de) {
    final index = (month - 1).clamp(0, 11);
    return de ? _monthsDe[index] : _monthsEn[index];
  }

  Widget _shell({
    required String top,
    required String middle,
    required String bottom,
  }) {
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: kIncidentFieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kIncidentBorder),
      ),
      child: Column(
        children: [
          Text(
            top,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kIncidentText,
              height: 1.1,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            middle,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kIncidentMuted,
            ),
          ),
          if (bottom.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              bottom,
              style: const TextStyle(
                fontSize: 11,
                color: kIncidentMuted,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlateBadge extends StatelessWidget {
  const _PlateBadge({required this.plate});
  final String plate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kIncidentBorder),
      ),
      child: Text(
        plate,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF374151),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

/// Prominenter Kopier-Button — kopiert den kompletten Bericht als Text.
class _CopyReportButton extends StatelessWidget {
  const _CopyReportButton({required this.data, this.compact = false});

  final Map<String, dynamic> data;
  final bool compact;

  Future<void> _copy(BuildContext context) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final messenger = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(
      ClipboardData(text: buildIncidentClipboardText(data)),
    );
    messenger?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
        content: Text(de ? 'Bericht kopiert.' : 'Report copied.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final label = de ? 'Bericht kopieren' : 'Copy report';

    if (!compact) {
      return CoButton(
        onPressed: () => _copy(context),
        icon: Icons.content_copy_rounded,
        label: label,
      );
    }

    return Tooltip(
      message: label,
      child: Material(
        color: const Color(0xFFECFDF3),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _copy(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFABEFC6)),
            ),
            child: const Icon(
              Icons.content_copy_rounded,
              size: 18,
              color: kIncidentFocus,
            ),
          ),
        ),
      ),
    );
  }
}

/// Ticket "INCIDENT REPORT": erzeugt (oder aktualisiert) den öffentlichen
/// Share-Link des Falls und kopiert ihn in die Zwischenablage. Jeder Fall
/// behält seinen eigenen, stabilen Link; erneutes Teilen aktualisiert den
/// Snapshot hinter dem bereits verteilten Link.
class _ShareLinkButton extends StatefulWidget {
  const _ShareLinkButton({required this.docRef, required this.data});

  final DocumentReference<Map<String, dynamic>> docRef;
  final Map<String, dynamic> data;

  @override
  State<_ShareLinkButton> createState() => _ShareLinkButtonState();
}

class _ShareLinkButtonState extends State<_ShareLinkButton> {
  bool _busy = false;

  Future<void> _share() async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final messenger = ScaffoldMessenger.maybeOf(context);
    setState(() => _busy = true);
    try {
      final url = await IncidentShareService().share(
        docId: widget.docRef.id,
        data: widget.data,
      );
      await Clipboard.setData(ClipboardData(text: url));
      messenger?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            de
                ? 'Öffentlicher Link kopiert — ohne Login abrufbar.'
                : 'Public link copied — viewable without login.',
          ),
        ),
      );
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB91C1C),
          content: Text(
            de ? 'Link konnte nicht erstellt werden: $e' : 'Sharing failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return CoButton(
      onPressed: _busy ? null : _share,
      icon: _busy ? Icons.hourglass_top_rounded : Icons.link_rounded,
      label: de ? 'Link teilen' : 'Share link',
      variant: CoButtonVariant.secondaryOutlined,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// Detail-Dialog
// ═════════════════════════════════════════════════════════════════════════

class _IncidentDetailDialog extends StatelessWidget {
  const _IncidentDetailDialog({
    required this.docRef,
    required this.initialData,
    required this.onEdit,
    required this.onDelete,
  });

  final DocumentReference<Map<String, dynamic>> docRef;
  final Map<String, dynamic> initialData;
  final VoidCallback onEdit;

  /// Soft-Delete mit Bestätigung + Undo (siehe
  /// `_IncidentListTabState._deleteIncident`).
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),
          builder: (context, snap) {
            final data = snap.data?.data() ?? initialData;
            final workAccident = isWorkAccident(data);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 12, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workAccident
                                  ? (de ? 'Arbeitsunfall' : 'Work accident')
                                  : (de
                                        ? 'Unfall oder Schaden'
                                        : 'Accident or damage'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: kIncidentText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _headline(data, de),
                              style: const TextStyle(
                                fontSize: 13,
                                color: kIncidentMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: kIncidentMuted,
                        tooltip: de ? 'Schließen' : 'Close',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: kIncidentBorder),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _CopyReportButton(data: data),
                            // Fahrzeug-Checks haben keinen Fall-Charakter —
                            // kein öffentlicher Bericht für sie.
                            if (!_isVehicleCheckDoc(data))
                              _ShareLinkButton(docRef: docRef, data: data),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ..._rows(context, data, de),
                        if (!workAccident) ...[
                          const SizedBox(height: 20),
                          _IncidentWorkflow(docRef: docRef),
                        ],
                        ..._photos(context, data, de),
                        // Belege (Polizeibericht, Schadenmeldung, …).
                        // Fahrzeug-Checks liegen in einer anderen
                        // Collection — dort stimmt weder der Storage-
                        // Scope noch der Anwendungsfall.
                        if (!_isVehicleCheckDoc(data)) ...[
                          const SizedBox(height: 20),
                          _IncidentAttachmentsSection(
                            docRef: docRef,
                            data: data,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: kIncidentBorder),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  // Wrap statt Row: mobil (Dialogbreite ≈ Bildschirm minus
                  // 40 px) passen Löschen + Schließen + Bearbeiten nicht in
                  // eine Zeile. Das `SizedBox` erzwingt die volle Breite,
                  // sonst schrumpft der Wrap auf die Buttonbreite und die
                  // Gruppe stünde mittig statt rechts.
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Fahrzeug-Checks sind hier nicht löschbar — sie
                        // gehören nicht in diese Liste (siehe
                        // `_isVehicleCheckDoc`).
                        if (!_isVehicleCheckDoc(data))
                          CoButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onDelete();
                            },
                            icon: Icons.delete_outline_rounded,
                            label: de ? 'Löschen' : 'Delete',
                            variant: CoButtonVariant.destructiveQuiet,
                          ),
                        CoButton(
                          onPressed: () => Navigator.of(context).pop(),
                          label: de ? 'Schließen' : 'Close',
                          variant: CoButtonVariant.quiet,
                        ),
                        CoButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onEdit();
                          },
                          icon: Icons.edit_outlined,
                          label: de ? 'Bearbeiten' : 'Edit',
                          variant: CoButtonVariant.secondaryOutlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _headline(Map<String, dynamic> data, bool de) {
    final occurredAt = incidentOccurredAt(data);
    final parts = <String>[
      if (occurredAt != null) DateFormat('dd.MM.yyyy').format(occurredAt),
      incidentDriverName(data),
      incidentPlate(data),
    ].where((e) => e.trim().isNotEmpty).toList();
    if (parts.isEmpty) return de ? 'Ohne Angaben' : 'No details';
    return parts.join(' · ');
  }

  List<Widget> _rows(BuildContext context, Map<String, dynamic> data, bool de) {
    final workAccident = isWorkAccident(data);
    final rows = <Widget>[];

    void row(String label, String value) {
      if (value.trim().isEmpty) return;
      rows.add(_DetailRow(label: label, value: value));
    }

    final occurredAt = incidentOccurredAt(data);
    final timeText = (data['timeText'] ?? '').toString().trim();
    if (occurredAt != null) {
      final time = timeText.isNotEmpty
          ? timeText
          : (occurredAt.hour == 0 && occurredAt.minute == 0
                ? ''
                : DateFormat('HH:mm').format(occurredAt));
      row(
        de ? 'Datum' : 'Date',
        time.isEmpty
            ? DateFormat('dd.MM.yyyy').format(occurredAt)
            : '${DateFormat('dd.MM.yyyy').format(occurredAt)} · $time',
      );
    }
    if (!workAccident) {
      row(
        de ? 'Vorfallart' : 'Incident type',
        incidentTypeLabel(incidentTypeOf(data), de: de),
      );
    }
    row(de ? 'Fahrer' : 'Driver', incidentDriverName(data));
    row(de ? 'Transporter-ID' : 'Transporter ID', incidentDriverTid(data));
    row(de ? 'Fahrzeug' : 'Vehicle', incidentPlate(data));
    row(de ? 'Ort' : 'Location', incidentAddress(data));
    row(de ? 'Hergang' : 'Course of events', incidentDescription(data));
    row(de ? 'Schaden' : 'Damage', (data['damage'] ?? '').toString());

    if (workAccident) {
      // Lese-Helfer statt Direktzugriff: eine in der Fahrer-App erstellte
      // Unfallanzeige legt dieselben Angaben unter `workAccident.*` ab.
      row(de ? 'Verletzung' : 'Injury', incidentInjuryType(data));
      row(de ? 'Körperteil' : 'Body part', incidentBodyPart(data));
      row(de ? 'Tätigkeit' : 'Activity', incidentActivityAtTime(data));
      if (data['firstAid'] == true) {
        final by = (data['firstAidBy'] ?? '').toString().trim();
        row(
          de ? 'Erste Hilfe' : 'First aid',
          by.isEmpty
              ? (de ? 'Ja' : 'Yes')
              : (de ? 'Ja (durch $by)' : 'Yes (by $by)'),
        );
      } else {
        row(de ? 'Behandlung' : 'Treatment', incidentDoctorText(data));
      }
      row(
        de ? 'Durchgangsarzt' : 'Designated doctor',
        data['doctorVisited'] == true ? (de ? 'Ja' : 'Yes') : '',
      );
      row(de ? 'Zeugen' : 'Witnesses', incidentWitnesses(data));
      final daysOff = data['expectedDaysOff'];
      if (daysOff is num && daysOff > 0) {
        row(
          de ? 'Voraussichtlicher Ausfall' : 'Expected days off',
          de ? '${daysOff.toInt()} Tage' : '${daysOff.toInt()} days',
        );
      }
      row(
        de ? 'BG-Meldung' : 'BG report',
        data['bgReportRequired'] == true
            ? (de ? 'erforderlich' : 'required')
            : '',
      );
    } else {
      row(
        de ? 'Schadenart' : 'Damage type',
        incidentDamageTypeLabel(data, de: de),
      );
      row(
        de ? 'Polizei beteiligt' : 'Police involved',
        incidentPoliceLabel(data, de: de),
      );
      final responsibility = incidentResponsibilityOf(data);
      if (responsibility != 'unknown') {
        row(
          de ? 'Schuldfrage' : 'Responsibility',
          responsibilityLabel(responsibility, de: de),
        );
      }
      final grounding = incidentGroundingOf(data);
      if (grounding != 'unknown') {
        final reason = (data['groundingReason'] ?? '').toString().trim();
        row(
          'Grounding',
          reason.isEmpty
              ? groundingLabel(grounding, de: de)
              : '${groundingLabel(grounding, de: de)} ($reason)',
        );
      }
      final tp = incidentMapOf(data['thirdParty']);
      final tpParts = <String>[
        (tp['name'] ?? '').toString(),
        (tp['plate'] ?? '').toString(),
        (tp['phone'] ?? '').toString(),
        (tp['email'] ?? '').toString(),
        (tp['insurance'] ?? '').toString(),
      ].map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (tpParts.isNotEmpty) {
        row(de ? 'Gegenpartei' : 'Third party', tpParts.join(' · '));
      }
    }

    row(de ? 'Notizen' : 'Notes', (data['notes'] ?? '').toString());
    row(
      de ? 'Gemeldet von' : 'Reported by',
      (data['reportedBy'] ?? '').toString(),
    );
    row(de ? 'Quelle' : 'Source', _sourceLabel(data, de));

    if (rows.isEmpty) {
      rows.add(
        Text(
          de ? 'Keine Angaben erfasst.' : 'No details recorded.',
          style: const TextStyle(fontSize: 13, color: kIncidentMuted),
        ),
      );
    }
    return rows;
  }

  static String _sourceLabel(Map<String, dynamic> data, bool de) {
    switch ((data['source'] ?? '').toString().trim()) {
      case kIncidentSourceCoDriver:
        return de ? 'In CoDriver erfasst' : 'Logged in CoDriver';
      case kIncidentSourceDriverApp:
        return de ? 'Fahrer-App' : 'Driver app';
      case 'structured':
        return de ? 'Import (strukturiert)' : 'Import (structured)';
      case 'chat_reconstructed':
        return de ? 'Import (aus Chat)' : 'Import (from chat)';
      default:
        return '';
    }
  }

  List<Widget> _photos(
    BuildContext context,
    Map<String, dynamic> data,
    bool de,
  ) {
    final photos = incidentPhotosOf(data);
    if (photos.isEmpty) return const <Widget>[];

    return <Widget>[
      const SizedBox(height: 20),
      Text(
        de ? 'Fotos (${photos.length})' : 'Photos (${photos.length})',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: kIncidentMuted,
          letterSpacing: 0.4,
        ),
      ),
      const SizedBox(height: 8),
      // Tippen öffnet die Lightbox statt eines neuen Tabs — der Admin
      // verliert sonst bei jedem Foto den Dialog-Kontext.
      IncidentPhotoGallery(photos: photos),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  DOKUMENTE / ANHÄNGE
// ─────────────────────────────────────────────────────────────────────────

/// Zähler-Badge auf der Vorfall-Kachel — Gegenstück zu
/// [IncidentPhotoBadge], damit man ohne Öffnen sieht, dass Belege
/// hinterlegt sind.
class _DocumentBadge extends StatelessWidget {
  const _DocumentBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Tooltip(
      message: de
          ? '$count ${count == 1 ? 'Dokument' : 'Dokumente'}'
          : '$count ${count == 1 ? 'document' : 'documents'}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF1F5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.attach_file_rounded,
              size: 13,
              color: Color(0xFF475467),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475467),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dokumenten-Block im Detail-Dialog: hochladen, öffnen, entfernen.
///
/// Sitzt bewusst hier und nicht im Erfassungsformular: das Dokument muss
/// existieren, bevor Dateien darunter abgelegt werden können (der
/// Storage-Pfad enthält die Report-ID), und Belege wie der
/// Polizeibericht treffen typischerweise Tage nach der Meldung ein.
class _IncidentAttachmentsSection extends StatefulWidget {
  const _IncidentAttachmentsSection({
    required this.docRef,
    required this.data,
  });

  final DocumentReference<Map<String, dynamic>> docRef;

  /// Live-Daten aus dem `StreamBuilder` des Dialogs — nach dem Upload
  /// rendert die Liste dadurch von selbst neu.
  final Map<String, dynamic> data;

  @override
  State<_IncidentAttachmentsSection> createState() =>
      _IncidentAttachmentsSectionState();
}

class _IncidentAttachmentsSectionState
    extends State<_IncidentAttachmentsSection> {
  bool _busy = false;

  /// `users/{dspUid}/incident_reports/{id}` → das Großeltern-Dokument ist
  /// der DSP.
  String get _dspUid => widget.docRef.parent.parent?.id ?? '';

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    if (_dspUid.isEmpty) {
      _snack(de ? 'Kein DSP-Zugriff.' : 'No DSP scope.');
      return;
    }

    IncidentAttachmentPickResult picked;
    try {
      picked = await pickIncidentAttachments();
    } catch (_) {
      _snack(
        de
            ? 'Datei-Auswahl fehlgeschlagen.'
            : 'File selection failed.',
      );
      return;
    }
    if (!mounted) return;

    if (picked.hasRejections) {
      final reasons = <String>[
        if (picked.tooLarge > 0)
          de
              ? '${picked.tooLarge} über 15 MB'
              : '${picked.tooLarge} over 15 MB',
        if (picked.wrongType > 0)
          de
              ? '${picked.wrongType} kein PDF/Bild'
              : '${picked.wrongType} not PDF/image',
        if (picked.unreadable > 0)
          de
              ? '${picked.unreadable} nicht lesbar'
              : '${picked.unreadable} unreadable',
      ];
      _snack(
        de
            ? 'Übersprungen: ${reasons.join(', ')}.'
            : 'Skipped: ${reasons.join(', ')}.',
      );
    }
    if (picked.files.isEmpty) return;

    setState(() => _busy = true);
    final uploaded = <IncidentAttachment>[];
    var failed = 0;
    for (var i = 0; i < picked.files.length; i++) {
      try {
        uploaded.add(
          await uploadIncidentAttachment(
            dspUid: _dspUid,
            reportId: widget.docRef.id,
            file: picked.files[i],
            index: i,
          ),
        );
      } catch (_) {
        failed++;
      }
    }
    // Auch bei Teilfehlern speichern: was oben liegt, gehört ins
    // Dokument — sonst bleibt die Datei verwaist im Bucket.
    try {
      await addIncidentAttachments(widget.docRef, uploaded);
    } catch (_) {
      // Firestore-Schreibrecht fehlt (nur das DSP-Konto selbst darf
      // Vorfälle ändern — siehe `firestore.rules`, `isSelf(userId)`).
      // Die schon hochgeladenen Dateien wieder wegräumen, sonst liegen
      // sie ohne Referenz im Bucket.
      for (final att in uploaded) {
        await deleteIncidentAttachmentFile(att.path);
      }
      failed += uploaded.length;
      uploaded.clear();
    }
    if (!mounted) return;
    setState(() => _busy = false);

    if (failed > 0) {
      _snack(
        de
            ? '$failed Datei(en) konnten nicht hochgeladen werden.'
            : '$failed file(s) could not be uploaded.',
      );
    } else if (uploaded.isNotEmpty) {
      _snack(
        de
            ? '${uploaded.length} Dokument(e) hinzugefügt.'
            : '${uploaded.length} document(s) added.',
      );
    }
  }

  Future<void> _open(IncidentAttachment att) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final uri = Uri.tryParse(att.url);
    if (uri == null) {
      _snack(de ? 'Link ist ungültig.' : 'Invalid link.');
      return;
    }
    var opened = false;
    try {
      opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      _snack(
        de
            ? 'Dokument konnte nicht geöffnet werden.'
            : 'Could not open the document.',
      );
    }
  }

  Future<void> _remove(IncidentAttachment att) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(de ? 'Dokument entfernen?' : 'Remove document?'),
        content: Text(
          de
              ? '„${att.name}" wird endgültig gelöscht.'
              : '"${att.name}" will be deleted permanently.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: kIncidentDanger),
            child: Text(de ? 'Entfernen' : 'Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      // Erst der Array-Eintrag: scheitert das Storage-Delete (Rolle ohne
      // Delete-Recht, Bestandseintrag ohne `path`), verschwindet der
      // Anhang trotzdem sauber aus der Ansicht.
      await removeIncidentAttachment(widget.docRef, att);
      await deleteIncidentAttachmentFile(att.path);
      if (!mounted) return;
      setState(() => _busy = false);
      _snack(de ? 'Dokument entfernt.' : 'Document removed.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack(
        de
            ? 'Dokument konnte nicht entfernt werden.'
            : 'Could not remove the document.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final attachments = incidentAttachmentsOf(widget.data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                de
                    ? 'Dokumente (${attachments.length})'
                    : 'Documents (${attachments.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: kIncidentMuted,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            // Kein `busy: true`: der Spinner von `CoButton` ist weiß und
            // damit auf der weißen Outlined-Fläche unsichtbar. Das Label
            // übernimmt die Rückmeldung.
            CoButton(
              onPressed: _busy ? null : _pickAndUpload,
              icon: Icons.upload_file_rounded,
              label: _busy
                  ? (de ? 'Lädt hoch …' : 'Uploading …')
                  : (de ? 'Hochladen' : 'Upload'),
              variant: CoButtonVariant.secondaryOutlined,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (attachments.isEmpty)
          Text(
            de
                ? 'Noch keine Dokumente. PDF oder Bild bis 15 MB — z. B. '
                      'Polizeibericht oder Zusammenfassung der Schadenmeldung.'
                : 'No documents yet. PDF or image up to 15 MB — e.g. police '
                      'report or damage claim summary.',
            style: const TextStyle(fontSize: 13, color: kIncidentMuted),
          )
        else
          for (final att in attachments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _IncidentAttachmentTile(
                attachment: att,
                onOpen: () => _open(att),
                onRemove: _busy ? null : () => _remove(att),
              ),
            ),
      ],
    );
  }
}

/// Eine Zeile der Dokumentenliste: Typ-Icon, Name, Größe, Entfernen.
class _IncidentAttachmentTile extends StatelessWidget {
  const _IncidentAttachmentTile({
    required this.attachment,
    required this.onOpen,
    required this.onRemove,
  });

  final IncidentAttachment attachment;
  final VoidCallback onOpen;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final isPdf = attachment.isPdf;
    final icon = isPdf
        ? Icons.picture_as_pdf_rounded
        : attachment.isImage
        ? Icons.image_outlined
        : Icons.insert_drive_file_outlined;
    final iconColor = isPdf ? kIncidentDanger : const Color(0xFF475467);
    final meta = <String>[
      if (isPdf) 'PDF' else if (attachment.isImage) (de ? 'Bild' : 'Image'),
      _formatFileSize(attachment.size, de),
    ].where((e) => e.isNotEmpty).join(' · ');

    return Container(
      decoration: BoxDecoration(
        color: kIncidentFieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kIncidentBorder),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CoPressable(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  children: <Widget>[
                    Icon(icon, size: 20, color: iconColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            attachment.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kIncidentText,
                            ),
                          ),
                          if (meta.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              meta,
                              style: const TextStyle(
                                fontSize: 11,
                                color: kIncidentMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: kIncidentMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: kIncidentMuted,
            tooltip: de ? 'Entfernen' : 'Remove',
          ),
        ],
      ),
    );
  }
}

/// Dateigröße kompakt — im Deutschen mit Komma als Dezimaltrenner.
String _formatFileSize(int bytes, bool de) {
  if (bytes <= 0) return '';
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
  final mb = kb / 1024;
  final text = mb.toStringAsFixed(mb < 10 ? 1 : 0);
  return '${de ? text.replaceAll('.', ',') : text} MB';
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 168,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: kIncidentMuted,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: kIncidentText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// Bausteine
// ═════════════════════════════════════════════════════════════════════════

/// Aus der Statistik angeklickter Fahrer bzw. Fahrzeug.
class _StatFocus {
  const _StatFocus({
    required this.kind,
    required this.key,
    required this.label,
  });

  /// 'driver' | 'plate'
  final String kind;
  final String key;
  final String label;
}

/// Kompaktes Filter-Dropdown in Feld-Optik der Seite.
class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
    this.width = 200,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        borderRadius: BorderRadius.circular(12),
        icon: const Icon(Icons.expand_more_rounded, size: 20),
        style: const TextStyle(fontSize: 13.5, color: kIncidentText),
        decoration: incidentInputDecoration(
          isDense: true,
          prefixIcon: Icon(icon, size: 17, color: kIncidentMuted),
        ),
      ),
    );
  }
}

/// Sichtbarer Hinweis auf den Klickfilter aus der Statistik — er lässt
/// sich auch dann aufheben, wenn das Panel gerade zugeklappt ist oder auf
/// die andere Dimension umgeschaltet wurde.
class _ActiveFocusChip extends StatelessWidget {
  const _ActiveFocusChip({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF3),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFABEFC6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_rounded, size: 15, color: kIncidentFocus),
            const SizedBox(width: 8),
            Text(
              de ? 'Gefiltert auf $label' : 'Filtered to $label',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: kIncidentFocus,
              ),
            ),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: 16),
              color: kIncidentFocus,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              tooltip: de ? 'Filter aufheben' : 'Clear filter',
            ),
          ],
        ),
      ),
    );
  }
}

/// Statistik-Karte: Vorfälle je Fahrer bzw. je Fahrzeug, absteigend.
/// Ein Klick auf eine Zeile filtert die Vorfallsliste — der Zähler wird
/// damit zur Navigation.
class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.groups,
    required this.mode,
    required this.showModeToggle,
    required this.onModeChanged,
    required this.activeKey,
    required this.onSelect,
    required this.collapsible,
    required this.expanded,
    required this.onToggleExpanded,
  });

  final List<IncidentGroup> groups;
  final String mode;
  final bool showModeToggle;
  final ValueChanged<String> onModeChanged;
  final String? activeKey;
  final ValueChanged<IncidentGroup> onSelect;
  final bool collapsible;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  /// Feste Höhe im gestapelten Layout — sonst würde die Karte die
  /// Vorfallsliste bei vielen Fahrern komplett verdrängen.
  static const double _stackedBodyHeight = 260;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final total = groups.fold<int>(0, (running, g) => running + g.count);

    final body = groups.isEmpty
        ? _EmptyStatsBody(de: de)
        : ListView.separated(
            primary: false,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, i) {
              final group = groups[i];
              return _StatsRow(
                group: group,
                selected: group.key == activeKey,
                onTap: () => onSelect(group),
              );
            },
          );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kIncidentBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(de, total),
          if (showModeToggle && expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _SegmentToggle(
                value: mode,
                onChanged: onModeChanged,
                segments: [
                  ('driver', de ? 'Fahrer' : 'Drivers'),
                  ('plate', de ? 'Fahrzeuge' : 'Vehicles'),
                ],
              ),
            ),
          if (expanded)
            collapsible
                ? SizedBox(height: _stackedBodyHeight, child: body)
                : Expanded(child: body),
        ],
      ),
    );
  }

  Widget _header(bool de, int total) {
    final title = Row(
      children: [
        const Icon(Icons.leaderboard_outlined, size: 18, color: kIncidentMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            de ? 'Statistik' : 'Statistics',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kIncidentText,
            ),
          ),
        ),
        Text(
          de
              ? '$total ${total == 1 ? 'Vorfall' : 'Vorfälle'}'
              : '$total ${total == 1 ? 'incident' : 'incidents'}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kIncidentMuted,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        if (collapsible) ...[
          const SizedBox(width: 4),
          Icon(
            expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            size: 20,
            color: kIncidentMuted,
          ),
        ],
      ],
    );

    final padded = Padding(
      padding: EdgeInsets.fromLTRB(16, 16, collapsible ? 12 : 16, 12),
      child: title,
    );

    if (!collapsible) return padded;
    return Semantics(
      button: true,
      expanded: expanded,
      child: InkWell(onTap: onToggleExpanded, child: padded),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.group,
    required this.selected,
    required this.onTap,
  });

  final IncidentGroup group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? const Color(0xFFECFDF3) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? kIncidentFocus : kIncidentText,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  constraints: const BoxConstraints(minWidth: 28),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? kIncidentFocus : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${group.count}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : kIncidentMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: kIncidentFocus,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyStatsBody extends StatelessWidget {
  const _EmptyStatsBody({required this.de});

  final bool de;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bar_chart_rounded,
              size: 24,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            Text(
              de ? 'Noch keine Vorfälle' : 'No incidents yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kIncidentText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              de
                  ? 'Sobald Vorfälle erfasst sind, stehen hier die häufigsten zuerst.'
                  : 'Once incidents are logged, the most frequent appear here first.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: kIncidentMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Zwei-Segment-Umschalter im Stil der Seite (Fahrer | Fahrzeuge).
class _SegmentToggle extends StatelessWidget {
  const _SegmentToggle({
    required this.value,
    required this.onChanged,
    required this.segments,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final List<(String, String)> segments;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kIncidentFieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kIncidentBorder),
      ),
      child: Row(
        children: [
          for (final (key, label) in segments)
            Expanded(
              child: Semantics(
                selected: key == value,
                button: true,
                child: Material(
                  color: key == value ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => onChanged(key),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: key == value
                              ? kIncidentBorder
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: key == value
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: key == value ? kIncidentText : kIncidentMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Hinweis, sobald die Liste am Limit hängt — sonst sähe eine gefilterte
/// Suche so aus, als gäbe es die älteren Vorfälle gar nicht.
class _TruncationNotice extends StatelessWidget {
  const _TruncationNotice({required this.limit});

  final int limit;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF0C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEDF89)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFFB45309),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              de
                  ? 'Es werden die neuesten $limit Vorfälle angezeigt.'
                  : 'Showing the $limit most recent incidents.',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF93370D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListLoading extends StatelessWidget {
  const _ListLoading();

  @override
  Widget build(BuildContext context) {
    // Skeleton statt Spinner: die Liste braucht regelmäßig > 1 s.
    return ListView.separated(
      key: const ValueKey('skeleton'),
      padding: const EdgeInsets.only(top: 96),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 96,
        decoration: BoxDecoration(
          color: kIncidentFieldFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kIncidentBorder),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kIncidentFieldFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kIncidentBorder),
              ),
              child: Icon(icon, size: 22, color: kIncidentMuted),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kIncidentText,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: kIncidentMuted,
                  height: 1.5,
                ),
              ),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// Einstellungen (Firma / Versicherung — Basis der Fahrer-Meldung)
// ═════════════════════════════════════════════════════════════════════════

class _IncidentSettingsTab extends StatefulWidget {
  const _IncidentSettingsTab({required this.dspUid});
  final String dspUid;

  @override
  State<_IncidentSettingsTab> createState() => _IncidentSettingsTabState();
}

class _IncidentSettingsTabState extends State<_IncidentSettingsTab> {
  final _companyNameCtrl = TextEditingController();
  final _companyAddress1Ctrl = TextEditingController();
  final _companyAddress2Ctrl = TextEditingController();
  final _companyPhoneCtrl = TextEditingController();
  final _companyEmailCtrl = TextEditingController();
  final _insuranceNameCtrl = TextEditingController();
  final _insurancePolicyCtrl = TextEditingController();
  final _insuranceEmailCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in <TextEditingController>[
      _companyNameCtrl,
      _companyAddress1Ctrl,
      _companyAddress2Ctrl,
      _companyPhoneCtrl,
      _companyEmailCtrl,
      _insuranceNameCtrl,
      _insurancePolicyCtrl,
      _insuranceEmailCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  DocumentReference<Map<String, dynamic>>? get _ref {
    if (widget.dspUid.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('settings')
        .doc('incident_report');
  }

  static String _s(dynamic v) => v?.toString().trim() ?? '';

  static String _pick(List<String> values) {
    for (final v in values) {
      if (v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  Future<void> _load() async {
    final ref = _ref;
    if (ref == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final snap = await ref.get();
      final data = snap.data() ?? const <String, dynamic>{};
      final company = incidentMapOf(data['company']);
      final insurance = incidentMapOf(data['insurance']);
      if (!mounted) return;
      _companyNameCtrl.text = _pick([
        _s(company['name']),
        _s(data['company_name']),
      ]);
      _companyAddress1Ctrl.text = _pick([
        _s(company['addressLine1']),
        _s(data['company_addressLine1']),
      ]);
      _companyAddress2Ctrl.text = _pick([
        _s(company['addressLine2']),
        _s(data['company_addressLine2']),
      ]);
      _companyPhoneCtrl.text = _pick([
        _s(company['phone']),
        _s(data['company_phone']),
      ]);
      _companyEmailCtrl.text = _pick([
        _s(company['email']),
        _s(data['company_email']),
      ]);
      _insuranceNameCtrl.text = _pick([
        _s(insurance['name']),
        _s(data['insurance_name']),
      ]);
      _insurancePolicyCtrl.text = _pick([
        _s(insurance['policyNumber']),
        _s(data['insurance_policyNumber']),
      ]);
      _insuranceEmailCtrl.text = _pick([
        _s(insurance['email']),
        _s(data['insurance_email']),
      ]);
    } catch (_) {
      // Fehler zeigt sich beim Speichern; Felder bleiben leer und editierbar.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final ref = _ref;
    final de = Localizations.localeOf(context).languageCode == 'de';
    if (ref == null) return;
    setState(() => _saving = true);
    try {
      await ref.set({
        'enabled': true,
        'company': {
          'name': _companyNameCtrl.text.trim(),
          'addressLine1': _companyAddress1Ctrl.text.trim(),
          'addressLine2': _companyAddress2Ctrl.text.trim(),
          'phone': _companyPhoneCtrl.text.trim(),
          'email': _companyEmailCtrl.text.trim(),
        },
        'insurance': {
          'name': _insuranceNameCtrl.text.trim(),
          'policyNumber': _insurancePolicyCtrl.text.trim(),
          'email': _insuranceEmailCtrl.text.trim(),
        },
        // Flache Spiegelung — ältere Clients lesen noch die flachen Keys.
        'company_name': _companyNameCtrl.text.trim(),
        'company_addressLine1': _companyAddress1Ctrl.text.trim(),
        'company_addressLine2': _companyAddress2Ctrl.text.trim(),
        'company_phone': _companyPhoneCtrl.text.trim(),
        'company_email': _companyEmailCtrl.text.trim(),
        'insurance_name': _insuranceNameCtrl.text.trim(),
        'insurance_policyNumber': _insurancePolicyCtrl.text.trim(),
        'insurance_email': _insuranceEmailCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(de ? 'Einstellungen gespeichert.' : 'Settings saved.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: kIncidentDanger,
          content: Text(
            de ? 'Speichern fehlgeschlagen: $e' : 'Could not save: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(kIncidentFocus),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < kIncidentMobileBreakpoint;

        // Mobil entfallen Karten-Überschrift und Erklärtext; die beiden
        // Blöcke stehen als schlanke Abschnittslabels über ihren Feldern.
        final company = <Widget>[
          if (isMobile)
            _sectionLabel(de ? 'Firma' : 'Company')
          else ...[
            Text(
              de ? 'Firma und Versicherung' : 'Company and insurance',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: kIncidentText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              de
                  ? 'Diese Angaben sieht der Fahrer, wenn er einen Unfall meldet.'
                  : 'Drivers see these details when they report an accident.',
              style: const TextStyle(fontSize: 13, color: kIncidentMuted),
            ),
            const SizedBox(height: 24),
          ],
          IncidentField(
            label: de ? 'Firmenname' : 'Company name',
            child: _field(_companyNameCtrl),
          ),
          IncidentField(
            label: de ? 'Adresse, Zeile 1' : 'Address line 1',
            child: _field(_companyAddress1Ctrl),
          ),
          IncidentField(
            label: de ? 'Adresse, Zeile 2' : 'Address line 2',
            child: _field(_companyAddress2Ctrl),
          ),
          IncidentField(
            label: de ? 'Telefon' : 'Phone',
            child: _field(_companyPhoneCtrl, type: TextInputType.phone),
          ),
          IncidentField(
            label: de ? 'E-Mail' : 'Email',
            child: _field(_companyEmailCtrl, type: TextInputType.emailAddress),
          ),
        ];

        final insurance = <Widget>[
          _sectionLabel(de ? 'Versicherung' : 'Insurance'),
          IncidentField(
            label: de ? 'Versicherungsgesellschaft' : 'Insurance company',
            child: _field(_insuranceNameCtrl),
          ),
          IncidentField(
            label: de ? 'Versicherungsnummer' : 'Policy number',
            child: _field(_insurancePolicyCtrl),
          ),
          IncidentField(
            label: de ? 'E-Mail der Versicherung' : 'Insurance email',
            child: _field(
              _insuranceEmailCtrl,
              type: TextInputType.emailAddress,
            ),
          ),
        ];

        final actions = isMobile
            // Mobil volle Breite untereinander — Tap-Ziele bleiben groß.
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CoButton(
                    onPressed: _saving ? null : _save,
                    icon: Icons.check_rounded,
                    label: de ? 'Einstellungen speichern' : 'Save settings',
                    busy: _saving,
                  ),
                  const SizedBox(height: 8),
                  CoButton(
                    onPressed: _saving ? null : _load,
                    label: de ? 'Zurücksetzen' : 'Reset',
                    variant: CoButtonVariant.quiet,
                  ),
                ],
              )
            : Row(
                children: [
                  CoButton(
                    onPressed: _saving ? null : _save,
                    icon: Icons.check_rounded,
                    label: de ? 'Einstellungen speichern' : 'Save settings',
                    busy: _saving,
                  ),
                  const SizedBox(width: 8),
                  CoButton(
                    onPressed: _saving ? null : _load,
                    label: de ? 'Zurücksetzen' : 'Reset',
                    variant: CoButtonVariant.quiet,
                  ),
                ],
              );

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kIncidentBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...company,
                  const SizedBox(height: 8),
                  ...insurance,
                  const SizedBox(height: 8),
                  actions,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Schlankes Abschnittslabel im Stil der Mobile-Sheets.
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: kIncidentMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, {TextInputType? type}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(fontSize: 14, color: kIncidentText),
      decoration: incidentInputDecoration(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// Bearbeitungs-Status (Fahrzeug-Vorfälle)
// ═════════════════════════════════════════════════════════════════════════

/// Live-Checkliste für die Unfall-Bearbeitung. Jeder Haken schreibt nach
/// `workflow.*` auf dem Vorfall, damit der Stand für das ganze Team sichtbar
/// ist.
class _IncidentWorkflow extends StatefulWidget {
  const _IncidentWorkflow({required this.docRef});
  final DocumentReference<Map<String, dynamic>> docRef;

  @override
  State<_IncidentWorkflow> createState() => _IncidentWorkflowState();
}

class _IncidentWorkflowState extends State<_IncidentWorkflow> {
  final _claimNumberCtrl = TextEditingController();
  String _lastClaimText = '';

  @override
  void dispose() {
    _claimNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggle(String key, bool value) async {
    await widget.docRef.set({
      'workflow': {
        // Beim Zurücknehmen wird der Zeitstempel entfernt, nicht auf null
        // gesetzt — ein null-Feld bliebe im Dokument stehen und sähe für
        // jeden Leser wie „Wert vorhanden, aber leer" aus.
        key: value,
        '${key}At': value ? FieldValue.serverTimestamp() : FieldValue.delete(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _saveClaim() async {
    final text = _claimNumberCtrl.text.trim();
    if (text == _lastClaimText) return;
    _lastClaimText = text;
    await widget.docRef.set({
      'workflow': {'thirdPartyClaimNumber': text},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: widget.docRef.snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data() ?? const <String, dynamic>{};
        final wf = incidentMapOf(data['workflow']);
        bool flag(String k) => wf[k] == true;

        final claim = (wf['thirdPartyClaimNumber'] ?? '').toString();
        if (claim != _lastClaimText && _claimNumberCtrl.text != claim) {
          _claimNumberCtrl.text = claim;
          _lastClaimText = claim;
        }

        final done = <bool>[
          flag('reportSent'),
          flag('repairApproved'),
          flag('inWorkshop'),
          flag('thirdPartyNotified'),
          flag('closed'),
        ];
        final allDone = !done.contains(false);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: allDone ? const Color(0xFFECFDF3) : kIncidentFieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: allDone ? const Color(0xFFABEFC6) : kIncidentBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    allDone
                        ? Icons.check_circle_rounded
                        : Icons.timelapse_rounded,
                    size: 18,
                    color: allDone ? kIncidentFocus : kIncidentMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    de ? 'Bearbeitungs-Status' : 'Handling status',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: allDone ? kIncidentFocus : kIncidentText,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${done.where((e) => e).length}/${done.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kIncidentMuted,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _WorkflowCheck(
                label: de
                    ? 'Unfall-Report an Versicherung gesendet'
                    : 'Accident report sent to the insurer',
                value: flag('reportSent'),
                onChanged: (v) => _toggle('reportSent', v),
              ),
              _WorkflowCheck(
                label: de
                    ? 'Reparaturfreigabe erhalten'
                    : 'Repair approval received',
                value: flag('repairApproved'),
                onChanged: (v) => _toggle('repairApproved', v),
              ),
              _WorkflowCheck(
                label: de
                    ? 'Fahrzeug in der Werkstatt'
                    : 'Vehicle in the workshop',
                value: flag('inWorkshop'),
                onChanged: (v) => _toggle('inWorkshop', v),
              ),
              _WorkflowCheck(
                label: de ? 'Unfallgegner informiert' : 'Third party informed',
                value: flag('thirdPartyNotified'),
                onChanged: (v) => _toggle('thirdPartyNotified', v),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 4, bottom: 8),
                child: TextField(
                  controller: _claimNumberCtrl,
                  style: const TextStyle(fontSize: 13, color: kIncidentText),
                  decoration: incidentInputDecoration(
                    hintText: de
                        ? 'Schadennummer (optional)'
                        : 'Claim number (optional)',
                    isDense: true,
                  ).copyWith(fillColor: Colors.white),
                  onEditingComplete: _saveClaim,
                  onTapOutside: (_) => _saveClaim(),
                ),
              ),
              _WorkflowCheck(
                label: de ? 'Alles abgeschlossen' : 'Everything closed',
                value: flag('closed'),
                onChanged: (v) => _toggle('closed', v),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkflowCheck extends StatelessWidget {
  const _WorkflowCheck({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                visualDensity: VisualDensity.compact,
                activeColor: kIncidentFocus,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kIncidentText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
