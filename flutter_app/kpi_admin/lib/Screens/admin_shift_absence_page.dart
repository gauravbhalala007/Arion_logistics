import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/employment_period.dart';
import '../services/vacation_pools_repository.dart';
import '../utils/driver_activity.dart';
import '../utils/vacation_days.dart';
import '../utils/vacation_pools.dart';
import '../widgets/clearable_search_field.dart';
import '../widgets/vacation_pool_lines.dart';
import '../widgets/web_preview.dart'
    if (dart.library.html) '../widgets/web_preview_web.dart';
import 'zeitkonto_tab.dart';

/// Eine Zeile des Kranktage-Rankings: genehmigte Krankheitstage eines
/// aktiven Fahrers, absolut und relativ zur Beschäftigungsdauer.
class _SickRankEntry {
  final String driverId;
  final String name;
  final int totalDays;

  /// Kalendertage über alle Beschäftigungszeiträume (bis heute);
  /// 0 = kein Zeitraum im Drivers Hub hinterlegt.
  final int employedDays;

  const _SickRankEntry({
    required this.driverId,
    required this.name,
    required this.totalDays,
    required this.employedDays,
  });

  double? get percent =>
      employedDays > 0 ? totalDays / employedDays * 100 : null;
}

class AdminShiftAbsencePage extends StatefulWidget {
  const AdminShiftAbsencePage({super.key, this.requestType});

  /// When set ('vacation' or 'sick_leave'), this page only shows
  /// requests of that type — used by the Zeiten & Abwesenheiten
  /// tab shell to render two distinct pages from the same widget.
  /// Null = show all (legacy combined behaviour).
  final String? requestType;

  @override
  State<AdminShiftAbsencePage> createState() => _AdminShiftAbsencePageState();
}

class _AdminShiftAbsencePageState extends State<AdminShiftAbsencePage> {
  static const _kGreen = Color(0xFF1D7F5A);
  static const _kText = Color(0xFF111827);
  static const _kMuted = Color(0xFF6B7280);
  static const _kBorder = Color(0xFFE5E7EB);
  static const _kPageBg = Color(0xFFF4F5FB);
  static const _kOrange = Color(0xFFFF7A18);
  static const _kRed = Color(0xFFB91C1C);

  /// Offene Anträge / bevorstehende Abwesenheit werden nur als kurze
  /// Vorschau gezeigt — alles darüber hinaus über "Mehr anzeigen".
  static const int _kPreviewLimit = 3;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  bool get _de => Localizations.localeOf(context).languageCode == 'de';
  String? _resolvedDspUid;
  bool _loadingScope = true;
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // ── Kranktage-Ranking (nur Krankmeldungs-Ansicht) ─────────────────
  // Einmal geladen, nach Erfassen/Import/Statuswechsel aktualisiert.
  Future<List<_SickRankEntry>>? _rankingFuture;
  bool _rankingByPercent = false;
  bool _rankingExpanded = false;

  /// Historie: standardmäßig nur [_kPreviewLimit] Einträge, der Rest
  /// klappt über „Mehr anzeigen" direkt in der Karte auf (gleiche
  /// Mechanik wie beim Kranktage-Ranking oben).
  bool _historyExpanded = false;

  /// Ticket „TIME & ABSENCE - HISTORY": Sortierung der Historie.
  /// Vorbelegung = bisheriges Verhalten (Erfassungs-/Prüfzeitpunkt,
  /// neueste zuerst).
  _HistorySort _historySort = _HistorySort.addedAt;

  void _refreshRanking() {
    if (widget.requestType != 'sick_leave') return;
    if (_scopeUid == null) return;
    setState(() => _rankingFuture = _loadSickRanking());
  }

  @override
  void initState() {
    super.initState();
    _resolveScope();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String? get _scopeUid {
    final uid = _uid;
    if (uid == null) return null;
    final scoped = (_resolvedDspUid ?? '').trim();
    return scoped.isNotEmpty ? scoped : uid;
  }

  CollectionReference<Map<String, dynamic>>? get _rootAbsencesCol {
    final scope = _scopeUid;
    if (scope == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('absence_requests');
  }

  void _setLoadingScope(bool value) {
    if (!mounted) return;
    setState(() => _loadingScope = value);
  }

  Future<void> _resolveScope() async {
    final uid = _uid;
    if (uid == null) {
      _setLoadingScope(false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!mounted) return;
      final data = snap.data() ?? const <String, dynamic>{};
      final dspUid = (data['dspUid'] ?? '').toString().trim();
      _resolvedDspUid = dspUid.isEmpty ? uid : dspUid;
    } catch (_) {
      if (!mounted) return;
      _resolvedDspUid = uid;
    } finally {
      _setLoadingScope(false);
    }
  }

  Future<void> _updateAbsenceStatus({
    required String requestId,
    required String driverId,
    required String status,
    /// Ticket „TIME & ABSENCE - HISTORY": Pflicht-Begründung beim
    /// Ablehnen — wird am Antrag gespeichert und dem Fahrer in der
    /// Benachrichtigung mitgeschickt.
    String rejectionReason = '',
    /// Antragsdaten für die Fahrer-Benachrichtigung (Zeitraum + Art).
    /// `null` = keine Benachrichtigung schreiben.
    _AbsenceAdminItem? notifySource,
  }) async {
    final scope = _scopeUid;
    if (scope == null) {
      _showSnack(
        _de ? 'DSP-Zuordnung fehlt.' : 'Missing DSP scope.',
        error: true,
      );
      return;
    }

    try {
      final db = FirebaseFirestore.instance;
      final rootRef = db
          .collection('users')
          .doc(scope)
          .collection('absence_requests')
          .doc(requestId);
      final driverRef = db
          .collection('users')
          .doc(scope)
          .collection('drivers')
          .doc(driverId.toUpperCase())
          .collection('absence_requests')
          .doc(requestId);

      // Ticket jlmRu2T: Beim Stornieren bleiben `reviewedBy`/`reviewedAt`
      // UNANGETASTET — sonst ginge verloren, wer den Antrag ursprünglich
      // genehmigt hat. Die Stornierung bekommt eigene Felder.
      final isCancel = status == 'cancelled';
      final reason = rejectionReason.trim();
      final payload = <String, dynamic>{
        'status': status,
        if (isCancel) ...{
          'cancelledBy': _uid,
          'cancelledAt': FieldValue.serverTimestamp(),
        } else ...{
          'reviewedBy': _uid,
          'reviewedAt': FieldValue.serverTimestamp(),
        },
        // Der Grund gehört nur an eine Ablehnung. Wird ein Antrag später
        // doch genehmigt, verschwindet die alte Begründung wieder.
        if (status == 'rejected' && reason.isNotEmpty)
          'rejectionReason': reason
        else if (status == 'approved')
          'rejectionReason': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final batch = db.batch();
      batch.set(rootRef, payload, SetOptions(merge: true));
      batch.set(driverRef, payload, SetOptions(merge: true));
      await batch.commit();

      // Fahrer über die Entscheidung informieren — bewusst NACH dem
      // Commit und in einem eigenen try/catch: schlägt allein die
      // Benachrichtigung fehl, ist der Statuswechsel trotzdem gültig.
      if (notifySource != null && (status == 'approved' || status == 'rejected')) {
        await _notifyDriverAboutDecision(
          scope: scope,
          item: notifySource,
          status: status,
          rejectionReason: reason,
        );
      }

      _showSnack(
        status == 'approved'
            ? (_de
                ? 'Antrag erfolgreich genehmigt.'
                : 'Request approved successfully.')
            : status == 'cancelled'
                ? (_de
                    ? 'Abwesenheit storniert.'
                    : 'Leave cancelled.')
                : (_de
                    ? 'Antrag erfolgreich abgelehnt.'
                    : 'Request rejected successfully.'),
      );
      _refreshRanking();
    } catch (e) {
      _showSnack(
        _de
            ? 'Antrag konnte nicht aktualisiert werden: $e'
            : 'Failed to update request: $e',
        error: true,
      );
    }
  }

  /// Ticket „TIME & ABSENCE - HISTORY": Fahrer über die Entscheidung
  /// informieren.
  ///
  /// Schreibt EINEN neuen Eintrag in
  /// `users/{dspUid}/drivers/{TID}/notifications` — exakt im Bestands-
  /// format der Fahrer-Benachrichtigungen (siehe `notifications_page`
  /// und `models/driver_notification.dart`): `type`/`title`/`body`/
  /// `sourceLang`/`translations`/`status`/`readAt`/`confirmedAt`/
  /// `requiresConfirmation`/`createdAt`.
  ///
  ///  * `type: 'message'` — die Fahrer-App filtert danach („Nachrichten"),
  ///    `rule` ist den bestätigungspflichtigen Regeln vorbehalten.
  ///  * `requiresConfirmation: false` — wie bei jeder Nachricht, die
  ///    keine Unterschrift verlangt (`notifications_page` setzt das Flag
  ///    ebenfalls nur für `rule`).
  ///  * `translations` mit `de` + `en`; die Fahrer-App zieht daraus die
  ///    Fassung ihrer eigenen Sprache und fällt sonst auf `title`/`body`
  ///    in der Sprache des Admins zurück.
  ///
  /// Bewusst immer ein NEUES Dokument (`doc()` ohne ID): die Rules
  /// erlauben dem DSP an dieser Stelle nur `create`, kein `update`.
  Future<void> _notifyDriverAboutDecision({
    required String scope,
    required _AbsenceAdminItem item,
    required String status,
    required String rejectionReason,
  }) async {
    if (item.driverId.isEmpty) return;
    final approved = status == 'approved';
    final reason = rejectionReason.trim();

    String bodyFor(bool de) {
      final range = '${item.fromDateText} – ${item.toDateText}';
      final head = de
          ? '${item.typeLabel(true)}: $range (${item.daysLabel(true)})'
          : '${item.typeLabel(false)}: $range (${item.daysLabel(false)})';
      if (approved) {
        return de
            ? '$head wurde genehmigt.'
            : '$head has been approved.';
      }
      final rejected = de
          ? '$head wurde abgelehnt.'
          : '$head has been rejected.';
      if (reason.isEmpty) return rejected;
      return de
          ? '$rejected\n\nGrund: $reason'
          : '$rejected\n\nReason: $reason';
    }

    String titleFor(bool de) {
      if (approved) {
        return de
            ? 'Abwesenheitsantrag genehmigt'
            : 'Absence request approved';
      }
      return de
          ? 'Abwesenheitsantrag abgelehnt'
          : 'Absence request rejected';
    }

    try {
      final sourceLang = _de ? 'de' : 'en';
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(scope)
          .collection('drivers')
          .doc(item.driverId.toUpperCase())
          .collection('notifications')
          .doc();
      final now = FieldValue.serverTimestamp();
      await ref.set({
        'notificationId': ref.id,
        'type': 'message',
        'title': titleFor(_de),
        'body': bodyFor(_de),
        'sourceLang': sourceLang,
        'translations': <String, dynamic>{
          'de': {'title': titleFor(true), 'body': bodyFor(true)},
          'en': {'title': titleFor(false), 'body': bodyFor(false)},
        },
        'status': 'unread',
        'readAt': null,
        'confirmedAt': null,
        'requiresConfirmation': false,
        'createdAt': now,
        'updatedAt': now,
      });
    } catch (e) {
      // Der Statuswechsel ist bereits gespeichert — hier nur informieren,
      // damit der Admin den Fahrer notfalls anders erreicht.
      _showSnack(
        _de
            ? 'Status gespeichert, aber die Benachrichtigung an den Fahrer '
                'konnte nicht zugestellt werden: $e'
            : 'Status saved, but the driver notification could not be '
                'delivered: $e',
        error: true,
      );
    }
  }

  /// Ablehnen mit Pflicht-Begründung (Ticket „TIME & ABSENCE -
  /// HISTORY"). Der Text landet am Antrag (`rejectionReason`) und in der
  /// Benachrichtigung an den Fahrer.
  Future<void> _confirmRejectAbsence(_AbsenceAdminItem item) async {
    final de = _de;
    final controller = TextEditingController();
    try {
      final reason = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          String? error;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              void submit() {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  setDialogState(() {
                    error = de
                        ? 'Bitte einen Grund angeben.'
                        : 'Please provide a reason.';
                  });
                  return;
                }
                Navigator.of(dialogContext).pop(value);
              }

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  de ? 'Antrag ablehnen?' : 'Reject request?',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                content: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.driverName} · ${item.typeLabel(de)}\n'
                        '${item.fromDateText} – ${item.toDateText} · '
                        '${item.daysLabel(de)}',
                        style: const TextStyle(
                          color: _kText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        minLines: 3,
                        maxLines: 5,
                        maxLength: 500,
                        textInputAction: TextInputAction.newline,
                        onChanged: (_) {
                          if (error == null) return;
                          setDialogState(() => error = null);
                        },
                        decoration: InputDecoration(
                          labelText: de
                              ? 'Grund der Ablehnung'
                              : 'Reason for rejection',
                          hintText: de
                              ? 'Wird dem Fahrer mitgeteilt.'
                              : 'Will be sent to the driver.',
                          errorText: error,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      Text(
                        de
                            ? 'Der Fahrer erhält eine Benachrichtigung mit '
                                'Status und Begründung.'
                            : 'The driver receives a notification with the '
                                'status and this explanation.',
                        style: const TextStyle(
                          color: _kMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(de ? 'Abbrechen' : 'Cancel'),
                  ),
                  FilledButton(
                    onPressed: submit,
                    style: FilledButton.styleFrom(backgroundColor: _kRed),
                    child: Text(de ? 'Ablehnen' : 'Reject'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (reason == null || reason.trim().isEmpty) return;
      await _updateAbsenceStatus(
        requestId: item.requestId,
        driverId: item.driverId,
        status: 'rejected',
        rejectionReason: reason,
        notifySource: item,
      );
    } finally {
      controller.dispose();
    }
  }

  Future<List<_DriverOption>> _loadDriverOptions() async {
    final scope = _scopeUid;
    if (scope == null) return const [];

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('drivers')
        .get();

    final items = <_DriverOption>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final transporterId = ((data['transporterId'] ?? doc.id).toString())
          .trim()
          .toUpperCase();
      if (transporterId.isEmpty) continue;
      final driverName = _AbsenceAdminItem._firstNonEmpty([
        (data['driverName'] ?? '').toString(),
        (data['name'] ?? '').toString(),
        (data['fullName'] ?? '').toString(),
        transporterId,
      ]);
      items.add(
        _DriverOption(
          driverId: transporterId,
          driverName: driverName,
          // Gleiche Quelle wie im Drivers Hub: aktive DAs sind die, die
          // laut Fahrer-Dokument arbeiten — alles andere ist Archiv.
          isActive: isDriverWorking(data),
        ),
      );
    }
    items.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return a.driverName.toLowerCase().compareTo(b.driverName.toLowerCase());
    });
    return items;
  }

  /// Setzt `paid` (bezahlt/unbezahlt) auf einem bestehenden
  /// Urlaubsantrag — Root-Dokument und Fahrer-Kopie bleiben synchron.
  ///
  /// Nur für `type == 'vacation'` relevant: bezahlter Urlaub wird dem
  /// Zeitkonto gutgeschrieben, unbezahlter nicht.
  Future<void> _updateAbsencePaid({
    required String requestId,
    required String driverId,
    required bool paid,
  }) async {
    final scope = _scopeUid;
    if (scope == null) {
      _showSnack(
        _de ? 'DSP-Zuordnung fehlt.' : 'Missing DSP scope.',
        error: true,
      );
      return;
    }

    try {
      final db = FirebaseFirestore.instance;
      final rootRef = db
          .collection('users')
          .doc(scope)
          .collection('absence_requests')
          .doc(requestId);
      final driverRef = db
          .collection('users')
          .doc(scope)
          .collection('drivers')
          .doc(driverId.toUpperCase())
          .collection('absence_requests')
          .doc(requestId);

      final payload = <String, dynamic>{
        'paid': paid,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final batch = db.batch();
      batch.set(rootRef, payload, SetOptions(merge: true));
      batch.set(driverRef, payload, SetOptions(merge: true));
      await batch.commit();
      _showSnack(
        paid
            ? (_de ? 'Als bezahlter Urlaub markiert.' : 'Marked as paid leave.')
            : (_de
                ? 'Als unbezahlter Urlaub markiert.'
                : 'Marked as unpaid leave.'),
      );
    } catch (e) {
      _showSnack(
        _de ? 'Speichern fehlgeschlagen: $e' : 'Failed to save: $e',
        error: true,
      );
    }
  }

  /// Ticket jlmRu2T — Bearbeiten: schreibt Zeitraum, bezahlt/unbezahlt
  /// und Grund auf Root-Dokument **und** Fahrer-Kopie (gleiches
  /// Batch/merge-Muster wie [_updateAbsencePaid]).
  Future<void> _updateAbsenceDetails({
    required String requestId,
    required String driverId,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
    required bool hasPaidFlag,
    required bool paid,
  }) async {
    final scope = _scopeUid;
    if (scope == null) {
      throw StateError(_de ? 'DSP-Zuordnung fehlt.' : 'Missing DSP scope.');
    }

    final db = FirebaseFirestore.instance;
    final rootRef = db
        .collection('users')
        .doc(scope)
        .collection('absence_requests')
        .doc(requestId);
    final driverRef = db
        .collection('users')
        .doc(scope)
        .collection('drivers')
        .doc(driverId.toUpperCase())
        .collection('absence_requests')
        .doc(requestId);

    final payload = <String, dynamic>{
      'fromDate': Timestamp.fromDate(_dateOnly(fromDate)),
      'toDate': Timestamp.fromDate(_dateOnly(toDate)),
      'reason': reason.trim(),
      // Nur Urlaub kennt bezahlt/unbezahlt — bei allen anderen Arten
      // bleibt das Feld bewusst unangetastet.
      if (hasPaidFlag) 'paid': paid,
      'updatedAt': FieldValue.serverTimestamp(),
      'editedBy': _uid,
      'editedAt': FieldValue.serverTimestamp(),
    };

    final batch = db.batch();
    batch.set(rootRef, payload, SetOptions(merge: true));
    batch.set(driverRef, payload, SetOptions(merge: true));
    await batch.commit();
  }

  /// Bearbeiten-Dialog: vorbefüllt mit Zeitraum, bezahlt/unbezahlt
  /// (nur Urlaub) und Grund des bestehenden Antrags.
  Future<void> _openEditAbsenceDialog(_AbsenceAdminItem item) async {
    final de = _de;
    DateTime fromDate = item.fromDate;
    DateTime toDate = item.toDate;
    bool paid = item.paid;
    final reasonCtrl = TextEditingController(text: item.reason);
    var saving = false;

    Future<void> pickDate(
      BuildContext dialogContext,
      void Function(void Function()) setLocal, {
      required bool isFrom,
    }) async {
      final now = DateTime.now();
      final lastDate = item.type == 'sick_leave'
          ? DateTime(now.year + 1, now.month, now.day)
          : DateTime(now.year + 2, now.month, now.day);
      final initialDate = isFrom ? fromDate : toDate;
      final picked = await showDatePicker(
        context: dialogContext,
        firstDate: DateTime(2020),
        lastDate: lastDate,
        initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      );
      if (picked == null) return;
      setLocal(() {
        if (isFrom) {
          fromDate = picked;
          if (toDate.isBefore(picked)) toDate = picked;
        } else {
          toDate = picked;
        }
      });
    }

    await showDialog<void>(
      context: context,
      // Hinweis: `barrierDismissible` wird von showDialog nur EINMAL
      // beim Öffnen ausgewertet und kann `saving` daher gar nicht
      // berücksichtigen — der Ausdruck war irreführend. Wegtippen
      // während des Speicherns ist unkritisch: der Batch-Write läuft
      // durch und Bestätigung/Refresh hängen am Messenger der Seite,
      // nicht am Dialog.
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocal) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F5EE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.edit_calendar_outlined,
                              color: _kGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  de
                                      ? 'Abwesenheit bearbeiten'
                                      : 'Edit leave',
                                  style: const TextStyle(
                                    color: _kText,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.driverName} · ${item.typeLabel(de)}',
                                  style: const TextStyle(
                                    color: _kMuted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (item.hasPaidFlag) ...[
                        _PaidLeaveSelector(
                          paid: paid,
                          enabled: !saving,
                          onChanged: (value) => setLocal(() => paid = value),
                        ),
                        const SizedBox(height: 14),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: saving
                                  ? null
                                  : () => pickDate(
                                        dialogContext,
                                        setLocal,
                                        isFrom: true,
                                      ),
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(
                                DateFormat('dd.MM.yyyy').format(fromDate),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: saving
                                  ? null
                                  : () => pickDate(
                                        dialogContext,
                                        setLocal,
                                        isFrom: false,
                                      ),
                              icon: const Icon(Icons.event_outlined),
                              label: Text(
                                DateFormat('dd.MM.yyyy').format(toDate),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: reasonCtrl,
                        enabled: !saving,
                        decoration: InputDecoration(
                          labelText: de ? 'Grund' : 'Reason',
                          hintText: de ? 'Optionale Notiz' : 'Optional note',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          TextButton(
                            onPressed: saving
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            child: Text(de ? 'Abbrechen' : 'Cancel'),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: saving
                                ? null
                                : () async {
                                    if (toDate.isBefore(fromDate)) {
                                      _showSnack(
                                        de
                                            ? 'Enddatum darf nicht vor dem Startdatum liegen.'
                                            : 'End date cannot be before start date.',
                                        error: true,
                                      );
                                      return;
                                    }
                                    setLocal(() => saving = true);
                                    try {
                                      await _updateAbsenceDetails(
                                        requestId: item.requestId,
                                        driverId: item.driverId,
                                        fromDate: fromDate,
                                        toDate: toDate,
                                        reason: reasonCtrl.text,
                                        hasPaidFlag: item.hasPaidFlag,
                                        paid: paid,
                                      );
                                      if (dialogContext.mounted) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                      _showSnack(
                                        de
                                            ? 'Abwesenheit aktualisiert.'
                                            : 'Leave updated.',
                                      );
                                      _refreshRanking();
                                    } catch (e) {
                                      if (dialogContext.mounted) {
                                        setLocal(() => saving = false);
                                      }
                                      _showSnack(
                                        de
                                            ? 'Speichern fehlgeschlagen: $e'
                                            : 'Failed to save: $e',
                                        error: true,
                                      );
                                    }
                                  },
                            icon: saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              saving
                                  ? (de ? 'Speichern...' : 'Saving...')
                                  : (de ? 'Speichern' : 'Save'),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: _kGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    reasonCtrl.dispose();
  }

  /// Ticket jlmRu2T — Stornieren: setzt den Status auf `cancelled`.
  /// Bewusst KEIN Löschen, damit die Historie nachvollziehbar bleibt;
  /// stornierte Einträge zählen nirgends mehr mit (überall wird auf
  /// `approved` gefiltert).
  Future<void> _confirmCancelAbsence(_AbsenceAdminItem item) async {
    final de = _de;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          de ? 'Abwesenheit stornieren?' : 'Cancel leave?',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          de
              ? '${item.driverName} · ${item.typeLabel(de)}\n'
                  '${item.fromDateText} – ${item.toDateText} · ${item.daysLabel(de)}\n\n'
                  'Der Eintrag bleibt in der Historie sichtbar, zählt aber '
                  'nicht mehr als genehmigte Abwesenheit.'
              : '${item.driverName} · ${item.typeLabel(de)}\n'
                  '${item.fromDateText} – ${item.toDateText} · ${item.daysLabel(de)}\n\n'
                  'The entry stays visible in the history but no longer '
                  'counts as approved leave.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(de ? 'Zurück' : 'Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _kRed),
            child: Text(de ? 'Stornieren' : 'Cancel leave'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _updateAbsenceStatus(
      requestId: item.requestId,
      driverId: item.driverId,
      status: 'cancelled',
    );
  }

  /// Ticket „History löschen" — einzelne Historien-Einträge entfernen.
  ///
  /// Bewusst SOFT-DELETE statt `delete()`, weil die Einträge
  /// abrechnungsrelevant sind:
  ///  * `computeMonthlyAccount` liest
  ///    `drivers/{id}/absence_requests` mit
  ///    `where('status','==','approved')` und schreibt daraus
  ///    Urlaubs-/Kranktage ins Zeitkonto. Ein reines `deleted`-Flag
  ///    würde die Function NICHT erreichen — der gelöschte Eintrag
  ///    zählte im Überstundenkonto stillschweigend weiter.
  ///  * `onAbsenceUpdated` steigt bei einem echten Löschen sofort aus
  ///    (`if (!after) return; // gelöscht — nichts zu tun`). Ein
  ///    Hard-Delete würde also KEINE Neuberechnung auslösen und das
  ///    `time_account` des Monats veraltet zurücklassen.
  ///
  /// Deshalb: genehmigte Einträge werden zusätzlich auf `cancelled`
  /// gesetzt. Das läuft in den bestehenden Trigger-Pfad
  /// (`statusChanged && oldStatus == 'approved'`) und rechnet alle
  /// betroffenen Monate sauber zurück — ohne eine Zeile in den
  /// Functions oder den Rules zu ändern. Das `deleted`-Flag blendet den
  /// Eintrag danach nur noch in der UI aus; die Historie bleibt für
  /// Audit/DSGVO-Export vollständig.
  Future<void> _confirmDeleteAbsence(_AbsenceAdminItem item) async {
    final de = _de;
    final wasApproved = item.status == 'approved';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          de ? 'Eintrag löschen?' : 'Delete entry?',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          de
              ? '${item.driverName} · ${item.typeLabel(de)}\n'
                  '${item.fromDateText} – ${item.toDateText} · ${item.daysLabel(de)}\n\n'
                  'Der Eintrag verschwindet aus der Historie.'
                  '${wasApproved ? ' Das Zeitkonto des betroffenen Monats wird automatisch neu berechnet.' : ''}'
              : '${item.driverName} · ${item.typeLabel(de)}\n'
                  '${item.fromDateText} – ${item.toDateText} · ${item.daysLabel(de)}\n\n'
                  'The entry disappears from the history.'
                  '${wasApproved ? ' The time account of the affected month is recalculated automatically.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _kRed),
            child: Text(de ? 'Löschen' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _softDeleteAbsence(item);
  }

  Future<void> _softDeleteAbsence(_AbsenceAdminItem item) async {
    final scope = _scopeUid;
    if (scope == null) {
      _showSnack(
        _de ? 'DSP-Zuordnung fehlt.' : 'Missing DSP scope.',
        error: true,
      );
      return;
    }

    try {
      final db = FirebaseFirestore.instance;
      final rootRef = db
          .collection('users')
          .doc(scope)
          .collection('absence_requests')
          .doc(item.requestId);
      final driverRef = db
          .collection('users')
          .doc(scope)
          .collection('drivers')
          .doc(item.driverId.toUpperCase())
          .collection('absence_requests')
          .doc(item.requestId);

      final payload = <String, dynamic>{
        'deleted': true,
        'deletedBy': _uid,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Nur `approved` zählt irgendwo mit (App-Aggregationen wie auch
        // `computeMonthlyAccount`). Genehmigte Einträge müssen deshalb
        // aus diesem Status heraus — das stößt zugleich den Recompute
        // an. `rejected`/`cancelled` bleiben unangetastet, damit die
        // ursprüngliche Entscheidung im Audit erhalten bleibt.
        if (item.status == 'approved') ...{
          'status': 'cancelled',
          'cancelledBy': _uid,
          'cancelledAt': FieldValue.serverTimestamp(),
        },
      };

      final batch = db.batch();
      batch.set(rootRef, payload, SetOptions(merge: true));
      batch.set(driverRef, payload, SetOptions(merge: true));
      await batch.commit();

      _showSnack(_de ? 'Eintrag gelöscht.' : 'Entry deleted.');
      _refreshRanking();
    } catch (e) {
      _showSnack(
        _de
            ? 'Eintrag konnte nicht gelöscht werden: $e'
            : 'Failed to delete entry: $e',
        error: true,
      );
    }
  }

  Future<void> _addManualPastLeave({
    required _DriverOption driver,
    required String type,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
    required bool paid,
  }) async {
    final scope = _scopeUid;
    if (scope == null) {
      _showSnack(
        _de ? 'DSP-Zuordnung fehlt.' : 'Missing DSP scope.',
        error: true,
      );
      return;
    }

    final db = FirebaseFirestore.instance;
    final rootRef = db
        .collection('users')
        .doc(scope)
        .collection('absence_requests')
        .doc();
    final requestId = rootRef.id;
    final driverRef = db
        .collection('users')
        .doc(scope)
        .collection('drivers')
        .doc(driver.driverId)
        .collection('absence_requests')
        .doc(requestId);

    final now = FieldValue.serverTimestamp();
    final payload = <String, dynamic>{
      'requestId': requestId,
      'dspUid': scope,
      'driverUid': '',
      'driverTransporterId': driver.driverId,
      'driverName': driver.driverName,
      'type': type,
      // Nur beim Urlaub relevant: bezahlt (Default) wird dem Zeitkonto
      // gutgeschrieben, unbezahlt nicht. Andere Abwesenheitsarten
      // bekommen bewusst kein `paid`-Feld.
      if (type == 'vacation') 'paid': paid,
      'fromDate': Timestamp.fromDate(_dateOnly(fromDate)),
      'toDate': Timestamp.fromDate(_dateOnly(toDate)),
      'reason': reason.trim(),
      'status': 'approved',
      'submittedAt': now,
      'updatedAt': now,
      'reviewedAt': now,
      'reviewedBy': _uid,
      'source': 'admin_manual',
    };

    final batch = db.batch();
    batch.set(rootRef, payload, SetOptions(merge: true));
    batch.set(driverRef, payload, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> _openAddPastLeaveDialog() async {
    final driverOptions = await _loadDriverOptions();
    if (!mounted) return;
    final de = _de;
    if (driverOptions.isEmpty) {
      _showSnack(
        de ? 'Noch keine Fahrer verfügbar.' : 'No drivers available yet.',
        error: true,
      );
      return;
    }

    final activeDrivers =
        driverOptions.where((d) => d.isActive).toList(growable: false);
    final archivedDrivers =
        driverOptions.where((d) => !d.isActive).toList(growable: false);
    _DriverOption? selectedDriver =
        activeDrivers.isNotEmpty ? activeDrivers.first : driverOptions.first;
    String type = widget.requestType ?? 'vacation';
    // Ticket: Urlaub kann bezahlt oder unbezahlt erfasst werden.
    // Default = bezahlt (wie bisher alle Bestandsdatensätze).
    bool paid = true;
    DateTime? fromDate;
    DateTime? toDate;
    final reasonCtrl = TextEditingController();
    var saving = false;

    Future<void> pickDate(
      BuildContext dialogContext,
      void Function(void Function()) setLocal, {
      required bool isFrom,
    }) async {
      final initialDate = isFrom
          ? (fromDate ?? DateTime.now())
          : (toDate ?? fromDate ?? DateTime.now());
      // Tickets "Not able to select sick leave / PTO dates in the future":
      // auch zukünftige Zeiträume erfassbar — Krankmeldungen bis +1 Jahr,
      // Urlaub/Sonderurlaub (wird im Voraus geplant) bis +2 Jahre.
      final now = DateTime.now();
      final lastDate = type == 'sick_leave'
          ? DateTime(now.year + 1, now.month, now.day)
          : DateTime(now.year + 2, now.month, now.day);
      final picked = await showDatePicker(
        context: dialogContext,
        firstDate: DateTime(2020),
        lastDate: lastDate,
        initialDate:
            initialDate.isAfter(lastDate) ? lastDate : initialDate,
      );
      if (picked == null) return;
      setLocal(() {
        if (isFrom) {
          fromDate = picked;
          if (toDate != null && toDate!.isBefore(picked)) {
            toDate = picked;
          }
        } else {
          toDate = picked;
        }
      });
    }

    await showDialog<void>(
      context: context,
      // Hinweis: `barrierDismissible` wird von showDialog nur EINMAL
      // beim Öffnen ausgewertet und kann `saving` daher gar nicht
      // berücksichtigen — der Ausdruck war irreführend. Wegtippen
      // während des Speicherns ist unkritisch: der Batch-Write läuft
      // durch und Bestätigung/Refresh hängen am Messenger der Seite,
      // nicht am Dialog.
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocal) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F5EE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.event_available_outlined,
                              color: _kGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  de
                                      ? 'Abwesenheit erfassen'
                                      : 'Record leave',
                                  style: const TextStyle(
                                    color: _kText,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  de
                                      ? 'Urlaub oder Abwesenheit manuell erfassen — vergangene wie zukünftige Zeiträume.'
                                      : 'Record vacation or leave manually — past as well as future dates.',
                                  style: const TextStyle(
                                    color: _kMuted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<_DriverOption>(
                        initialValue: selectedDriver,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: de ? 'Fahrer' : 'Driver',
                          helperText: de
                              ? 'Aufgeteilt in aktive und archivierte DAs (Drivers Hub).'
                              : 'Split into active and archived DAs (Drivers Hub).',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        selectedItemBuilder: (context) => [
                          for (final entry in _driverPickerEntries(
                            de: de,
                            active: activeDrivers,
                            archived: archivedDrivers,
                          ))
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                entry.option == null
                                    ? ''
                                    : '${entry.option!.driverName} '
                                        '(${entry.option!.driverId})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        items: [
                          for (final entry in _driverPickerEntries(
                            de: de,
                            active: activeDrivers,
                            archived: archivedDrivers,
                          ))
                            if (entry.option == null)
                              DropdownMenuItem<_DriverOption>(
                                enabled: false,
                                child: Text(
                                  entry.header!,
                                  style: const TextStyle(
                                    color: _kMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              )
                            else
                              DropdownMenuItem<_DriverOption>(
                                value: entry.option,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${entry.option!.driverName} '
                                        '(${entry.option!.driverId})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (!entry.option!.isActive) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.archive_outlined,
                                        size: 15,
                                        color: _kMuted.withValues(alpha: 0.9),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                        ],
                        onChanged: saving
                            ? null
                            : (value) => setLocal(() => selectedDriver = value),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: type,
                        decoration: InputDecoration(
                          labelText: de ? 'Art' : 'Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'vacation',
                            child: Text(de ? 'Urlaub' : 'Vacation'),
                          ),
                          DropdownMenuItem(
                            value: 'sick_leave',
                            child: Text(de ? 'Krankheit' : 'Sick leave'),
                          ),
                          DropdownMenuItem(
                            value: 'special_leave',
                            child: Text(de ? 'Sonderurlaub' : 'Special leave'),
                          ),
                        ],
                        onChanged: saving
                            ? null
                            : (value) {
                                if (value == null) return;
                                setLocal(() {
                                  type = value;
                                  // Nur Urlaub kennt bezahlt/unbezahlt —
                                  // beim Wechsel zurück auf den Default.
                                  if (value != 'vacation') paid = true;
                                });
                              },
                      ),
                      if (type == 'vacation') ...[
                        const SizedBox(height: 14),
                        _PaidLeaveSelector(
                          paid: paid,
                          enabled: !saving,
                          onChanged: (value) => setLocal(() => paid = value),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: saving
                                  ? null
                                  : () => pickDate(
                                        dialogContext,
                                        setLocal,
                                        isFrom: true,
                                      ),
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(
                                fromDate == null
                                    ? (de ? 'Von' : 'From')
                                    : DateFormat('dd.MM.yyyy').format(fromDate!),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: saving
                                  ? null
                                  : () => pickDate(
                                        dialogContext,
                                        setLocal,
                                        isFrom: false,
                                      ),
                              icon: const Icon(Icons.event_outlined),
                              label: Text(
                                toDate == null
                                    ? (de ? 'Bis' : 'To')
                                    : DateFormat('dd.MM.yyyy').format(toDate!),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: reasonCtrl,
                        enabled: !saving,
                        decoration: InputDecoration(
                          labelText: de ? 'Grund' : 'Reason',
                          hintText: de ? 'Optionale Notiz' : 'Optional note',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          TextButton(
                            onPressed: saving
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            child: Text(de ? 'Abbrechen' : 'Cancel'),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: saving
                                ? null
                                : () async {
                                    if (selectedDriver == null) {
                                      _showSnack(
                                        de
                                            ? 'Bitte einen Fahrer auswählen.'
                                            : 'Please choose a driver.',
                                        error: true,
                                      );
                                      return;
                                    }
                                    if (fromDate == null || toDate == null) {
                                      _showSnack(
                                        de
                                            ? 'Bitte beide Daten auswählen.'
                                            : 'Please select both dates.',
                                        error: true,
                                      );
                                      return;
                                    }
                                    if (toDate!.isBefore(fromDate!)) {
                                      _showSnack(
                                        de
                                            ? 'Enddatum darf nicht vor dem Startdatum liegen.'
                                            : 'End date cannot be before start date.',
                                        error: true,
                                      );
                                      return;
                                    }
                                    setLocal(() => saving = true);
                                    try {
                                      await _addManualPastLeave(
                                        driver: selectedDriver!,
                                        type: type,
                                        fromDate: fromDate!,
                                        toDate: toDate!,
                                        reason: reasonCtrl.text,
                                        paid: paid,
                                      );
                                      // Dialog kann während des Speicherns
                                      // weggetippt worden sein — der
                                      // Schreibvorgang lief trotzdem durch,
                                      // also müssen Bestätigung und
                                      // Ranking-Refresh in jedem Fall
                                      // kommen (der Snackbar hängt am
                                      // Messenger der Seite, nicht am
                                      // Dialog).
                                      if (dialogContext.mounted) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                      _showSnack(
                                        de
                                            ? 'Abwesenheit erfolgreich gespeichert.'
                                            : 'Leave saved successfully.',
                                      );
                                      _refreshRanking();
                                    } catch (e) {
                                      if (dialogContext.mounted) {
                                        setLocal(() => saving = false);
                                      }
                                      _showSnack(
                                        de
                                            ? 'Speichern fehlgeschlagen: $e'
                                            : 'Failed to save leave: $e',
                                        error: true,
                                      );
                                    }
                                  },
                            icon: saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.add_circle_outline),
                            label: Text(
                              saving
                                  ? (de ? 'Speichern...' : 'Saving...')
                                  : (de ? 'Nachtragen' : 'Add leave'),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: _kGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    reasonCtrl.dispose();
  }

  /// Öffnet den CSV-Massenimport für Krankheitstage.
  /// Namens-Matching läuft ausschließlich gegen **aktive** DAs
  /// (`isDriverWorking`) — archivierte Fahrer tauchen nicht auf.
  Future<void> _openSickLeaveCsvImportDialog() async {
    final driverOptions = await _loadDriverOptions();
    if (!mounted) return;
    final de = _de;
    final activeDrivers =
        driverOptions.where((d) => d.isActive).toList(growable: false);
    if (activeDrivers.isEmpty) {
      _showSnack(
        de ? 'Keine aktiven Fahrer verfügbar.' : 'No active drivers available.',
        error: true,
      );
      return;
    }

    final result = await showDialog<_SickCsvImportResult>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _SickLeaveCsvImportDialog(
        activeDrivers: activeDrivers,
        onImport: _importSickLeaveCsvRows,
      ),
    );
    if (!mounted || result == null) return;
    _showSnack(result.summary(de));
    _refreshRanking();
  }

  /// Schreibt die (bereits zugeordneten) CSV-Zeilen als Krankmeldungen —
  /// exakt im Schema der manuellen Erfassung (Root-Dokument +
  /// Fahrer-Kopie im selben Batch), nur mit `source: 'csv_import'`.
  Future<_SickCsvImportResult> _importSickLeaveCsvRows(
    List<_SickCsvRow> rows,
  ) async {
    final scope = _scopeUid;
    if (scope == null) {
      throw StateError(_de ? 'DSP-Zuordnung fehlt.' : 'Missing DSP scope.');
    }

    final db = FirebaseFirestore.instance;
    // Pro Fahrer einmal die bestehenden Krankmeldungen laden — der
    // Schlüssel ist fromDate+toDate (tagesgenau), damit Wiederholungs-
    // Importe derselben Datei nichts doppelt anlegen.
    final existingKeys = <String, Set<String>>{};
    var imported = 0;
    var duplicates = 0;
    var skipped = 0;

    var batch = db.batch();
    var pendingOps = 0;

    Future<void> flush() async {
      if (pendingOps == 0) return;
      await batch.commit();
      batch = db.batch();
      pendingOps = 0;
    }

    for (final row in rows) {
      final driver = row.driver;
      if (!row.isValid || driver == null) {
        skipped++;
        continue;
      }

      final driverKey = driver.driverId;
      var keys = existingKeys[driverKey];
      if (keys == null) {
        keys = <String>{};
        final snap = await db
            .collection('users')
            .doc(scope)
            .collection('drivers')
            .doc(driverKey)
            .collection('absence_requests')
            .get();
        for (final doc in snap.docs) {
          final data = doc.data();
          if ((data['type'] ?? '').toString().toLowerCase() != 'sick_leave') {
            continue;
          }
          final from = _AbsenceAdminItem._toDate(data['fromDate']);
          final to = _AbsenceAdminItem._toDate(data['toDate']);
          if (from == null || to == null) continue;
          keys.add(_sickRangeKey(from, to));
        }
        existingKeys[driverKey] = keys;
      }

      final rangeKey = _sickRangeKey(row.fromDate!, row.toDate!);
      if (keys.contains(rangeKey)) {
        duplicates++;
        skipped++;
        continue;
      }

      final rootRef = db
          .collection('users')
          .doc(scope)
          .collection('absence_requests')
          .doc();
      final requestId = rootRef.id;
      final driverRef = db
          .collection('users')
          .doc(scope)
          .collection('drivers')
          .doc(driverKey)
          .collection('absence_requests')
          .doc(requestId);

      final now = FieldValue.serverTimestamp();
      final payload = <String, dynamic>{
        'requestId': requestId,
        'dspUid': scope,
        'driverUid': '',
        'driverTransporterId': driverKey,
        'driverName': driver.driverName,
        'type': 'sick_leave',
        'fromDate': Timestamp.fromDate(_dateOnly(row.fromDate!)),
        'toDate': Timestamp.fromDate(_dateOnly(row.toDate!)),
        'reason': '',
        'status': 'approved',
        'submittedAt': now,
        'updatedAt': now,
        'reviewedAt': now,
        'reviewedBy': _uid,
        'source': 'csv_import',
      };

      batch.set(rootRef, payload, SetOptions(merge: true));
      batch.set(driverRef, payload, SetOptions(merge: true));
      pendingOps += 2;
      keys.add(rangeKey);
      imported++;

      // Firestore erlaubt 500 Writes pro Batch — mit Puffer flushen.
      if (pendingOps >= 400) {
        await flush();
      }
    }

    await flush();

    return _SickCsvImportResult(
      imported: imported,
      skipped: skipped,
      duplicates: duplicates,
    );
  }

  static String _sickRangeKey(DateTime from, DateTime to) {
    String d(DateTime value) =>
        '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
    return '${d(from)}_${d(to)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return Center(
        child: Text(
          _de
              ? 'Du musst als Admin angemeldet sein.'
              : 'You must be logged in as admin.',
        ),
      );
    }
    if (_loadingScope) {
      return const Center(child: CircularProgressIndicator());
    }

    final absencesCol = _rootAbsencesCol;
    if (absencesCol == null) {
      return Center(
        child: Text(_de ? 'DSP-Zuordnung fehlt.' : 'Missing DSP scope.'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1080;
        final isNarrow = constraints.maxWidth < 700;
        final horizontalPadding = isNarrow ? 12.0 : (isCompact ? 14.0 : 24.0);
        // Schmale oder niedrige Fenster scrollen komplett — so kann
        // nichts überlaufen. Breite Fenster behalten die Historie als
        // fixen Hauptbereich, der den restlichen Platz füllt.
        final useScrollLayout = isCompact || constraints.maxHeight < 820;

        return Container(
          color: _kPageBg,
          padding: EdgeInsets.all(horizontalPadding),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: absencesCol
                .orderBy('submittedAt', descending: true)
                .limit(300)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text(
                    _de
                        ? 'Abwesenheitsanträge konnten nicht geladen werden: ${snap.error}'
                        : 'Failed to load absence requests: ${snap.error}',
                  ),
                );
              }

              final buckets = _splitAbsenceBuckets(
                docs: snap.data?.docs ?? const [],
                requestType: widget.requestType,
                search: _search,
                de: _de,
                historySort: _historySort,
              );
              final pending = buckets.pending;
              final approvedUpcoming = buckets.upcoming;
              final history = buckets.history;

              final previewPending =
                  _buildPreviewSection(_AbsenceBucket.pending, pending);
              final previewUpcoming =
                  _buildPreviewSection(_AbsenceBucket.upcoming, approvedUpcoming);

              final previewBlock = isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        previewPending,
                        const SizedBox(height: 14),
                        previewUpcoming,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: previewPending),
                        const SizedBox(width: 16),
                        Expanded(child: previewUpcoming),
                      ],
                    );

              final head = <Widget>[
                _buildHeader(isCompact: isCompact, isNarrow: isNarrow),
                const SizedBox(height: 18),
                _buildStatsRow(
                  isCompact: isCompact,
                  isNarrow: isNarrow,
                  pendingCount: pending.length,
                  approvedUpcomingCount: approvedUpcoming.length,
                  historyCount: history.length,
                ),
                const SizedBox(height: 18),
                if (widget.requestType == 'sick_leave') ...[
                  _buildSickRanking(isNarrow: isNarrow),
                  const SizedBox(height: 18),
                ],
                _buildSearchBar(),
                const SizedBox(height: 18),
              ];

              if (useScrollLayout) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ...head,
                    previewBlock,
                    const SizedBox(height: 16),
                    _buildHistorySection(history, embedded: true),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...head,
                  previewBlock,
                  const SizedBox(height: 16),
                  // Historie = Hauptbereich: bekommt den kompletten
                  // restlichen Platz der Seite.
                  Expanded(
                    child: _buildHistorySection(history, embedded: false),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Summiert alle genehmigten Krankmeldungen je AKTIVEM Fahrer und
  /// setzt sie in Relation zur Beschäftigungsdauer (alle Zeiträume aus
  /// dem Drivers Hub, gedeckelt auf heute).
  Future<List<_SickRankEntry>> _loadSickRanking() async {
    final scope = _scopeUid;
    if (scope == null) return const [];
    final db = FirebaseFirestore.instance;

    final driversSnap =
        await db.collection('users').doc(scope).collection('drivers').get();
    final absSnap = await db
        .collection('users')
        .doc(scope)
        .collection('absence_requests')
        .where('type', isEqualTo: 'sick_leave')
        .get();

    final daysByDriver = <String, int>{};
    for (final doc in absSnap.docs) {
      final d = doc.data();
      if ((d['status'] ?? '').toString().toLowerCase() != 'approved') continue;
      final id = ((d['driverTransporterId'] ?? d['driverId'] ?? '')
              .toString())
          .trim()
          .toUpperCase();
      final from = (d['fromDate'] as Timestamp?)?.toDate();
      final to = (d['toDate'] as Timestamp?)?.toDate();
      if (id.isEmpty || from == null || to == null) continue;
      final f = DateTime.utc(from.year, from.month, from.day);
      final t = DateTime.utc(to.year, to.month, to.day);
      final days = t.difference(f).inDays + 1;
      if (days > 0) daysByDriver[id] = (daysByDriver[id] ?? 0) + days;
    }

    final now = DateTime.now();
    final out = <_SickRankEntry>[];
    for (final doc in driversSnap.docs) {
      final data = doc.data();
      // Nur aktive Fahrer — gleiche Quelle wie im Drivers Hub.
      if (!isDriverWorking(data)) continue;
      final tid =
          ((data['transporterId'] ?? doc.id).toString()).trim().toUpperCase();
      final total = daysByDriver[tid] ?? 0;
      if (total <= 0) continue;

      var employedDays = 0;
      for (final p in employmentPeriodsOf(data)) {
        final s = p.startDate;
        if (s == null) continue;
        var e = p.endDate ?? now;
        if (e.isAfter(now)) e = now;
        final su = DateTime.utc(s.year, s.month, s.day);
        final eu = DateTime.utc(e.year, e.month, e.day);
        final d = eu.difference(su).inDays + 1;
        if (d > 0) employedDays += d;
      }

      out.add(_SickRankEntry(
        driverId: tid,
        name: _AbsenceAdminItem._firstNonEmpty([
          (data['driverName'] ?? '').toString(),
          (data['name'] ?? '').toString(),
          (data['fullName'] ?? '').toString(),
          tid,
        ]),
        totalDays: total,
        employedDays: employedDays,
      ));
    }
    return out;
  }

  /// Ranking-Karte: Toggle „Gesamt" vs. „% der Beschäftigungszeit",
  /// absteigend sortiert, Top 8 mit Aufklappen.
  Widget _buildSickRanking({required bool isNarrow}) {
    final de = _de;
    _rankingFuture ??= _loadSickRanking();

    Widget segButton(String label, bool selected, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? _kGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : _kMuted,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: FutureBuilder<List<_SickRankEntry>>(
        future: _rankingFuture,
        builder: (context, snap) {
          final entries = [...(snap.data ?? const <_SickRankEntry>[])];
          if (_rankingByPercent) {
            entries.sort((a, b) =>
                (b.percent ?? -1).compareTo(a.percent ?? -1));
          } else {
            entries.sort((a, b) => b.totalDays.compareTo(a.totalDays));
          }
          final shown =
              _rankingExpanded ? entries : entries.take(8).toList();
          final maxTotal = entries.isEmpty
              ? 1
              : entries
                  .map((e) => e.totalDays)
                  .reduce((a, b) => a > b ? a : b);
          final maxPct = entries
              .map((e) => e.percent ?? 0)
              .fold<double>(0, (a, b) => a > b ? a : b);

          String pctLabel(_SickRankEntry e) {
            final p = e.percent;
            if (p == null) return '—';
            final s = p.toStringAsFixed(1);
            return '${de ? s.replaceAll('.', ',') : s} %';
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.leaderboard_outlined,
                      size: 18, color: _kRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      de ? 'Kranktage-Ranking' : 'Sick days ranking',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _kText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        segButton(de ? 'Gesamt' : 'Total',
                            !_rankingByPercent,
                            () => setState(() => _rankingByPercent = false)),
                        segButton(
                            de ? '% Beschäftigung' : '% of tenure',
                            _rankingByPercent,
                            () => setState(() => _rankingByPercent = true)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                de
                    ? 'Genehmigte Krankheitstage aktiver Fahrer — gesamt '
                        'oder anteilig an der Beschäftigungsdauer.'
                    : 'Approved sick days of active drivers — total or '
                        'relative to time employed.',
                style: const TextStyle(fontSize: 12, color: _kMuted),
              ),
              const SizedBox(height: 10),
              if (snap.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                )
              else if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    de
                        ? 'Noch keine genehmigten Krankmeldungen.'
                        : 'No approved sick leave yet.',
                    style: const TextStyle(fontSize: 13, color: _kMuted),
                  ),
                )
              else ...[
                // Aufgeklappt bekommen die Zeilen eine EIGENE, in der
                // Hoehe gedeckelte Scrollflaeche. Vorher wuchs die Karte
                // mit ~90 Zeilen ueber den Bildschirm hinaus — im breiten
                // Layout sitzt sie in einer nicht scrollenden Column, die
                // Historie darunter wurde auf null gequetscht und die
                // Seite wirkte eingefroren.
                if (_rankingExpanded)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 380),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: shown.length,
                        itemBuilder: (context, i) =>
                            _sickRankRow(shown, i, maxTotal, maxPct,
                                pctLabel, isNarrow, de),
                      ),
                    ),
                  )
                else
                for (var i = 0; i < shown.length; i++)
                  _sickRankRow(
                      shown, i, maxTotal, maxPct, pctLabel, isNarrow, de),
                if (entries.length > 8)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(
                          () => _rankingExpanded = !_rankingExpanded),
                      child: Text(
                        _rankingExpanded
                            ? (de ? 'Weniger anzeigen' : 'Show less')
                            : (de
                                ? 'Alle anzeigen (${entries.length})'
                                : 'Show all (${entries.length})'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Eine Zeile des Kranktage-Rankings — von der Inline-Schleife und
  /// der aufgeklappten Scroll-Liste gemeinsam genutzt.
  Widget _sickRankRow(
    List<_SickRankEntry> shown,
    int i,
    int maxTotal,
    double maxPct,
    String Function(_SickRankEntry) pctLabel,
    bool isNarrow,
    bool de,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '${i + 1}.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: i < 3 ? _kRed : _kMuted,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shown[i].name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _rankingByPercent
                        ? (maxPct <= 0
                            ? 0
                            : (shown[i].percent ?? 0) / maxPct)
                        : shown[i].totalDays / maxTotal,
                    minHeight: 4,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_kRed),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _rankingByPercent
                ? pctLabel(shown[i])
                : (de
                    ? '${shown[i].totalDays} Tage'
                    : '${shown[i].totalDays} days'),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: _kText,
            ),
          ),
          if (!isNarrow) ...[
            const SizedBox(width: 8),
            Text(
              _rankingByPercent
                  ? (de
                      ? '\u00b7 ${shown[i].totalDays} Tage'
                      : '\u00b7 ${shown[i].totalDays} days')
                  : '\u00b7 ${pctLabel(shown[i])}',
              style: const TextStyle(fontSize: 12, color: _kMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader({required bool isCompact, required bool isNarrow}) {
    final de = _de;
    final isSick = widget.requestType == 'sick_leave';
    final isVacation = widget.requestType == 'vacation';
    final title = isSick
        ? (de ? 'Krankmeldungen' : 'Sick Leave')
        : isVacation
            ? (de ? 'Urlaubsanträge' : 'Vacation Requests')
            : (de ? 'Abwesenheits-Verwaltung' : 'Absence Management');
    final subtitle = isSick
        ? (de
            ? 'Krankmeldungen prüfen — Pflicht-AU pro Fahrer einsehen, freigeben oder ablehnen.'
            : 'Review sick leave — view the required sick note per driver, approve or reject.')
        : isVacation
            ? (de
                ? 'Urlaubsanträge prüfen, kommende Genehmigungen im Blick behalten, Historie pflegen.'
                : 'Review vacation requests, keep upcoming approvals in view, and maintain the history.')
            : (de
                ? 'Offene Urlaubsanträge prüfen, kommende genehmigte Abwesenheiten im Blick behalten und eine klare Entscheidungs-Historie pflegen.'
                : 'Review pending vacation requests, monitor upcoming approved leave, and keep a clear decision history.');
    final tileColor = isSick
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFE7F5EE);
    final tileIcon = isSick
        ? Icons.medical_services_outlined
        : Icons.event_busy_outlined;
    final tileIconColor = isSick ? const Color(0xFFB91C1C) : _kGreen;

    final titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isNarrow ? 44 : 52,
          height: isNarrow ? 44 : 52,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            tileIcon,
            color: tileIconColor,
            size: isNarrow ? 22 : 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _kText,
                  fontSize: isNarrow ? 20 : (isCompact ? 22 : 28),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: _kMuted,
                  fontSize: isNarrow ? 13 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final action = FilledButton.icon(
      onPressed: _openAddPastLeaveDialog,
      icon: const Icon(Icons.add_circle_outline),
      label: Text(
        isSick
            ? (de ? 'Krankmeldung erfassen' : 'Record sick leave')
            : (de ? 'Urlaub erfassen' : 'Record vacation'),
        overflow: TextOverflow.ellipsis,
      ),
    );

    // Nur im Krankmeldungs-Bereich: runder "+"-Button für den
    // CSV-Massenimport von Krankheitstagen.
    final csvAction = isSick
        ? Tooltip(
            message: de
                ? 'Krankheitstage per CSV importieren'
                : 'Import sick days via CSV',
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(
                side: BorderSide(color: _kBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _openSickLeaveCsvImportDialog,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.add_rounded, color: _kGreen, size: 26),
                ),
              ),
            ),
          )
        : null;

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 12),
          // Aktionen rechtsbündig — wie in der breiten Ansicht.
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(child: action),
              if (csvAction != null) ...[
                const SizedBox(width: 10),
                csvAction,
              ],
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 12),
        Flexible(child: action),
        if (csvAction != null) ...[
          const SizedBox(width: 10),
          csvAction,
        ],
      ],
    );
  }

  Widget _buildStatsRow({
    required bool isCompact,
    required bool isNarrow,
    required int pendingCount,
    required int approvedUpcomingCount,
    required int historyCount,
  }) {
    final de = _de;
    // Zwischen 700 und 1080 px nebeneinander, aber ohne Bildunterzeile —
    // spart Höhe, ohne umzubrechen.
    final dense = isCompact && !isNarrow;
    final children = [
      _StatCard(
        dense: dense,
        title: de ? 'Offene Prüfung' : 'Pending review',
        value: '$pendingCount',
        caption: de
            ? 'Anträge, die auf eine Entscheidung warten'
            : 'Requests waiting for decision',
        accent: _kOrange,
        icon: Icons.pending_actions_rounded,
      ),
      _StatCard(
        dense: dense,
        title: de ? 'Genehmigt (bevorstehend)' : 'Approved upcoming',
        value: '$approvedUpcomingCount',
        caption: de
            ? 'Bevorstehende oder laufende genehmigte Abwesenheit'
            : 'Upcoming or active approved leave',
        accent: _kGreen,
        icon: Icons.event_available_rounded,
      ),
      _StatCard(
        dense: dense,
        title: de ? 'Historie' : 'History',
        value: '$historyCount',
        caption: de
            ? 'Geprüfte oder abgeschlossene Anträge'
            : 'Reviewed or completed requests',
        accent: const Color(0xFF475569),
        icon: Icons.history_rounded,
      ),
    ];

    if (isNarrow) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i < children.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return _AbsenceSearchField(
      controller: _searchCtrl,
      focusNode: _searchFocusNode,
      onChanged: (value) {
        if (_search == value) return;
        setState(() => _search = value);
      },
    );
  }

  /// Kompakte Vorschau für "Offene Anträge" bzw. "Bevorstehende
  /// Abwesenheit": maximal [_kPreviewLimit] Einträge, der Rest liegt
  /// hinter "Mehr anzeigen" in einer eigenen Vollbild-Ansicht.
  Widget _buildPreviewSection(
    _AbsenceBucket bucket,
    List<_AbsenceAdminItem> items,
  ) {
    final de = _de;
    final isPending = bucket == _AbsenceBucket.pending;
    final visible = items.take(_kPreviewLimit).toList();
    final hidden = items.length - visible.length;

    return _SectionCard(
      dense: true,
      title: _bucketTitle(bucket, de),
      subtitle: isPending
          ? (de
              ? 'Neue Fahrer-Anträge genehmigen oder ablehnen.'
              : 'Approve or reject new driver requests.')
          : (de
              ? 'Bereits genehmigter Urlaub oder Krankheit in der Zukunft.'
              : 'Already approved vacation or sick leave ahead.'),
      icon: isPending
          ? Icons.pending_actions_rounded
          : Icons.event_available_rounded,
      countLabel: '${items.length}',
      countAccent: isPending ? _kOrange : _kGreen,
      // Ticket b9roqxo: „Mehr anzeigen" gibt es jetzt in JEDER Sektion —
      // auch wenn nichts gekürzt wurde, damit das Popup mit allen
      // Einträgen (und allen Aktionen) immer erreichbar ist.
      footer: items.isEmpty
          ? null
          : _ShowMoreButton(
              label: hidden > 0
                  ? (de
                      ? 'Mehr anzeigen ($hidden weitere)'
                      : 'Show more ($hidden more)')
                  : (de
                      ? 'Mehr anzeigen (${items.length})'
                      : 'Show more (${items.length})'),
              onTap: () => _openAllRequests(bucket),
            ),
      child: items.isEmpty
          ? _CompactEmptyState(
              title: isPending
                  ? (de ? 'Keine offenen Anträge' : 'No pending requests')
                  : (de
                      ? 'Keine bevorstehende Abwesenheit'
                      : 'No upcoming approved leave'),
            )
          : Column(
              children: [
                for (var i = 0; i < visible.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _CompactAbsenceTile(
                    item: visible[i],
                    onApprove: isPending ? _approveOf(visible[i]) : null,
                    onReject: isPending ? _rejectOf(visible[i]) : null,
                    // Wer hier genehmigen kann, muss auch bezahlt/
                    // unbezahlt entscheiden können — sonst wäre die
                    // Auswahl bei ≤ 3 offenen Anträgen unerreichbar.
                    onSetPaid: isPending ? _setPaidOf(visible[i]) : null,
                    // Ticket jlmRu2T: Bearbeiten/Stornieren für
                    // bevorstehende Abwesenheiten.
                    onEdit: isPending ? null : _editOf(visible[i]),
                    onCancel: isPending ? null : _cancelOf(visible[i]),
                  ),
                ],
              ],
            ),
    );
  }

  /// Sortier-Auswahl der Historie — bewusst ein schlankes Dropdown im
  /// Stil der übrigen Filter dieser Seite (Ticket „TIME & ABSENCE -
  /// HISTORY").
  Widget _buildHistorySortSelector(bool de) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Auf schmalen Karten entfällt das Präfix „Sortierung:" — sonst
        // bräuchte die längste Option mehr Platz, als die Zeile hat.
        final compact = constraints.maxWidth < 420;
        return Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _kBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<_HistorySort>(
                  value: _historySort,
                  isDense: true,
                  borderRadius: BorderRadius.circular(16),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: _kMuted,
                  ),
                  style: const TextStyle(
                    color: _kText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                  selectedItemBuilder: (context) => [
                    for (final sort in _HistorySort.values)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.swap_vert_rounded,
                            size: 16,
                            color: _kMuted,
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              compact
                                  ? _historySortLabel(sort, de)
                                  : '${de ? 'Sortierung' : 'Sort'}: '
                                      '${_historySortLabel(sort, de)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _kText,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                  items: [
                    for (final sort in _HistorySort.values)
                      DropdownMenuItem<_HistorySort>(
                        value: sort,
                        child: Text(
                          _historySortLabel(sort, de),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null || value == _historySort) return;
                    setState(() => _historySort = value);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Hauptbereich der Seite. [embedded] = im Seiten-Scroll eingebettet
  /// (schmale Fenster), sonst füllt die Karte den Restplatz.
  Widget _buildHistorySection(
    List<_AbsenceAdminItem> items, {
    required bool embedded,
  }) {
    final de = _de;
    // Ticket „History Show more": standardmäßig nur die jüngsten
    // [_kPreviewLimit] Einträge; der Rest klappt in der Karte selbst auf.
    final visible = _historyExpanded
        ? items
        : items.take(_kPreviewLimit).toList(growable: false);
    final hidden = items.length - visible.length;
    final canExpand = items.length > _kPreviewLimit;

    return _SectionCard(
      emphasized: true,
      title: de ? 'Historie' : 'History',
      subtitle: de
          ? 'Vergangene genehmigte Abwesenheiten und abgelehnte Anträge — der komplette Verlauf.'
          : 'Past approved leave and rejected requests — the complete record.',
      icon: Icons.history_rounded,
      countLabel: '${items.length}',
      countAccent: const Color(0xFF475569),
      // Ticket „TIME & ABSENCE - HISTORY": Sortierung direkt unter der
      // Kopfzeile — sie gilt für die Karte UND das „Alle anzeigen"-Popup.
      headerExtra: _buildHistorySortSelector(de),
      footer: items.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canExpand)
                  _ExpandToggleButton(
                    expanded: _historyExpanded,
                    label: _historyExpanded
                        ? (de ? 'Weniger anzeigen' : 'Show less')
                        : (de
                            ? 'Mehr anzeigen (+$hidden)'
                            : 'Show more (+$hidden)'),
                    onTap: () => setState(
                      () => _historyExpanded = !_historyExpanded,
                    ),
                  ),
                // Ticket b9roqxo: das Popup mit ALLEN Einträgen (eigene
                // Suche, deutlich größeres Ladelimit) bleibt erhalten —
                // eindeutig beschriftet, damit es sich nicht mit dem
                // Aufklappen oben beißt.
                _ShowMoreButton(
                  label: de
                      ? 'Alle anzeigen & suchen (${items.length})'
                      : 'Show all & search (${items.length})',
                  onTap: () => _openAllRequests(_AbsenceBucket.history),
                ),
              ],
            ),
      child: items.isEmpty
          ? _EmptyState(
              title: de ? 'Noch keine Historie' : 'No history yet',
              subtitle: de
                  ? 'Geprüfte Anträge erscheinen hier im Laufe der Zeit.'
                  : 'Reviewed requests will appear here over time.',
            )
          : ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: embedded,
              physics: embedded
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              itemCount: visible.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _HistoryAbsenceTile(
                  item: visible[index],
                  onEdit: _editOf(visible[index]),
                  onCancel: _cancelOf(visible[index]),
                  onDelete: _deleteOf(visible[index]),
                );
              },
            ),
    );
  }

  VoidCallback? _approveOf(_AbsenceAdminItem item) => item.driverId.isEmpty
      ? null
      : () => _updateAbsenceStatus(
            requestId: item.requestId,
            driverId: item.driverId,
            status: 'approved',
            // Genehmigungen werden dem Fahrer ebenfalls gemeldet — er
            // soll nicht nur bei einem Nein etwas hören.
            notifySource: item,
          );

  /// Ablehnen läuft immer über den Dialog mit Pflicht-Begründung.
  VoidCallback? _rejectOf(_AbsenceAdminItem item) =>
      item.driverId.isEmpty ? null : () => _confirmRejectAbsence(item);

  /// Bezahlt/unbezahlt lässt sich nur an Urlaubsanträgen mit bekanntem
  /// Fahrer umstellen (die Fahrer-Kopie braucht die Transporter-ID).
  ValueChanged<bool>? _setPaidOf(_AbsenceAdminItem item) =>
      item.driverId.isEmpty || !item.hasPaidFlag
          ? null
          : (value) => _updateAbsencePaid(
                requestId: item.requestId,
                driverId: item.driverId,
                paid: value,
              );

  /// Ticket jlmRu2T: Bearbeiten/Stornieren setzt einen bekannten Fahrer
  /// voraus (die Fahrer-Kopie braucht die Transporter-ID).
  ///
  /// Abgelehnte Anträge bekommen gar kein Menü — an einem `rejected`
  /// gibt es nichts zu bearbeiten und nichts zu stornieren. Bereits
  /// stornierte Einträge sind ebenfalls unveränderlich; damit entfällt
  /// auch ein zweites Storno auf demselben Eintrag.
  bool _isLocked(_AbsenceAdminItem item) =>
      item.driverId.isEmpty ||
      item.status == 'rejected' ||
      item.status == 'cancelled';

  VoidCallback? _editOf(_AbsenceAdminItem item) =>
      _isLocked(item) ? null : () => _openEditAbsenceDialog(item);

  VoidCallback? _cancelOf(_AbsenceAdminItem item) =>
      _isLocked(item) ? null : () => _confirmCancelAbsence(item);

  /// Löschen ist bewusst NICHT an [_isLocked] gekoppelt: gerade
  /// abgelehnte und stornierte Einträge sind die, die der Admin aus der
  /// Historie räumen will. Einzige Voraussetzung ist eine bekannte
  /// Fahrer-ID — ohne sie ist die Fahrer-Kopie nicht adressierbar und
  /// die Function-Seite bliebe auf dem alten Stand.
  VoidCallback? _deleteOf(_AbsenceAdminItem item) => item.driverId.isEmpty
      ? null
      : () => _confirmDeleteAbsence(item);

  String _bucketTitle(_AbsenceBucket bucket, bool de) {
    switch (bucket) {
      case _AbsenceBucket.pending:
        return de ? 'Offene Anträge' : 'Pending Requests';
      case _AbsenceBucket.upcoming:
        return de ? 'Bevorstehende Abwesenheit' : 'Upcoming Leave';
      case _AbsenceBucket.history:
        return de ? 'Historie' : 'History';
    }
  }

  /// Eigene Vollbild-Ansicht mit ALLEN Einträgen des Bereichs
  /// (keine Kürzung), inkl. eigener Suche und — bei offenen Anträgen —
  /// Genehmigen/Ablehnen direkt aus der Liste.
  Future<void> _openAllRequests(_AbsenceBucket bucket) async {
    final col = _rootAbsencesCol;
    if (col == null) return;
    final de = _de;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 20,
          ),
          clipBehavior: Clip.antiAlias,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: _AbsenceAllRequestsView(
            collection: col,
            requestType: widget.requestType,
            bucket: bucket,
            title: _bucketTitle(bucket, de),
            initialSearch: _search,
            historySort: _historySort,
            onApproveOf: _approveOf,
            onRejectOf: _rejectOf,
            onSetPaidOf: _setPaidOf,
            onEditOf: _editOf,
            onCancelOf: _cancelOf,
            onDeleteOf: _deleteOf,
          ),
        );
      },
    );
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: error ? _kRed : null),
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  /// Kompakte Variante (Vorschau-Bereiche): kleinerer Header,
  /// weniger Innenabstand — nimmt spürbar weniger Platz ein.
  final bool dense;

  /// Hauptbereich (Historie): kräftigerer Rahmen/Schatten.
  final bool emphasized;

  /// Optionaler Zähler-Chip rechts im Header.
  final String? countLabel;
  final Color? countAccent;

  /// Optionale Fußzeile (z. B. "Mehr anzeigen").
  final Widget? footer;

  /// Optionale Zeile direkt unter der Kopfzeile (z. B. die Sortier-
  /// Auswahl der Historie).
  final Widget? headerExtra;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.dense = false,
    this.emphasized = false,
    this.countLabel,
    this.countAccent,
    this.footer,
    this.headerExtra,
  });

  @override
  Widget build(BuildContext context) {
    final accent = countAccent ?? const Color(0xFF475569);
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: dense ? 34 : 40,
                  height: dense ? 34 : 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(dense ? 12 : 14),
                  ),
                  child: Icon(
                    icon,
                    size: dense ? 17 : 20,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(width: dense ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF111827),
                          fontSize: dense ? 15 : (emphasized ? 20 : 18),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF6B7280),
                          fontSize: dense ? 12 : 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (countLabel != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      countLabel!,
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (headerExtra != null) ...[
              SizedBox(height: dense ? 10 : 12),
              headerExtra!,
            ],
            SizedBox(height: dense ? 12 : 16),
            if (constraints.maxHeight.isFinite)
              Expanded(child: child)
            else
              child,
            if (footer != null) ...[
              const SizedBox(height: 10),
              footer!,
            ],
          ],
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(dense ? 20 : 24),
            border: Border.all(
              color: emphasized
                  ? const Color(0xFFD5DBE4)
                  : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: emphasized ? 0.06 : 0.04,
                ),
                blurRadius: emphasized ? 18 : 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(dense ? 14 : 18),
          child: content,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String caption;
  final Color accent;
  final IconData icon;
  final bool dense;

  const _StatCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.accent,
    required this.icon,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(dense ? 13 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: dense ? 40 : 46,
            height: dense ? 40 : 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: dense ? 20 : 24),
          ),
          SizedBox(width: dense ? 11 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: dense ? 12 : 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: const Color(0xFF111827),
                    fontSize: dense ? 22 : 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (!dense) ...[
                  const SizedBox(height: 4),
                  Text(
                    caption,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingAbsenceCard extends StatelessWidget {
  final _AbsenceAdminItem item;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  /// Setzt bezahlt/unbezahlt auf einem Urlaubsantrag. `null` = nicht
  /// änderbar (dann wird nur die Kennzeichnung angezeigt).
  final ValueChanged<bool>? onSetPaid;

  const _PendingAbsenceCard({
    required this.item,
    required this.onApprove,
    required this.onReject,
    this.onSetPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.driverName,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${item.driverId.isEmpty ? '-' : item.driverId}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: item.status),
            ],
          ),
          const SizedBox(height: 14),
          Builder(builder: (context) {
            final de = Localizations.localeOf(context).languageCode == 'de';
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetaPill(
                  icon: Icons.category_outlined,
                  text: item.typeLabel(de),
                ),
                _MetaPill(
                  icon: Icons.calendar_today_outlined,
                  text: '${item.fromDateText} - ${item.toDateText}',
                ),
                _MetaPill(
                  icon: Icons.timelapse_rounded,
                  text: item.daysLabel(de),
                ),
                _MetaPill(
                  icon: Icons.schedule_send_outlined,
                  text: de
                      ? 'Eingereicht ${item.submittedAtText}'
                      : 'Submitted ${item.submittedAtText}',
                ),
                if (item.hasPaidFlag && onSetPaid == null)
                  _PaidPill(paid: item.paid),
                if (item.type == 'sick_leave') _AuPill(item: item),
              ],
            );
          }),
          if (item.hasPaidFlag && onSetPaid != null) ...[
            const SizedBox(height: 14),
            _PaidLeaveSelector(paid: item.paid, onChanged: onSetPaid!),
          ],
          if (item.reason.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                item.reason,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close_rounded),
                  label: Text(
                    Localizations.localeOf(context).languageCode == 'de'
                        ? 'Ablehnen'
                        : 'Reject',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB91C1C),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    Localizations.localeOf(context).languageCode == 'de'
                        ? 'Genehmigen'
                        : 'Approve',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1D7F5A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryAbsenceTile extends StatelessWidget {
  final _AbsenceAdminItem item;

  /// Ticket jlmRu2T: Kontext-Menü (⋮) mit Bearbeiten/Stornieren.
  /// `null` = Aktion nicht verfügbar (z. B. bereits storniert).
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  /// Ticket „History löschen": Papierkorb direkt an der Zeile —
  /// bewusst sichtbar statt im ⋮-Menü, weil abgelehnte/stornierte
  /// Einträge gar kein Menü bekommen (dort sind Bearbeiten und
  /// Stornieren gesperrt), genau sie aber weggeräumt werden sollen.
  final VoidCallback? onDelete;

  const _HistoryAbsenceTile({
    required this.item,
    this.onEdit,
    this.onCancel,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.driverName,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusChip(status: item.status),
              if (onEdit != null || onCancel != null)
                _AbsenceActionsMenu(onEdit: onEdit, onCancel: onCancel),
              if (onDelete != null)
                Builder(
                  builder: (context) {
                    final de =
                        Localizations.localeOf(context).languageCode == 'de';
                    return IconButton(
                      tooltip: de ? 'Eintrag löschen' : 'Delete entry',
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      splashRadius: 18,
                      constraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Color(0xFFB91C1C),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Builder(builder: (context) {
            final de = Localizations.localeOf(context).languageCode == 'de';
            final paidSuffix =
                item.hasPaidFlag ? ' | ${item.paidLabel(de)}' : '';
            return Text(
              '${item.typeLabel(de)} | ${item.fromDateText} - '
              '${item.toDateText} | ${item.daysLabel(de)}$paidSuffix',
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            );
          }),
          if (item.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          // Ticket „TIME & ABSENCE - HISTORY": Ablehngrund direkt am
          // Eintrag — sonst wäre nach der Entscheidung nirgends mehr
          // nachvollziehbar, warum abgelehnt wurde.
          if (item.rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Builder(builder: (context) {
              final de =
                  Localizations.localeOf(context).languageCode == 'de';
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      de ? 'Grund der Ablehnung' : 'Reason for rejection',
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.rejectionReason,
                      style: const TextStyle(
                        color: Color(0xFF7F1D1D),
                        fontSize: 12.5,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 8),
          Text(
            item.reviewLine(
              Localizations.localeOf(context).languageCode == 'de',
            ),
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Auswahl „Bezahlt / Unbezahlt" für Urlaub. Bezahlter Urlaub wird dem
/// Überstundenkonto mit den Soll-Stunden des Tages gutgeschrieben,
/// unbezahlter nicht (das Konto sinkt entsprechend).
class _PaidLeaveSelector extends StatelessWidget {
  const _PaidLeaveSelector({
    required this.paid,
    required this.onChanged,
    this.enabled = true,
    this.compact = false,
  });

  final bool paid;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  /// Platzsparende Variante für die Vorschau-Zeilen: ohne Überschrift
  /// und Erklärtext, niedrigere Chips.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(
            de ? 'Vergütung' : 'Payment',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Row(
          children: [
            Expanded(
              child: _PaidChoiceChip(
                label: de ? 'Bezahlt' : 'Paid',
                icon: Icons.payments_outlined,
                selected: paid,
                enabled: enabled,
                compact: compact,
                onTap: () => onChanged(true),
              ),
            ),
            SizedBox(width: compact ? 8 : 10),
            Expanded(
              child: _PaidChoiceChip(
                label: de ? 'Unbezahlt' : 'Unpaid',
                icon: Icons.money_off_csred_outlined,
                selected: !paid,
                enabled: enabled,
                compact: compact,
                // Unbezahlt ist der Ausnahmefall — orange wie die
                // Kennzeichnung in den Listen (_PaidPill).
                selectedForeground: const Color(0xFF9A3412),
                selectedBackground: const Color(0xFFFFEDD5),
                selectedBorder: const Color(0xFFC2410C),
                onTap: () => onChanged(false),
              ),
            ),
          ],
        ),
        if (!compact) ...[
          const SizedBox(height: 6),
          Text(
            paid
                ? (de
                    ? 'Bezahlt: Soll-Stunden des Tages werden dem Zeitkonto gutgeschrieben (Monatsplan: U).'
                    : 'Paid: the day\'s target hours are credited to the time account (monthly plan: U).')
                : (de
                    ? 'Unbezahlt: keine Gutschrift — das Überstundenkonto sinkt um die Soll-Stunden (Monatsplan: X).'
                    : 'Unpaid: no credit — the overtime account drops by the target hours (monthly plan: X).'),
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _PaidChoiceChip extends StatelessWidget {
  const _PaidChoiceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.compact = false,
    this.selectedForeground = const Color(0xFF0F5132),
    this.selectedBackground = const Color(0xFFE4F5EC),
    this.selectedBorder = const Color(0xFF1D7F5A),
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final bool compact;
  final Color selectedForeground;
  final Color selectedBackground;
  final Color selectedBorder;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? selectedForeground : const Color(0xFF475569);
    return Material(
      color: selected ? selectedBackground : Colors.white,
      borderRadius: BorderRadius.circular(compact ? 11 : 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 11 : 14),
        onTap: enabled ? onTap : null,
        child: Container(
          height: compact ? 34 : 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 11 : 14),
            border: Border.all(
              color: selected ? selectedBorder : const Color(0xFFE5E7EB),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 15 : 17, color: fg),
              SizedBox(width: compact ? 6 : 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: compact ? 12 : 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kennzeichnung „Bezahlt / Unbezahlt" in den Listen.
class _PaidPill extends StatelessWidget {
  const _PaidPill({required this.paid});

  final bool paid;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final fg = paid ? const Color(0xFF0F5132) : const Color(0xFF9A3412);
    final bg = paid ? const Color(0xFFE4F5EC) : const Color(0xFFFFEDD5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            paid ? Icons.payments_outlined : Icons.money_off_csred_outlined,
            size: 15,
            color: fg,
          ),
          const SizedBox(width: 8),
          Text(
            paid
                ? (de ? 'Bezahlt (U)' : 'Paid (U)')
                : (de ? 'Unbezahlt (X)' : 'Unpaid (X)'),
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    late final Color fg;
    late final Color bg;
    late final String label;

    switch (status) {
      case 'approved':
        fg = const Color(0xFF1D7F5A);
        bg = const Color(0xFFE4F5EC);
        label = de ? 'GENEHMIGT' : 'APPROVED';
        break;
      case 'rejected':
        fg = const Color(0xFFB91C1C);
        bg = const Color(0xFFFEE2E2);
        label = de ? 'ABGELEHNT' : 'REJECTED';
        break;
      // Ticket jlmRu2T: storniert = neutral grau, klar unterscheidbar
      // von „abgelehnt" (rot).
      case 'cancelled':
        fg = const Color(0xFF64748B);
        bg = const Color(0xFFE2E8F0);
        label = de ? 'STORNIERT' : 'CANCELLED';
        break;
      default:
        fg = const Color(0xFF9A3412);
        bg = const Color(0xFFFFEDD5);
        label = de ? 'OFFEN' : 'PENDING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                color: Color(0xFF94A3B8),
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Schmale Variante von [_EmptyState] für die Vorschau-Karten.
class _CompactEmptyState extends StatelessWidget {
  final String title;

  const _CompactEmptyState({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 18,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Mehr anzeigen" / "Show more" — öffnet die Vollansicht.
class _ShowMoreButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ShowMoreButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.open_in_full_rounded, size: 16),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF1D7F5A),
          padding: const EdgeInsets.symmetric(vertical: 10),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

/// „Mehr anzeigen" / „Weniger anzeigen" — klappt eine Liste an Ort und
/// Stelle auf bzw. wieder zu (im Gegensatz zu [_ShowMoreButton], der ein
/// Popup öffnet).
class _ExpandToggleButton extends StatelessWidget {
  final String label;
  final bool expanded;
  final VoidCallback onTap;

  const _ExpandToggleButton({
    required this.label,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(
          expanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          size: 18,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF1D7F5A),
          padding: const EdgeInsets.symmetric(vertical: 10),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

/// Platzsparende Zeile für die Vorschau-Bereiche.
class _CompactAbsenceTile extends StatelessWidget {
  final _AbsenceAdminItem item;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  /// Bezahlt/unbezahlt direkt aus der Vorschau umschaltbar. Ohne diesen
  /// Callback bleibt die Zeile reine Anzeige.
  final ValueChanged<bool>? onSetPaid;

  /// Ticket jlmRu2T: Kontext-Menü (⋮) mit Bearbeiten/Stornieren —
  /// nur für bevorstehende (bereits genehmigte) Abwesenheiten.
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  const _CompactAbsenceTile({
    required this.item,
    this.onApprove,
    this.onReject,
    this.onSetPaid,
    this.onEdit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final isPending = onApprove != null || onReject != null;
    // Der Antrag kann hier genehmigt werden — also muss hier auch
    // entschieden werden können, ob der Urlaub bezahlt ist.
    final showPaidToggle = onSetPaid != null && item.hasPaidFlag;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.driverName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.typeLabel(de)} · ${item.fromDateText} – '
                      '${item.toDateText} · ${item.daysLabel(de)}'
                      '${item.hasPaidFlag && !item.paid ? ' · ${item.paidLabel(de)}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (item.type == 'sick_leave') ...[
                Tooltip(
                  message: item.hasAuFile
                      ? (de ? 'AU vorhanden' : 'Sick note uploaded')
                      : (de ? 'AU fehlt' : 'Sick note missing'),
                  child: Icon(
                    item.hasAuFile
                        ? Icons.medical_services_rounded
                        : Icons.warning_amber_rounded,
                    size: 17,
                    color: item.hasAuFile
                        ? const Color(0xFF166534)
                        : const Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (isPending) ...[
                _MiniActionButton(
                  icon: Icons.close_rounded,
                  color: const Color(0xFFB91C1C),
                  background: const Color(0xFFFEE2E2),
                  tooltip: de ? 'Ablehnen' : 'Reject',
                  onPressed: onReject,
                ),
                const SizedBox(width: 8),
                _MiniActionButton(
                  icon: Icons.check_rounded,
                  color: Colors.white,
                  background: const Color(0xFF1D7F5A),
                  tooltip: de ? 'Genehmigen' : 'Approve',
                  onPressed: onApprove,
                ),
              ] else ...[
                _StatusChip(status: item.status),
                if (onEdit != null || onCancel != null)
                  _AbsenceActionsMenu(onEdit: onEdit, onCancel: onCancel),
              ],
            ],
          ),
          if (showPaidToggle) ...[
            const SizedBox(height: 10),
            _PaidLeaveSelector(
              paid: item.paid,
              onChanged: onSetPaid!,
              compact: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String tooltip;
  final VoidCallback? onPressed;

  const _MiniActionButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: onPressed == null
            ? background.withValues(alpha: 0.4)
            : background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

/// Ticket jlmRu2T — Kontext-Menü (⋮) an Einträgen in „Bevorstehend"
/// und „Historie": Bearbeiten und Stornieren.
class _AbsenceActionsMenu extends StatelessWidget {
  const _AbsenceActionsMenu({required this.onEdit, required this.onCancel});

  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return PopupMenuButton<String>(
      tooltip: de ? 'Aktionen' : 'Actions',
      icon: const Icon(
        Icons.more_vert_rounded,
        size: 18,
        color: Color(0xFF64748B),
      ),
      padding: EdgeInsets.zero,
      splashRadius: 18,
      constraints: const BoxConstraints(minWidth: 180),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit?.call();
        } else if (value == 'cancel') {
          onCancel?.call();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'edit',
          enabled: onEdit != null,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 18),
              const SizedBox(width: 10),
              Text(de ? 'Bearbeiten' : 'Edit'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'cancel',
          enabled: onCancel != null,
          child: Row(
            children: [
              const Icon(
                Icons.cancel_outlined,
                size: 18,
                color: Color(0xFFB91C1C),
              ),
              const SizedBox(width: 10),
              Text(
                de ? 'Stornieren' : 'Cancel',
                style: const TextStyle(color: Color(0xFFB91C1C)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Obergrenze des „Alle Einträge"-Popups. Bewusst weit über dem
/// Vorschau-Limit der Seite (300), damit das Popup seinem Versprechen
/// gerecht wird — aber nicht unbegrenzt, weil an der Collection ein
/// Live-Stream hängt.
const int _kAllRequestsLimit = 2000;

/// Hinweiszeile, wenn [_kAllRequestsLimit] tatsächlich erreicht wurde.
class _ListLimitNotice extends StatelessWidget {
  const _ListLimitNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFF9A3412),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF9A3412),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vollbild-Ansicht mit ALLEN Einträgen eines Bereichs. Hängt am
/// selben Firestore-Stream wie die Seite, damit Genehmigen/Ablehnen
/// sofort sichtbar wird. Es wird bewusst nicht gekürzt.
class _AbsenceAllRequestsView extends StatefulWidget {
  const _AbsenceAllRequestsView({
    required this.collection,
    required this.requestType,
    required this.bucket,
    required this.title,
    required this.initialSearch,
    required this.historySort,
    required this.onApproveOf,
    required this.onRejectOf,
    required this.onSetPaidOf,
    required this.onEditOf,
    required this.onCancelOf,
    required this.onDeleteOf,
  });

  final CollectionReference<Map<String, dynamic>> collection;
  final String? requestType;
  final _AbsenceBucket bucket;
  final String title;
  final String initialSearch;

  /// Sortierung der Historie — kommt aus der Seite, damit das Popup
  /// dieselbe Reihenfolge zeigt wie die Karte darunter.
  final _HistorySort historySort;
  final VoidCallback? Function(_AbsenceAdminItem) onApproveOf;
  final VoidCallback? Function(_AbsenceAdminItem) onRejectOf;
  final ValueChanged<bool>? Function(_AbsenceAdminItem) onSetPaidOf;
  final VoidCallback? Function(_AbsenceAdminItem) onEditOf;
  final VoidCallback? Function(_AbsenceAdminItem) onCancelOf;
  final VoidCallback? Function(_AbsenceAdminItem) onDeleteOf;

  @override
  State<_AbsenceAllRequestsView> createState() =>
      _AbsenceAllRequestsViewState();
}

class _AbsenceAllRequestsViewState extends State<_AbsenceAllRequestsView> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initialSearch);
  final FocusNode _focus = FocusNode();
  late String _search = widget.initialSearch;

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final media = MediaQuery.sizeOf(context);
    // Ticket b9roqxo: Popup bewusst schmal (max ~640 px) — die Liste
    // scrollt intern, damit der Dialog nie über den Bildschirm läuft.
    final width = math.max(280.0, math.min(640.0, media.width - 48));
    final height = math.max(300.0, media.height * 0.86);
    final isPending = widget.bucket == _AbsenceBucket.pending;
    final isHistory = widget.bucket == _AbsenceBucket.history;

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 12, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isPending
                        ? Icons.pending_actions_rounded
                        : isHistory
                            ? Icons.history_rounded
                            : Icons.event_available_rounded,
                    size: 20,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        de
                            ? 'Alle Einträge dieses Bereichs.'
                            : 'Every entry in this section.',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: de ? 'Schließen' : 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: _AbsenceSearchField(
              controller: _ctrl,
              focusNode: _focus,
              onChanged: (value) {
                if (_search == value) return;
                setState(() => _search = value);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              // Das Popup verspricht ALLE Einträge — die Seiten-Vorschau
              // liest bewusst nur die letzten 300, hier wird deutlich
              // weiter aufgemacht. Ein hartes Limit bleibt als Schutz vor
              // einem unbegrenzten Live-Stream stehen; wird es erreicht,
              // sagt eine Hinweiszeile das offen.
              stream: widget.collection
                  .orderBy('submittedAt', descending: true)
                  .limit(_kAllRequestsLimit)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data?.docs ?? const [];
                final items = _splitAbsenceBuckets(
                  docs: docs,
                  requestType: widget.requestType,
                  search: _search,
                  de: de,
                  historySort: widget.historySort,
                ).of(widget.bucket);

                if (items.isEmpty) {
                  return _EmptyState(
                    title: de ? 'Keine Einträge' : 'No entries',
                    subtitle: de
                        ? 'Für diese Suche gibt es hier nichts.'
                        : 'Nothing matches this search here.',
                  );
                }

                final limitReached = docs.length >= _kAllRequestsLimit;

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  itemCount: items.length + (limitReached ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return _ListLimitNotice(
                        text: de
                            ? 'Nur die neuesten $_kAllRequestsLimit Anträge '
                                'werden geladen — ältere Einträge fehlen in '
                                'dieser Liste.'
                            : 'Only the most recent $_kAllRequestsLimit '
                                'requests are loaded — older entries are '
                                'missing from this list.',
                      );
                    }
                    final item = items[index];
                    if (!isPending) {
                      return _HistoryAbsenceTile(
                        item: item,
                        onEdit: widget.onEditOf(item),
                        onCancel: widget.onCancelOf(item),
                        // Löschen nur in der Historie — Bevorstehendes
                        // wird storniert, nicht weggeräumt.
                        onDelete:
                            isHistory ? widget.onDeleteOf(item) : null,
                      );
                    }
                    return _PendingAbsenceCard(
                      item: item,
                      onApprove: widget.onApproveOf(item),
                      onReject: widget.onRejectOf(item),
                      onSetPaid: widget.onSetPaidOf(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _AbsenceBucket { pending, upcoming, history }

/// Ticket „TIME & ABSENCE - HISTORY": Sortier-Optionen der Historie.
///
///  * [addedAt]         — Erfassungs-/Prüfzeitpunkt (`historySortDate`,
///                        also die Bestandskette cancelledAt → reviewedAt
///                        → submittedAt). Das ist die Vorbelegung und
///                        entspricht exakt dem bisherigen Verhalten.
///  * [occurrence]      — Datum des Vorgangs (`fromDate`).
///  * [driverFirstName] — Vorname des Fahrers, A–Z.
enum _HistorySort { addedAt, occurrence, driverFirstName }

String _historySortLabel(_HistorySort sort, bool de) {
  switch (sort) {
    case _HistorySort.addedAt:
      return de ? 'Erfasst am (neu → alt)' : 'Added (new → old)';
    case _HistorySort.occurrence:
      return de
          ? 'Datum des Vorgangs (neu → alt)'
          : 'Date of occurrence (new → old)';
    case _HistorySort.driverFirstName:
      return de ? 'Fahrer-Vorname (A–Z)' : 'Driver first name (A–Z)';
  }
}

/// Vorname für die A–Z-Sortierung.
///
/// Bestandsdaten kommen in beiden Schreibweisen vor: „Vorname Nachname"
/// und — vor allem aus CSV-Importen — „Nachname, Vorname". Steht ein
/// Komma im Namen, ist der Vorname der Teil DAHINTER, sonst das erste
/// Wort.
String _driverFirstNameKey(String driverName) {
  final name = driverName.trim();
  if (name.isEmpty) return '';
  final commaIndex = name.indexOf(',');
  final relevant =
      commaIndex >= 0 ? name.substring(commaIndex + 1).trim() : name;
  final parts = relevant.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return (parts.isEmpty ? relevant : parts.first).toLowerCase();
}

/// Vergleicher für die gewählte Historien-Sortierung. Bei Gleichstand
/// fällt jede Variante auf den Erfassungszeitpunkt zurück, damit die
/// Reihenfolge stabil bleibt.
int _compareHistory(_AbsenceAdminItem a, _AbsenceAdminItem b,
    _HistorySort sort) {
  switch (sort) {
    case _HistorySort.addedAt:
      return b.historySortDate.compareTo(a.historySortDate);
    case _HistorySort.occurrence:
      final byDate = b.fromDate.compareTo(a.fromDate);
      if (byDate != 0) return byDate;
      return b.historySortDate.compareTo(a.historySortDate);
    case _HistorySort.driverFirstName:
      final byName = _driverFirstNameKey(a.driverName)
          .compareTo(_driverFirstNameKey(b.driverName));
      if (byName != 0) return byName;
      return b.historySortDate.compareTo(a.historySortDate);
  }
}

class _AbsenceBuckets {
  final List<_AbsenceAdminItem> pending;
  final List<_AbsenceAdminItem> upcoming;
  final List<_AbsenceAdminItem> history;

  const _AbsenceBuckets({
    required this.pending,
    required this.upcoming,
    required this.history,
  });

  List<_AbsenceAdminItem> of(_AbsenceBucket bucket) {
    switch (bucket) {
      case _AbsenceBucket.pending:
        return pending;
      case _AbsenceBucket.upcoming:
        return upcoming;
      case _AbsenceBucket.history:
        return history;
    }
  }
}

/// Einheitliche Aufteilung der Anträge — wird sowohl von der Seite
/// als auch von der "Mehr anzeigen"-Vollansicht genutzt.
_AbsenceBuckets _splitAbsenceBuckets({
  required Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  required String? requestType,
  required String search,
  required bool de,
  _HistorySort historySort = _HistorySort.addedAt,
}) {
  final needle = search.trim().toLowerCase();
  final items = docs
      .map(_AbsenceAdminItem.fromDoc)
      // Soft-gelöschte Einträge sind für den Admin nicht mehr da —
      // eine Stelle für Seite UND „Alle Einträge"-Popup.
      .where((it) => !it.deleted)
      .where((it) => requestType == null || it.type == requestType)
      .where((it) => _matchesAbsenceSearch(it, needle, de))
      .toList();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final pending = items.where((item) => item.status == 'pending').toList()
    ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  // Ticket „TIME & ABSENCE - HISTORY": In „Bevorstehend" gehören
  // ausschließlich GENEHMIGTE Abwesenheiten. Abgelehnte (und stornierte,
  // Ticket jlmRu2T) Anträge sind hier explizit ausgeschlossen — sie
  // bleiben nur in der Historie sichtbar.
  final upcoming = items
      .where((item) =>
          item.status == 'approved' &&
          item.status != 'rejected' &&
          item.status != 'cancelled' &&
          !item.toDate.isBefore(today))
      .toList()
    ..sort((a, b) => a.fromDate.compareTo(b.fromDate));
  // Ticket jlmRu2T: stornierte Einträge verschwinden aus „Bevorstehend"
  // (dort zählt nur `approved`) und landen dauerhaft in der Historie.
  final history = items
      .where((item) =>
          item.status == 'rejected' ||
          item.status == 'cancelled' ||
          (item.status == 'approved' && item.toDate.isBefore(today)))
      .toList()
    ..sort((a, b) => _compareHistory(a, b, historySort));

  return _AbsenceBuckets(
    pending: pending,
    upcoming: upcoming,
    history: history,
  );
}

bool _matchesAbsenceSearch(_AbsenceAdminItem item, String needle, bool de) {
  if (needle.isEmpty) return true;
  return item.driverName.toLowerCase().contains(needle) ||
      item.driverId.toLowerCase().contains(needle) ||
      item.reason.toLowerCase().contains(needle) ||
      item.typeLabel(de).toLowerCase().contains(needle);
}

/// Eintrag der Fahrer-Auswahl: entweder eine Gruppen-Überschrift
/// (aktive / archivierte DAs) oder ein auswählbarer Fahrer.
class _DriverPickerEntry {
  final String? header;
  final _DriverOption? option;

  const _DriverPickerEntry.header(this.header) : option = null;
  const _DriverPickerEntry.driver(this.option) : header = null;
}

/// Baut die zweigeteilte Auswahlliste: aktive DAs zuerst, danach das
/// Archiv — die Einstufung stammt aus den Drivers-Hub-Daten.
List<_DriverPickerEntry> _driverPickerEntries({
  required bool de,
  required List<_DriverOption> active,
  required List<_DriverOption> archived,
}) {
  final entries = <_DriverPickerEntry>[];
  if (active.isNotEmpty) {
    entries.add(
      _DriverPickerEntry.header(
        de
            ? 'AKTIVE DAs (${active.length})'
            : 'ACTIVE DAs (${active.length})',
      ),
    );
    entries.addAll(active.map(_DriverPickerEntry.driver));
  }
  if (archived.isNotEmpty) {
    entries.add(
      _DriverPickerEntry.header(
        de
            ? 'ARCHIVIERTE DAs (${archived.length})'
            : 'ARCHIVED DAs (${archived.length})',
      ),
    );
    entries.addAll(archived.map(_DriverPickerEntry.driver));
  }
  return entries;
}

class _AbsenceAdminItem {
  final String requestId;
  final String driverId;
  final String driverName;
  final String type;
  final String status;
  final String reason;
  final DateTime fromDate;
  final DateTime toDate;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  /// Zeitpunkt, ab dem der Antrag „im System verbucht" war — Anker für
  /// den manuellen Resturlaubs-Override (siehe `vacationBookedAtOf`).
  ///
  /// Bewusst NICHT aus [submittedAt] abgeleitet: das Feld fällt bei
  /// Altdaten auf `fromDate` zurück und würde einen nachgetragenen
  /// Vergangenheits-Urlaub fälschlich VOR den Override datieren. Hier
  /// gilt die kanonische Kette `reviewedAt → submittedAt → createdAt →
  /// updatedAt`, damit „DA Balance" denselben Saldo rechnet wie die
  /// vier übrigen Anzeigeorte.
  final DateTime? bookedAt;

  /// Zeitpunkt der Stornierung (Ticket jlmRu2T). Getrennt von
  /// [reviewedAt], damit die ursprüngliche Genehmigung erhalten bleibt.
  /// `null` bei Altfällen — dann greift [reviewedAt] als Fallback.
  final DateTime? cancelledAt;

  /// Bezahlter Urlaub? Nur für `type == 'vacation'` aussagekräftig.
  /// Bestandsdokumente ohne `paid`-Feld gelten als bezahlt — deshalb
  /// ist `true` der Fallback (Abwärtskompatibilität).
  final bool paid;

  /// Soft-Delete-Flag (Ticket „History löschen"). Gesetzte Einträge
  /// werden in der Admin-UI ausgeblendet, bleiben aber in Firestore —
  /// siehe `_softDeleteAbsence` für die Begründung.
  final bool deleted;

  /// Ticket „TIME & ABSENCE - HISTORY": Begründung der Ablehnung.
  /// Pflichtfeld beim Ablehnen, leer bei allen anderen Status und bei
  /// Altfällen, die vor dem Ticket abgelehnt wurden.
  final String rejectionReason;

  /// Krankmeldung-AU upload (Arbeitsunfähigkeitsbescheinigung), only
  /// set for sick-leave requests. Stored as base64 inline in Firestore.
  final String auFileBase64;
  final String auFilename;
  final String auMimeType;

  const _AbsenceAdminItem({
    required this.requestId,
    required this.driverId,
    required this.driverName,
    required this.type,
    required this.status,
    required this.reason,
    required this.fromDate,
    required this.toDate,
    required this.submittedAt,
    required this.reviewedAt,
    this.bookedAt,
    this.cancelledAt,
    this.paid = true,
    this.deleted = false,
    this.rejectionReason = '',
    this.auFileBase64 = '',
    this.auFilename = '',
    this.auMimeType = '',
  });

  bool get hasAuFile => auFileBase64.trim().isNotEmpty;

  factory _AbsenceAdminItem.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final fromDate = _toDate(data['fromDate']) ?? DateTime.now();
    final toDate = _toDate(data['toDate']) ?? fromDate;
    final submittedAt = _toDate(data['submittedAt']) ?? fromDate;

    // Fallback auf `driverId` wie im Kranktage-Ranking und in der
    // Fahrer-Übersicht: Altdaten ohne `driverTransporterId` hätten sonst
    // eine leere ID — und damit ein ausgegrautes ⋮-Menü, weil die
    // Fahrer-Kopie nicht adressierbar wäre.
    final driverId = _firstNonEmpty([
      _stringOf(data['driverTransporterId']),
      _stringOf(data['driverId']),
    ]).toUpperCase();

    return _AbsenceAdminItem(
      requestId: doc.id,
      driverId: driverId,
      driverName: _firstNonEmpty([
        _stringOf(data['driverName']),
        driverId,
      ]),
      type: _stringOf(data['type']).toLowerCase(),
      status: _stringOf(data['status']).toLowerCase().isEmpty
          ? 'pending'
          : _stringOf(data['status']).toLowerCase(),
      reason: _stringOf(data['reason']),
      fromDate: fromDate,
      toDate: toDate,
      submittedAt: submittedAt,
      reviewedAt: _toDate(data['reviewedAt']),
      // Aus den ROHDATEN, nicht aus `submittedAt` — Letzteres hat oben
      // bereits den `fromDate`-Fallback für Altdaten eingebaut.
      bookedAt: vacationBookedAtOf(data),
      cancelledAt: _toDate(data['cancelledAt']),
      // Fehlt das Feld (alle Bestandsdaten), gilt der Urlaub als bezahlt.
      paid: data['paid'] is bool ? data['paid'] as bool : true,
      deleted: data['deleted'] == true,
      rejectionReason: _stringOf(data['rejectionReason']),
      auFileBase64: _stringOf(data['auFileBase64']),
      auFilename: _stringOf(data['auFilename']),
      auMimeType: _stringOf(data['auMimeType']),
    );
  }

  String typeLabel(bool de) {
    switch (type) {
      case 'sick_leave':
        return de ? 'Krankmeldung' : 'Sick leave';
      case 'special_leave':
        return de ? 'Sonderurlaub' : 'Special leave';
      default:
        return de ? 'Urlaub' : 'Vacation';
    }
  }

  /// Nur Urlaub unterscheidet bezahlt/unbezahlt — andere Arten zeigen
  /// keinen Hinweis.
  bool get hasPaidFlag => type == 'vacation';

  String paidLabel(bool de) => paid
      ? (de ? 'Bezahlt' : 'Paid')
      : (de ? 'Unbezahlt' : 'Unpaid');

  /// Tage des Antrags.
  ///
  /// Ticket „TIME OFF & BALANCE": Bei URLAUB zählen nur Werktage —
  /// Wochenenden und die bundesweiten Feiertage zehren kein Kontingent
  /// auf und dürfen deshalb auch in der Anzeige nicht mitzählen. Für
  /// Krankmeldungen und Sonderurlaub bleibt es bei Kalendertagen
  /// (Bestandsverhalten; Krankheitstage werden kalendarisch gezählt).
  int get totalDays {
    final start = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final end = DateTime(toDate.year, toDate.month, toDate.day);
    if (end.isBefore(start)) return 0;
    if (type == 'vacation') return vacationChargeableDays(start, end);
    return end.difference(start).inDays + 1;
  }

  String daysLabel(bool de) => totalDays == 1
      ? (de ? '1 Tag' : '1 day')
      : (de ? '$totalDays Tage' : '$totalDays days');

  /// Datum, nach dem die Historie sortiert wird: bei Stornos der
  /// Storno-Zeitpunkt, sonst die Prüfung bzw. die Einreichung.
  DateTime get historySortDate => status == 'cancelled'
      ? (cancelledAt ?? reviewedAt ?? submittedAt)
      : (reviewedAt ?? submittedAt);

  String get fromDateText => DateFormat('dd.MM.yyyy').format(fromDate);
  String get toDateText => DateFormat('dd.MM.yyyy').format(toDate);
  String get submittedAtText => DateFormat('dd.MM.yyyy').format(submittedAt);

  String reviewLine(bool de) {
    // Stornierte Einträge datieren auf `cancelledAt`; `reviewedAt` bleibt
    // die ursprüngliche Genehmigung und dient nur als Fallback für
    // Altfälle, die noch ohne `cancelledAt` storniert wurden.
    final when = status == 'cancelled'
        ? (cancelledAt ?? reviewedAt ?? submittedAt)
        : (reviewedAt ?? submittedAt);
    final dateText = DateFormat('dd.MM.yyyy').format(when);
    final prefix = status == 'approved'
        ? (de ? 'Genehmigt' : 'Approved')
        : status == 'rejected'
            ? (de ? 'Abgelehnt' : 'Rejected')
            : status == 'cancelled'
                ? (de ? 'Storniert' : 'Cancelled')
                : (de ? 'Eingereicht' : 'Submitted');
    return de ? '$prefix am $dateText' : '$prefix on $dateText';
  }

  static DateTime? _toDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw.trim());
    }
    return null;
  }

  static String _stringOf(dynamic value) => value?.toString().trim() ?? '';

  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }
}

class _DriverOption {
  final String driverId;
  final String driverName;

  /// true = aktiver DA laut Drivers Hub (`isDriverWorking`),
  /// false = archivierter DA.
  final bool isActive;

  const _DriverOption({
    required this.driverId,
    required this.driverName,
    required this.isActive,
  });
}

/// Compact AU-Bescheinigung pill — green "AU vorhanden" + open icon
/// when uploaded, red "AU fehlt" when missing. Tap-to-open opens the
/// base64 in a new tab (web) or share-sheet (mobile) via a data: URL.
class _AuPill extends StatelessWidget {
  const _AuPill({required this.item});
  final _AbsenceAdminItem item;

  Future<void> _openAu(BuildContext context) async {
    if (!item.hasAuFile) return;
    final mime = item.auMimeType.trim().isNotEmpty
        ? item.auMimeType.trim()
        : 'application/pdf';
    try {
      final uri = Uri.parse('data:$mime;base64,${item.auFileBase64}');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      final de = Localizations.localeOf(context).languageCode == 'de';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de
                ? 'AU konnte nicht geöffnet werden: $e'
                : 'Could not open sick note: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final present = item.hasAuFile;
    final bg = present ? const Color(0xFFE7F5EE) : const Color(0xFFFEE2E2);
    final fg = present ? const Color(0xFF166534) : const Color(0xFFB91C1C);
    final icon = present
        ? Icons.medical_services_rounded
        : Icons.warning_amber_rounded;
    final label = present
        ? (de ? 'AU vorhanden' : 'Sick note uploaded')
        : (de ? 'AU fehlt' : 'Sick note missing');
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          if (present) ...[
            const SizedBox(width: 6),
            Icon(Icons.open_in_new_rounded, size: 13, color: fg),
          ],
        ],
      ),
    );
    if (!present) return child;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => _openAu(context),
      child: child,
    );
  }
}

/// Isolated search field — the parent page rebuilds many times due to
/// the wrapping StreamBuilder (Firestore metadata updates). Keeping the
/// TextField inside its own StatefulWidget stops Flutter-Web from
/// recreating the underlying HTML input on every parent rebuild, which
/// was the root cause of the "lose focus after every keystroke" bug.
class _AbsenceSearchField extends StatefulWidget {
  const _AbsenceSearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  State<_AbsenceSearchField> createState() => _AbsenceSearchFieldState();
}

class _AbsenceSearchFieldState extends State<_AbsenceSearchField> {
  @override
  Widget build(BuildContext context) {
    // One shared field feeds the page, the "all requests" popup and the time
    // accounts view — the controller decides when the clear button shows.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) => TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: Localizations.localeOf(context).languageCode == 'de'
            ? 'Nach Fahrername, ID oder Grund suchen'
            : 'Search by driver name, ID, or reason',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: buildSearchClearButton(
          context: context,
          value: value.text,
          focusNode: widget.focusNode,
          onClear: () {
            widget.controller.clear();
            widget.onChanged('');
          },
        ),
        suffixIconConstraints: kSearchClearConstraints,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: _AdminShiftAbsencePageState._kBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: _AdminShiftAbsencePageState._kBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: _AdminShiftAbsencePageState._kBorder,
          ),
        ),
      ),
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// CSV-Import für Krankheitstage (nur Krankmeldungs-Bereich)
// ---------------------------------------------------------------------------

/// Inhalt der Beispiel-Datei, die im Import-Dialog heruntergeladen
/// werden kann. Semikolon-getrennt, damit Excel (DE) sie direkt
/// spaltenweise öffnet.
const String _kSickCsvSample =
    'Name;Startdatum;Enddatum;Gesamttage\n'
    'Max Mustermann;01.08.2026;05.08.2026;5\n'
    'Erika Beispiel;12.08.2026;12.08.2026;1\n';

enum _SickCsvError { missingName, badFromDate, badToDate, endBeforeStart }

/// Eine geparste CSV-Zeile inklusive (später gesetzter) Fahrer-Zuordnung.
class _SickCsvRow {
  _SickCsvRow({
    required this.lineNumber,
    required this.rawName,
    this.fromDate,
    this.toDate,
    this.totalDaysRaw,
    this.error,
  });

  final int lineNumber;
  final String rawName;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? totalDaysRaw;
  final _SickCsvError? error;

  /// Zugeordneter aktiver Fahrer — automatisch per Namens-Matching
  /// oder manuell über das Dropdown in der Vorschau.
  _DriverOption? driver;

  /// true, wenn die Zuordnung eindeutig automatisch gefunden wurde.
  bool autoMatched = false;

  /// true, wenn die Zuordnung nur ein **Vorschlag** ist (Fuzzy-Treffer,
  /// z. B. Tippfehler oder Zweitname) — vorausgewählt, aber vom Admin
  /// zu bestätigen.
  bool isSuggestion = false;

  bool get isValid => error == null && fromDate != null && toDate != null;

  int get totalDays {
    if (!isValid) return 0;
    final start = DateTime(fromDate!.year, fromDate!.month, fromDate!.day);
    final end = DateTime(toDate!.year, toDate!.month, toDate!.day);
    if (end.isBefore(start)) return 0;
    return end.difference(start).inDays + 1;
  }

  String rangeText() {
    if (!isValid) return '';
    final fmt = DateFormat('dd.MM.yyyy');
    return fromDate == toDate
        ? fmt.format(fromDate!)
        : '${fmt.format(fromDate!)} – ${fmt.format(toDate!)}';
  }

  String errorLabel(bool de) {
    switch (error) {
      case _SickCsvError.missingName:
        return de ? 'Name fehlt' : 'Name missing';
      case _SickCsvError.badFromDate:
        return de ? 'Startdatum ungültig' : 'Invalid start date';
      case _SickCsvError.badToDate:
        return de ? 'Enddatum ungültig' : 'Invalid end date';
      case _SickCsvError.endBeforeStart:
        return de
            ? 'Enddatum liegt vor dem Startdatum'
            : 'End date is before start date';
      case null:
        return '';
    }
  }
}

class _SickCsvImportResult {
  const _SickCsvImportResult({
    required this.imported,
    required this.skipped,
    required this.duplicates,
  });

  final int imported;
  final int skipped;
  final int duplicates;

  String summary(bool de) => de
      ? '$imported importiert, $skipped übersprungen ($duplicates Duplikate)'
      : '$imported imported, $skipped skipped ($duplicates duplicates)';
}

/// Bytes → Text, tolerant gegenüber BOM und Nicht-UTF-8-Exporten
/// (Excel schreibt gern Windows-1252).
String _decodeCsvBytes(Uint8List bytes) {
  String text;
  try {
    text = utf8.decode(bytes);
  } catch (_) {
    text = latin1.decode(bytes, allowInvalid: true);
  }
  if (text.isNotEmpty && text.codeUnitAt(0) == 0xFEFF) {
    text = text.substring(1);
  }
  return text;
}

/// Ermittelt das Trennzeichen anhand der ersten nicht-leeren Zeile.
String _detectCsvDelimiter(List<String> lines) {
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    var semi = 0;
    var comma = 0;
    var tab = 0;
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (inQuotes) continue;
      if (ch == ';') semi++;
      if (ch == ',') comma++;
      if (ch == '\t') tab++;
    }
    if (tab > semi && tab > comma) return '\t';
    if (comma > semi) return ',';
    return ';';
  }
  return ';';
}

List<String> _splitCsvLine(String line, String delimiter) {
  final fields = <String>[];
  final buf = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        buf.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }
    if (!inQuotes && ch == delimiter) {
      fields.add(buf.toString());
      buf.clear();
      continue;
    }
    buf.write(ch);
  }
  fields.add(buf.toString());
  return fields.map((f) => f.trim()).toList(growable: false);
}

DateTime? _safeCsvDate(int year, int month, int day) {
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}

/// Akzeptiert dd.MM.yyyy, dd.MM.yy, dd/MM/yyyy, dd-MM-yyyy und
/// yyyy-MM-dd (sowie ISO-Strings mit Uhrzeit). Keine Datums-Untergrenze —
/// Vergangenheits-Zeiträume sind der Normalfall.
DateTime? _parseCsvDate(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final compact = trimmed.replaceAll(RegExp(r'\s+'), '');

  final iso = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$').firstMatch(compact);
  if (iso != null) {
    return _safeCsvDate(
      int.parse(iso.group(1)!),
      int.parse(iso.group(2)!),
      int.parse(iso.group(3)!),
    );
  }

  final dmy = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2}|\d{4})$')
      .firstMatch(compact);
  if (dmy != null) {
    final day = int.parse(dmy.group(1)!);
    final month = int.parse(dmy.group(2)!);
    var year = int.parse(dmy.group(3)!);
    if (dmy.group(3)!.length == 2) {
      year += year >= 70 ? 1900 : 2000;
    }
    return _safeCsvDate(year, month, day);
  }

  final parsed = DateTime.tryParse(trimmed);
  if (parsed != null) {
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
  return null;
}

/// Normalisiert Namen für das Matching: Klammer-Zusätze raus
/// (z. B. "David Reng (MO - FR)" → "david reng"), trim,
/// Mehrfach-Leerzeichen, lowercase, Umlaut-/Akzent-Transliteration,
/// Satzzeichen weg.
String _normalizeDriverName(String raw) {
  const map = <String, String>{
    'ä': 'ae', 'ö': 'oe', 'ü': 'ue', 'ß': 'ss',
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'å': 'a', 'ā': 'a', 'ą': 'a',
    'æ': 'ae', 'ç': 'c', 'ć': 'c', 'č': 'c',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ę': 'e', 'ě': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i',
    'ñ': 'n', 'ń': 'n', 'ň': 'n',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ø': 'o', 'ō': 'o', 'ő': 'oe',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ū': 'u', 'ů': 'u', 'ű': 'ue',
    'ý': 'y', 'ÿ': 'y',
    'ś': 's', 'š': 's', 'ş': 's',
    'ź': 'z', 'ż': 'z', 'ž': 'z',
    'ł': 'l', 'ř': 'r', 'ť': 't', 'đ': 'd', 'ğ': 'g', 'ı': 'i',
  };
  // Klammer-Zusätze (Schichtcodes, Notizen) zählen nicht zum Namen.
  final lower = raw
      .replaceAll(RegExp(r'\([^)]*\)'), ' ')
      .toLowerCase()
      .trim();
  final buf = StringBuffer();
  for (final ch in lower.split('')) {
    buf.write(map[ch] ?? ch);
  }
  return buf
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _sortedNameKey(String normalized) {
  final parts = normalized.split(' ').where((p) => p.isNotEmpty).toList()
    ..sort();
  return parts.join(' ');
}

/// Levenshtein-Distanz (Tippfehler-Toleranz für Namen). Bewusst simpel
/// gehalten — Namen sind kurz, es läuft nur über die aktiven Fahrer.
int _levenshteinDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var previous = List<int>.generate(b.length + 1, (i) => i, growable: false);
  var current = List<int>.filled(b.length + 1, 0, growable: false);

  for (var i = 1; i <= a.length; i++) {
    current[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      current[j] = math.min(
        math.min(current[j - 1] + 1, previous[j] + 1),
        previous[j - 1] + cost,
      );
    }
    final swap = previous;
    previous = current;
    current = swap;
  }
  return previous[b.length];
}

Set<String> _nameTokens(String normalized) =>
    normalized.split(' ').where((t) => t.isNotEmpty).toSet();

/// Matcht CSV-Namen gegen **aktive** Fahrer — exakt (normalisiert),
/// zusätzlich mit vertauschter Vorname/Nachname-Reihenfolge sowie
/// gegen die Transporter-ID. Mehrdeutige Treffer bleiben bewusst
/// unbeantwortet (manuelle Zuordnung im Dialog).
///
/// `suggest()` liefert darüber hinaus einen **Vorschlag** (kein
/// Auto-Match) für Tippfehler bzw. Zweitnamen — im Dialog wird der
/// Vorschlag nur vorausgewählt und muss vom Admin bestätigt werden.
class _SickCsvDriverMatcher {
  _SickCsvDriverMatcher(List<_DriverOption> drivers) {
    _drivers = List<_DriverOption>.unmodifiable(drivers);
    for (final driver in drivers) {
      final normalized = _normalizeDriverName(driver.driverName);
      if (normalized.isNotEmpty) {
        _byName.putIfAbsent(normalized, () => <_DriverOption>[]).add(driver);
        _bySortedTokens
            .putIfAbsent(_sortedNameKey(normalized), () => <_DriverOption>[])
            .add(driver);
      }
      final id = _normalizeDriverName(driver.driverId);
      if (id.isNotEmpty) {
        _byId.putIfAbsent(id, () => <_DriverOption>[]).add(driver);
      }
    }
  }

  late final List<_DriverOption> _drivers;
  final Map<String, List<_DriverOption>> _byName = {};
  final Map<String, List<_DriverOption>> _bySortedTokens = {};
  final Map<String, List<_DriverOption>> _byId = {};

  _DriverOption? match(String rawName) {
    final normalized = _normalizeDriverName(rawName);
    if (normalized.isEmpty) return null;

    final direct = _byName[normalized];
    if (direct != null && direct.length == 1) return direct.first;

    final swapped = _bySortedTokens[_sortedNameKey(normalized)];
    if (swapped != null && swapped.length == 1) return swapped.first;

    final byId = _byId[normalized];
    if (byId != null && byId.length == 1) return byId.first;

    return null;
  }

  /// Bester Kandidat für einen **nicht** exakt erkannten Namen.
  /// Zwei Quellen, in dieser Reihenfolge:
  /// 1. Levenshtein-Distanz <= 2 auf dem normalisierten Gesamtnamen
  ///    (fängt Tippfehler wie "Denise Muller" → "Denise Mueller" ab),
  /// 2. Token-Teilmenge mit mindestens 2 gemeinsamen Tokens
  ///    ("Alexandra Sonia Marghitan" → "Alexandra Marghitan").
  /// Mehrdeutigkeiten (zwei gleich gute Kandidaten) liefern `null`.
  _DriverOption? suggest(String rawName) {
    final normalized = _normalizeDriverName(rawName);
    if (normalized.isEmpty) return null;

    _DriverOption? best;
    var bestDistance = _kMaxSuggestDistance + 1;
    var ambiguous = false;

    for (final driver in _drivers) {
      final target = _normalizeDriverName(driver.driverName);
      if (target.isEmpty) continue;
      final distance = _levenshteinDistance(normalized, target);
      if (distance > _kMaxSuggestDistance) continue;
      if (distance < bestDistance) {
        bestDistance = distance;
        best = driver;
        ambiguous = false;
      } else if (distance == bestDistance && !identical(driver, best)) {
        ambiguous = true;
      }
    }
    if (best != null && !ambiguous) return best;

    // Fallback: Token-Teilmenge (Zweit-/Mittelnamen in nur einer Quelle).
    final tokens = _nameTokens(normalized);
    if (tokens.length < 2) return null;

    _DriverOption? subsetBest;
    var subsetOverlap = 0;
    var subsetAmbiguous = false;

    for (final driver in _drivers) {
      final targetTokens = _nameTokens(_normalizeDriverName(driver.driverName));
      if (targetTokens.length < 2) continue;
      final overlap = tokens.intersection(targetTokens).length;
      if (overlap < 2) continue;
      final isSubset = tokens.containsAll(targetTokens) ||
          targetTokens.containsAll(tokens);
      if (!isSubset) continue;
      if (overlap > subsetOverlap) {
        subsetOverlap = overlap;
        subsetBest = driver;
        subsetAmbiguous = false;
      } else if (overlap == subsetOverlap && !identical(driver, subsetBest)) {
        subsetAmbiguous = true;
      }
    }
    return subsetAmbiguous ? null : subsetBest;
  }

  /// Ab dieser Distanz gilt ein Name nicht mehr als Tippfehler.
  static const int _kMaxSuggestDistance = 2;
}

bool _looksLikeCsvHeader(List<String> cells) {
  if (cells.isEmpty) return false;
  final tokens = cells.map(_normalizeDriverName).join(' ').split(' ').toSet();
  const markers = <String>{
    'name', 'fahrer', 'driver', 'mitarbeiter', 'employee',
    'startdatum', 'enddatum', 'gesamttage', 'start', 'end', 'ende',
    'von', 'bis', 'from', 'to', 'days', 'tage', 'datum', 'date', 'total',
  };
  final hasMarker = tokens.any(markers.contains);
  final hasDate = cells.skip(1).any((c) => _parseCsvDate(c) != null);
  return hasMarker && !hasDate;
}

/// Parst den CSV-Text in Zeilen. Leere Zeilen werden ignoriert, die
/// Kopfzeile (falls vorhanden) übersprungen. Die Spalte „Gesamttage"
/// ist rein informativ.
List<_SickCsvRow> _parseSickLeaveCsv(String text) {
  final lines = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
  final delimiter = _detectCsvDelimiter(lines);
  final rows = <_SickCsvRow>[];
  var headerChecked = false;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().isEmpty) continue;
    final cells = _splitCsvLine(line, delimiter);
    if (cells.every((c) => c.isEmpty)) continue;

    if (!headerChecked) {
      headerChecked = true;
      if (_looksLikeCsvHeader(cells)) continue;
    }

    final lineNumber = i + 1;
    final name = cells.isNotEmpty ? cells[0] : '';
    final fromRaw = cells.length > 1 ? cells[1] : '';
    final toRaw = cells.length > 2 ? cells[2] : '';
    final totalRaw = cells.length > 3 ? cells[3] : '';

    if (name.trim().isEmpty) {
      rows.add(_SickCsvRow(
        lineNumber: lineNumber,
        rawName: name,
        error: _SickCsvError.missingName,
      ));
      continue;
    }

    final fromDate = _parseCsvDate(fromRaw);
    if (fromDate == null) {
      rows.add(_SickCsvRow(
        lineNumber: lineNumber,
        rawName: name,
        error: _SickCsvError.badFromDate,
      ));
      continue;
    }

    DateTime? toDate;
    if (toRaw.trim().isEmpty) {
      toDate = fromDate;
    } else {
      toDate = _parseCsvDate(toRaw);
      if (toDate == null) {
        rows.add(_SickCsvRow(
          lineNumber: lineNumber,
          rawName: name,
          error: _SickCsvError.badToDate,
        ));
        continue;
      }
    }

    if (toDate.isBefore(fromDate)) {
      rows.add(_SickCsvRow(
        lineNumber: lineNumber,
        rawName: name,
        error: _SickCsvError.endBeforeStart,
      ));
      continue;
    }

    rows.add(_SickCsvRow(
      lineNumber: lineNumber,
      rawName: name.trim(),
      fromDate: fromDate,
      toDate: toDate,
      totalDaysRaw: totalRaw.trim().isEmpty ? null : totalRaw.trim(),
    ));
  }

  return rows;
}

/// Popup für den CSV-Massenimport von Krankheitstagen: Beispiel-Datei,
/// Upload, Vorschau mit manueller Zuordnung und Import.
class _SickLeaveCsvImportDialog extends StatefulWidget {
  const _SickLeaveCsvImportDialog({
    required this.activeDrivers,
    required this.onImport,
  });

  /// Nur aktive DAs — Matching und Dropdown greifen ausschließlich hierauf.
  final List<_DriverOption> activeDrivers;
  final Future<_SickCsvImportResult> Function(List<_SickCsvRow> rows) onImport;

  @override
  State<_SickLeaveCsvImportDialog> createState() =>
      _SickLeaveCsvImportDialogState();
}

class _SickLeaveCsvImportDialogState extends State<_SickLeaveCsvImportDialog> {
  static const _kGreen = _AdminShiftAbsencePageState._kGreen;
  static const _kText = _AdminShiftAbsencePageState._kText;
  static const _kMuted = _AdminShiftAbsencePageState._kMuted;
  static const _kBorder = _AdminShiftAbsencePageState._kBorder;
  static const _kRed = _AdminShiftAbsencePageState._kRed;
  static const _kOrange = _AdminShiftAbsencePageState._kOrange;

  static const String _kSkipValue = '__skip__';

  List<_SickCsvRow> _rows = const [];
  String? _fileName;
  String? _error;
  bool _parsing = false;
  bool _importing = false;

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  int get _readyCount =>
      _rows.where((r) => r.isValid && r.driver != null).length;
  int get _openCount => _rows.where((r) => r.isValid && r.driver == null).length;
  int get _invalidCount => _rows.where((r) => !r.isValid).length;
  int get _suggestionCount =>
      _rows.where((r) => r.isValid && r.driver != null && r.isSuggestion).length;

  Future<void> _downloadSample() async {
    final de = _de;
    try {
      // BOM voranstellen, damit Excel Umlaute korrekt anzeigt.
      final bytes = Uint8List.fromList(utf8.encode('﻿$_kSickCsvSample'));
      await downloadWebBytes(bytes, 'krankheitstage_beispiel.csv');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = de
            ? 'Download nicht möglich: $e'
            : 'Download failed: $e';
      });
    }
  }

  Future<void> _pickAndParse() async {
    final de = _de;
    setState(() {
      _error = null;
      _parsing = true;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: const ['csv', 'txt'],
      );
      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _parsing = false);
        return;
      }
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        throw Exception(
          de ? 'Datei konnte nicht gelesen werden.' : 'Could not read file.',
        );
      }

      final rows = _parseSickLeaveCsv(_decodeCsvBytes(bytes));
      final matcher = _SickCsvDriverMatcher(widget.activeDrivers);
      for (final row in rows) {
        if (!row.isValid) continue;
        final match = matcher.match(row.rawName);
        if (match != null) {
          row.driver = match;
          row.autoMatched = true;
          row.isSuggestion = false;
          continue;
        }
        // Kein eindeutiger Treffer → Fuzzy-Vorschlag vorauswählen,
        // aber als "bitte prüfen" markieren.
        final suggestion = matcher.suggest(row.rawName);
        row.driver = suggestion;
        row.autoMatched = false;
        row.isSuggestion = suggestion != null;
      }

      if (!mounted) return;
      setState(() {
        _rows = rows;
        _fileName = file.name;
        _parsing = false;
        _error = rows.isEmpty
            ? (de
                ? 'Keine verwertbaren Zeilen gefunden.'
                : 'No usable rows found.')
            : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _parsing = false;
        _error = de ? 'Import fehlgeschlagen: $e' : 'Import failed: $e';
      });
    }
  }

  Future<void> _runImport() async {
    final de = _de;
    setState(() {
      _importing = true;
      _error = null;
    });
    try {
      final result = await widget.onImport(_rows);
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _importing = false;
        _error = de ? 'Import fehlgeschlagen: $e' : 'Import failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final de = _de;
    final busy = _parsing || _importing;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      color: _kRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          de
                              ? 'Krankheitstage importieren'
                              : 'Import sick days',
                          style: const TextStyle(
                            color: _kText,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          de
                              ? 'CSV mit Name, Startdatum, Enddatum und (optional) Gesamttage hochladen. Namen werden automatisch aktiven Fahrern zugeordnet — nicht erkannte Zeilen ordnest du unten selbst zu. Vergangene Zeiträume sind ausdrücklich erlaubt.'
                              : 'Upload a CSV with name, start date, end date and (optional) total days. Names are matched to active drivers automatically — assign unmatched rows yourself below. Past date ranges are explicitly allowed.',
                          style: const TextStyle(
                            color: _kMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: busy ? null : _downloadSample,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(
                      de
                          ? 'Beispiel-CSV herunterladen'
                          : 'Download sample CSV',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: busy ? null : _pickAndParse,
                    icon: _parsing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.file_upload_outlined, size: 18),
                    label: Text(
                      _fileName == null
                          ? (de ? 'CSV auswählen' : 'Choose CSV')
                          : (de ? 'Andere CSV wählen' : 'Choose another CSV'),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kGreen,
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
              if (_fileName != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: _kMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _fileName!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _kMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: _kRed,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              if (_rows.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  de
                      ? '${_rows.length} Zeilen · $_readyCount zugeordnet'
                          '${_suggestionCount > 0 ? " (davon $_suggestionCount Vorschläge)" : ""}'
                          ' · $_openCount offen · $_invalidCount fehlerhaft'
                      : '${_rows.length} rows · $_readyCount matched'
                          '${_suggestionCount > 0 ? " ($_suggestionCount suggested)" : ""}'
                          ' · $_openCount open · $_invalidCount invalid',
                  style: const TextStyle(
                    color: _kText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (_suggestionCount > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    de
                        ? 'Orange markierte Zeilen sind Vorschläge (ähnlicher Name) — bitte vor dem Import prüfen.'
                        : 'Rows marked orange are suggestions (similar name) — please check before importing.',
                    style: const TextStyle(
                      color: _kOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 340),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kBorder),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(10),
                        shrinkWrap: true,
                        itemCount: _rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) =>
                            _buildRowTile(_rows[index], de),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  TextButton(
                    onPressed: busy ? null : () => Navigator.of(context).pop(),
                    child: Text(de ? 'Abbrechen' : 'Cancel'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: (busy || _readyCount == 0) ? null : _runImport,
                    icon: _importing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.playlist_add_check_rounded),
                    label: Text(
                      _importing
                          ? (de ? 'Importiere...' : 'Importing...')
                          : (de
                              ? 'Importieren ($_readyCount)'
                              : 'Import ($_readyCount)'),
                    ),
                    style: FilledButton.styleFrom(backgroundColor: _kGreen),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowTile(_SickCsvRow row, bool de) {
    if (!row.isValid) {
      return _tileShell(
        accent: _kRed,
        icon: Icons.error_outline_rounded,
        title: row.rawName.trim().isEmpty
            ? (de ? 'Zeile ${row.lineNumber}' : 'Row ${row.lineNumber}')
            : row.rawName,
        subtitle: de
            ? '${row.errorLabel(de)} (Zeile ${row.lineNumber})'
            : '${row.errorLabel(de)} (row ${row.lineNumber})',
      );
    }

    final driver = row.driver;
    final daysText = row.totalDays == 1
        ? (de ? '1 Tag' : '1 day')
        : (de ? '${row.totalDays} Tage' : '${row.totalDays} days');

    if (driver != null) {
      if (row.isSuggestion) {
        // Fuzzy-Treffer: vorausgewählt, aber deutlich als Vorschlag
        // gekennzeichnet — der Admin bestätigt mit dem Import-Klick.
        return _tileShell(
          accent: _kOrange,
          icon: Icons.lightbulb_outline_rounded,
          title: '${driver.driverName} (${driver.driverId})',
          subtitle: de
              ? '${row.rangeText()} · $daysText · CSV: "${row.rawName}"'
              : '${row.rangeText()} · $daysText · CSV: "${row.rawName}"',
          badge: de ? 'Vorschlag — bitte prüfen' : 'Suggestion — please check',
          trailing: _buildAssignDropdown(row, de),
        );
      }
      return _tileShell(
        accent: _kGreen,
        icon: Icons.check_circle_rounded,
        title: '${driver.driverName} (${driver.driverId})',
        subtitle: row.autoMatched
            ? '${row.rangeText()} · $daysText'
            : '${row.rangeText()} · $daysText · '
                '${de ? 'manuell zugeordnet' : 'assigned manually'}',
        trailing: _buildAssignDropdown(row, de),
      );
    }

    return _tileShell(
      accent: _kOrange,
      icon: Icons.help_outline_rounded,
      title: row.rawName,
      subtitle: de
          ? '${row.rangeText()} · $daysText · nicht erkannt'
          : '${row.rangeText()} · $daysText · not matched',
      trailing: _buildAssignDropdown(row, de),
    );
  }

  Widget _buildAssignDropdown(_SickCsvRow row, bool de) {
    final value = row.driver?.driverId ?? _kSkipValue;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        isDense: true,
        underline: const SizedBox.shrink(),
        style: const TextStyle(
          color: _kText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        items: [
          DropdownMenuItem<String>(
            value: _kSkipValue,
            child: Text(
              de ? 'Überspringen' : 'Skip',
              style: const TextStyle(
                color: _kMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (final driver in widget.activeDrivers)
            DropdownMenuItem<String>(
              value: driver.driverId,
              child: Text(
                '${driver.driverName} (${driver.driverId})',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: _importing
            ? null
            : (selected) {
                setState(() {
                  if (selected == null || selected == _kSkipValue) {
                    row.driver = null;
                    row.autoMatched = false;
                    row.isSuggestion = false;
                    return;
                  }
                  row.driver = widget.activeDrivers
                      .firstWhere((d) => d.driverId == selected);
                  row.autoMatched = false;
                  row.isSuggestion = false;
                });
              },
      ),
    );
  }

  Widget _tileShell({
    required Color accent,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _kText,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                color: accent,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _kMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Ticket GB8SQFS + RsRiTdR — „DA Balance": Fahrer-Übersicht mit
// Abwesenheits-Historie UND Überstunden-Saldo in EINEM Tab.
//
// Ersetzt die früheren getrennten Tabs „Zeitkonto" und „Fahrer": listet
// alle AKTIVEN Fahrer (`isDriverWorking`, gleiche Quelle wie Drivers
// Hub) und zeigt je Zeile drei Kennzahlen — genommene Krankheitstage,
// PTO-Balance (verbleibende BEZAHLTE Urlaubstage) und Overtime-Balance.
// Klick auf einen Fahrer öffnet die komplette Historie (Urlaub &
// Sonderurlaub, Krankmeldungen, Überstunden), je Sektion 3 Einträge
// inline + „Mehr anzeigen"-Popup für den Rest.
//
// Datenquellen (alle aus den zwei ohnehin geladenen Sammlungen — keine
// zusätzlichen Queries, keine Rules-Änderung):
//  * Urlaub / Krankmeldungen: `users/{scope}/absence_requests`
//    (Root-Sammlung, die auch die Urlaubs-/Krankmeldungs-Tabs
//    bedienen). Die Zuordnung läuft über `driverTransporterId` mit
//    Fallback auf `driverId` — robuster als die Fahrer-Kopie, weil dort
//    ältere Bestandsdaten fehlen können.
//  * PTO-Balance: `onboarding.annualVacationDays`,
//    `onboarding.workStartDate` und
//    `onboarding.remainingVacationDaysOverride` aus dem Fahrer-Dokument
//    — identische Formel wie `_remainingVacationDaysRow` im Drivers Hub.
//  * Overtime: Map-Feld `overtimeAccount` im Fahrer-Dokument (Werte in
//    MINUTEN, Schlüssel `YYYY-MM`) — exakt die Quelle, aus der auch der
//    bisherige Zeitkonto-Tab gerechnet hat.
// ─────────────────────────────────────────────────────────────────────

/// „H:MM" bzw. „-H:MM" → Minuten. Gleiche Konvention wie im
/// Zeitkonto-Tab, damit Bestandsdaten als String weiter lesbar sind.
int _daParseDuration(String value) {
  final cleaned = value.trim().replaceAll(',', ':');
  if (cleaned.isEmpty) return 0;
  final isNegative = cleaned.startsWith('-');
  final raw = isNegative ? cleaned.substring(1) : cleaned;
  final parts = raw.split(':');
  final hours = int.tryParse(parts.first) ?? 0;
  final minutes = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  final total = hours * 60 + minutes;
  return isNegative ? -total : total;
}

int _daMinutesFromAny(dynamic value) {
  if (value is num) return value.round();
  return _daParseDuration('$value');
}

/// Minuten → „126:49" (Stunden nicht aufgefüllt, Minuten zweistellig).
/// Aufrufer hängen das „ h" selbst an — identisch zum Zeitkonto-Tab.
String _daFormatDuration(int minutesValue) {
  final isNegative = minutesValue < 0;
  final absolute = minutesValue.abs();
  final hours = absolute ~/ 60;
  final minutes = absolute % 60;
  return '${isNegative ? '-' : ''}$hours:${minutes.toString().padLeft(2, '0')}';
}

/// Ein Monat des Überstunden-Kontos.
class _DriverOvertimeMonth {
  const _DriverOvertimeMonth({
    required this.month,
    required this.targetMinutes,
    required this.workedMinutes,
    required this.paidMinutes,
  });

  /// `YYYY-MM`.
  final String month;

  /// Soll / Target.
  final int targetMinutes;

  /// Ist / Worked.
  final int workedMinutes;

  /// Bereits ausgezahlte Überstunden dieses Monats.
  final int paidMinutes;

  int get overtimeMinutes => workedMinutes - targetMinutes;

  /// Was nach der Auszahlung offen bleibt — das ist der Wert, der in
  /// den Gesamtsaldo läuft (gleiche Rechnung wie im Zeitkonto-Tab).
  int get remainingMinutes => overtimeMinutes - paidMinutes;

  String monthLabel(bool de) {
    final parts = month.split('-');
    if (parts.length < 2) return month;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (y == null || m == null || m < 1 || m > 12) return month;
    const deNames = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    const enNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${(de ? deNames : enNames)[m - 1]} $y';
  }
}

/// Liest das Map-Feld `overtimeAccount` aus dem Fahrer-Dokument,
/// neueste Monate zuerst.
List<_DriverOvertimeMonth> _overtimeMonthsOf(Map<String, dynamic> data) {
  final raw = data['overtimeAccount'];
  if (raw is! Map) return const <_DriverOvertimeMonth>[];
  final out = <_DriverOvertimeMonth>[];
  raw.forEach((key, value) {
    if (value is! Map) return;
    final map = value.map((k, v) => MapEntry(k.toString(), v));
    out.add(
      _DriverOvertimeMonth(
        month: key.toString(),
        targetMinutes: _daMinutesFromAny(map['target']),
        workedMinutes: _daMinutesFromAny(map['worked']),
        paidMinutes: _daMinutesFromAny(map['paid']),
      ),
    );
  });
  out.sort((a, b) => b.month.compareTo(a.month));
  return out;
}

// `_daCompletedMonthsSince` ist mit `accruedVacationDays` entfallen —
// die Monatsformel lebt jetzt als `completedMonthsSince` in
// `utils/vacation_pools.dart`.

/// Ganze Zahlen ohne Nachkommastellen, sonst max. zwei — gleiche
/// Darstellung wie `_formatVacationDays` im Drivers Hub.
String _daFormatDays(double value) {
  if (value % 1 == 0) return value.toInt().toString();
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// Ersetzt Zeichen, die die PDF-Standardschrift (Latin-1) nicht
/// darstellen kann — sie erscheinen sonst als leere Kästchen.
///
/// Gleiche Tabelle wie `_pdfSafe` im Vorschuss-PDF
/// (`driver_da_requests_view.dart`); der Report nutzt bewusst dieselbe
/// Lösung wie der Bestand, statt einen Unicode-Font einzubetten.
String _daPdfSafe(String input) {
  const map = {
    '\u2013': '-', // – Halbgeviertstrich
    '\u2014': '-', // — Geviertstrich
    '\u2010': '-',
    '\u2011': '-',
    '\u2012': '-',
    '\u2018': "'",
    '\u2019': "'",
    '\u201A': ',',
    '\u201C': '"',
    '\u201D': '"',
    '\u201E': '"',
    '\u2026': '...',
    '\u00A0': ' ',
    '\u202F': ' ',
    '\u2009': ' ',
    '\u20AC': 'EUR',
    '\u2192': '->',
    '\u2022': '-',
    '\u2713': 'x',
    '\u2714': 'x',
    '\u221E': '-', // ∞ = offener Vertragszeitraum
  };
  var out = input;
  map.forEach((k, v) => out = out.replaceAll(k, v));
  // Alles, was darüber hinaus außerhalb von Latin-1 liegt, entfernen.
  out = out.replaceAll(RegExp(r'[^\u0000-\u00FF]'), '');
  return out;
}

/// Tages-Sollstunden des DSP in MINUTEN — aus dem Admin-Dokument
/// (`users/{dspUid}.cotimerEmployment`).
///
/// Ticket „TIME & BALANCE". Die Konfiguration ist DSP-weit (siehe
/// `admin_cotimer_employment_dialog.dart`; die Function
/// `computeMonthlyAccount` liest dasselbe Feld und kennt ebenfalls
/// keine Fahrer-Overrides). Reihenfolge der Quellen:
///   1. `dailyContractHours`
///   2. `weeklyContractHours` / Anzahl `workingDays`
///   3. 8 h — derselbe Default wie in der Function
///
/// `sollMode == 'fixed_monthly'` bleibt bewusst außen vor: ein
/// Monatssoll lässt sich nicht verlässlich auf einen einzelnen
/// Urlaubstag herunterbrechen; dort greift der Tagesstunden-Wert des
/// Dialogs (Default 8 h) — dieselbe Näherung, die auch die Gutschrift
/// bezahlter Urlaubstage in der Function verwendet.
int _dailyContractMinutesOf(Map<String, dynamic> adminData) {
  const fallbackMinutes = 8 * 60;
  final raw = adminData['cotimerEmployment'];
  if (raw is! Map) return fallbackMinutes;
  final emp = raw.map((k, v) => MapEntry(k.toString(), v));

  double? asHours(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.'));
    }
    return null;
  }

  final daily = asHours(emp['dailyContractHours']);
  if (daily != null && daily > 0) return (daily * 60).round();

  final weekly = asHours(emp['weeklyContractHours']);
  final workingDays = emp['workingDays'];
  final dayCount = workingDays is List && workingDays.isNotEmpty
      ? workingDays.length
      : 5;
  if (weekly != null && weekly > 0) {
    return (weekly * 60 / dayCount).round();
  }
  return fallbackMinutes;
}

/// Abwesenheits- und Zeitkonto-Profil eines Fahrers.
class _DriverAbsenceProfile {
  final String driverId;
  final String driverName;

  /// `false` = archivierter (ausgetretener/deaktivierter) Fahrer. Solche
  /// wurden frueher gar nicht geladen; jetzt liegen sie hinter dem
  /// Archiv-Umschalter, damit alte Salden nachvollziehbar bleiben.
  final bool isActive;

  /// Personalnummer (`employeeNumber`) — leer, wenn nicht gepflegt.
  final String employeeNumber;

  /// Vertragszeitraum des aktuell laufenden (sonst jüngsten)
  /// Beschäftigungszeitraums, bereits als Text.
  final String contractPeriodText;

  /// Derselbe Zeitraum als Datum — der Text oben ist gekürzt (`dd.MM.yy`)
  /// und enthält „∞“ für offene Verträge, taugt also nicht zum Rechnen
  /// oder für den PDF-Export (Ticket „DA balance PDF": dort muss der
  /// letzte Vertragstag ausgeschrieben stehen).
  final DateTime? contractStart;
  final DateTime? contractEnd;

  /// Urlaub + Sonderurlaub — beides ist bezahlte/geplante Freizeit und
  /// gehört im Fahrer-Blatt unter „Urlaub (PTO)".
  final List<_AbsenceAdminItem> vacation;
  final List<_AbsenceAdminItem> sick;

  /// Überstunden je Monat, neueste zuerst.
  final List<_DriverOvertimeMonth> overtimeMonths;

  /// Jahresurlaub aus dem Onboarding (Default 20).
  final double annualVacationDays;

  /// Beschäftigungsbeginn — Basis der anteiligen Berechnung.
  final DateTime? workStartDate;

  /// Manueller Admin-Override — seit dem Bugfix eine MOMENTAUFNAHME zum
  /// Zeitpunkt [vacationOverrideAt], kein eingefrorener Endwert mehr.
  final double? vacationOverride;
  final DateTime? vacationOverrideAt;

  /// DSP-weite Urlaubstopf-Konfiguration; [VacationPoolsConfig.disabled]
  /// = bisheriges Ein-Topf-Verhalten.
  final VacationPoolsConfig poolsConfig;

  /// Tages-Sollstunden in MINUTEN.
  ///
  /// Ticket „TIME & BALANCE": Quelle ist die DSP-weite Vertrags-
  /// konfiguration `users/{dspUid}.cotimerEmployment` — dasselbe
  /// Dokument, aus dem auch die Cloud Function `computeMonthlyAccount`
  /// ihre Sollstunden zieht (`dailyContractHours`, Fallback
  /// `weeklyContractHours / Anzahl Arbeitstage`, sonst 8 h). Bewusst
  /// KEINE eigene Konstante: sonst liefen App und Function auseinander.
  final int dailyContractMinutes;

  const _DriverAbsenceProfile({
    required this.driverId,
    required this.driverName,
    required this.isActive,
    required this.employeeNumber,
    required this.contractPeriodText,
    required this.contractStart,
    required this.contractEnd,
    required this.vacation,
    required this.sick,
    required this.overtimeMonths,
    required this.annualVacationDays,
    required this.workStartDate,
    required this.vacationOverride,
    required this.vacationOverrideAt,
    required this.poolsConfig,
    required this.dailyContractMinutes,
  });

  static int _approvedDays(List<_AbsenceAdminItem> items) => items
      .where((it) => it.status == 'approved')
      .fold<int>(0, (acc, it) => acc + it.totalDays);

  /// Nur `approved` zählt — offene, abgelehnte und stornierte
  /// (Ticket jlmRu2T) Einträge bleiben außen vor.
  int get approvedVacationDays => _approvedDays(vacation);
  int get approvedSickDays => _approvedDays(sick);

  /// Ticket KJV4n2S: unbezahlter Urlaub wird getrennt ausgewiesen —
  /// er belastet das bezahlte Urlaubskontingent nicht.
  int get approvedUnpaidVacationDays => vacation
      .where((it) => it.status == 'approved' && it.hasPaidFlag && !it.paid)
      .fold<int>(0, (acc, it) => acc + it.totalDays);

  // `approvedPaidVacationDays` und `accruedVacationDays` sind entfallen:
  // sie bildeten die alte, einfrierende Resturlaubs-Formel nach. Beides
  // steckt jetzt in [vacationBalance] bzw. `utils/vacation_pools.dart`.

  /// Urlaubs-Saldo aus der gemeinsamen Formel (`utils/vacation_pools.dart`)
  /// — identisch zu Drivers Hub, Detailseite und Fahrer-App.
  VacationBalance get vacationBalance => computeVacationBalance(
        absences: vacation
            .map((it) => VacationAbsence(
                  from: it.fromDate,
                  to: it.toDate,
                  chargeable: it.type == 'vacation' &&
                      it.status == 'approved' &&
                      it.paid,
                  // Kanonische Kette aus den Rohdaten — siehe
                  // `_AbsenceAdminItem.bookedAt`.
                  bookedAt: it.bookedAt,
                ))
            .toList(growable: false),
        config: poolsConfig,
        annualVacationDays: annualVacationDays,
        workStartDate: workStartDate,
        manualOverride: vacationOverride,
        manualOverrideAt: vacationOverrideAt,
        // Ticket „DA balance PDF": bis zum letzten Vertragstag rechnen.
        // Ohne diesen Stichtag wuechse der anteilige Anspruch eines
        // ausgetretenen Fahrers Monat fuer Monat weiter, obwohl er gar
        // nicht mehr beschaeftigt ist. Bei laufendem Vertrag ist der
        // Stichtag schlicht heute — dort aendert sich nichts.
        now: balanceReferenceDate(DateTime.now()),
      );

  /// PTO Balance = verbleibende BEZAHLTE Urlaubstage über alle noch
  /// gültigen Töpfe. MIT Vorzeichen (Ticket „DA Balance"): wer mehr
  /// genommen hat als erworben, steht im Minus statt bei 0.
  double get ptoBalanceDays => vacationBalance.totalRemainingSigned;

  /// Kopfzeile „X von Y Urlaubstagen übrig (seit Vertragsbeginn)" —
  /// nur im Legacy-Modus (ein Topf, Zählung ab Beschäftigungsbeginn,
  /// Verfall erst zum Vertragsende). Im Topf-Modus tragen die Töpfe
  /// ihre eigene Aufschlüsselung. `null` = nicht anzeigen.
  /// [compact] kürzt für schmale Bildschirme — dort schnitt die lange
  /// Fassung sonst mitten im Satz ab (Ticket „TIME & BALANCE").
  String? ptoHeaderLine(bool de, {bool compact = false}) {
    final balance = vacationBalance;
    if (balance.pooled) return null;
    final total = balance.totalEntitlement;
    if (total <= 0) return null;
    final remaining = _daFormatDays(balance.totalRemainingSigned);
    final totalText = _daFormatDays(total);
    if (compact) {
      return de
          ? '$remaining von $totalText Tagen übrig'
          : '$remaining of $totalText days left';
    }
    return de
        ? '$remaining von $totalText Urlaubstagen übrig seit Beginn'
        : '$remaining of $totalText PTO days remaining since start';
  }

  /// Überstunden der erfassten Monate (offen nach Auszahlung), OHNE die
  /// Belastung durch unbezahlten Urlaub.
  int get recordedOvertimeMinutes => overtimeMonths.fold<int>(
      0, (acc, m) => acc + m.remainingMinutes);

  /// Ticket „TIME & BALANCE": Sollstunden der bereits genommenen
  /// UNBEZAHLTEN Urlaubstage.
  ///
  /// Unbezahlter Urlaub erzeugt keine Gutschrift, das Soll des Tages
  /// bleibt aber bestehen — dem Fahrer fehlen also genau diese Stunden
  /// (identische Regel wie serverseitig in `computeMonthlyAccount`, wo
  /// nur bezahlte Urlaubstage dem Ist gutgeschrieben werden).
  ///
  /// Gezählt werden nur WERKTAGE ([approvedUnpaidVacationDays] nutzt
  /// `vacationChargeableDays`): Wochenenden und bundesweite Feiertage
  /// haben ohnehin kein Soll.
  ///
  /// Warum die App das selbst rechnet: das hier angezeigte Konto kommt
  /// aus dem Map-Feld `overtimeAccount` (Excel-Import im Zeitkonto-Tab,
  /// Soll = Arbeitstage × Std./Tag). Dieser Import weiß nichts von
  /// Abwesenheiten — anders als die Function, die auf
  /// `time_account/{YYYY-MM}` schreibt. Ohne diesen Abzug bliebe
  /// unbezahlter Urlaub im DA-Balance-Blatt folgenlos.
  int get unpaidVacationChargeMinutes =>
      approvedUnpaidVacationDays * dailyContractMinutes;

  /// Overtime Balance über alle erfassten Monate (offen nach Auszahlung),
  /// abzüglich der Sollstunden unbezahlter Urlaubstage. Darf negativ
  /// werden — die Anzeige färbt negative Werte rot.
  int get overtimeBalanceMinutes =>
      recordedOvertimeMinutes - unpaidVacationChargeMinutes;

  /// Gibt es überhaupt etwas anzuzeigen? Auch ein Fahrer ganz ohne
  /// erfasste Monate bekommt einen Wert, sobald unbezahlter Urlaub das
  /// Konto belastet (genau der Fall aus dem Ticket).
  bool get hasOvertime =>
      overtimeMonths.isNotEmpty || unpaidVacationChargeMinutes > 0;

  bool get isEmpty =>
      vacation.isEmpty && sick.isEmpty && overtimeMonths.isEmpty;

  /// Ist der Vertrag am Stichtag [today] bereits beendet?
  bool contractEndedBy(DateTime today) {
    final end = contractEnd;
    return end != null && end.isBefore(DateTime(today.year, today.month, today.day));
  }

  /// Stichtag der Auswertung (Ticket „DA balance PDF": „counted until the
  /// last day of the contract"): laufender Vertrag → heute, beendeter
  /// Vertrag → letzter Vertragstag.
  ///
  /// Dieser Stichtag geht auch in die BERECHNUNG ein (siehe
  /// [vacationBalance]): Wer ausgetreten ist, erwirbt danach keinen
  /// weiteren Urlaubsanspruch mehr. Bildschirm und PDF zeigen deshalb
  /// dieselben Zahlen.
  DateTime balanceReferenceDate(DateTime today) {
    final day = DateTime(today.year, today.month, today.day);
    final end = contractEnd;
    if (end == null) return day;
    return end.isBefore(day) ? end : day;
  }
}

class AbsenceDriversOverviewPage extends StatefulWidget {
  const AbsenceDriversOverviewPage({super.key, required this.tabIndex});

  /// Position dieses Tabs im umschließenden [TabController]. Wird
  /// gebraucht, um beim Wechsel auf diesen Tab neu zu laden — die
  /// Zahlen entstehen aus einmaligen `get()`-Abfragen, nicht aus einem
  /// Live-Stream, und wären nach Bearbeiten/Stornieren in einem anderen
  /// Tab sonst veraltet.
  final int tabIndex;

  @override
  State<AbsenceDriversOverviewPage> createState() =>
      _AbsenceDriversOverviewPageState();
}

class _AbsenceDriversOverviewPageState
    extends State<AbsenceDriversOverviewPage> {
  static const _kText = Color(0xFF111827);
  static const _kMuted = Color(0xFF6B7280);
  static const _kBorder = Color(0xFFE5E7EB);
  static const _kPageBg = Color(0xFFF4F5FB);

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _search = '';

  /// `true` = Archiv-Ansicht (ausgetretene/deaktivierte Fahrer).
  bool _showArchived = false;
  /// Sortierung der DA-Balance-Liste. Standard bleibt alphabetisch —
  /// wer nach Ueberstunden sucht, schaltet bewusst um.
  _DaSort _sort = _DaSort.name;

  Future<List<_DriverAbsenceProfile>>? _future;

  /// Aufgelöster DSP-Scope (`dspUid`, sonst eigene UID). Wird von
  /// [_load] gesetzt und vom „Zeitkonto verwalten"-Dialog gebraucht.
  String? _scope;

  /// Firmenname aus `users/{scope}` — Kopfzeile und Dateiname des
  /// PDF-Exports. Leer, solange [_load] nicht durch ist.
  String _companyName = '';

  /// Verhindert doppelte Exporte bei schnellen Mehrfach-Klicks.
  bool _exportingPdf = false;

  TabController? _tabController;
  int? _lastTabIndex;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = DefaultTabController.maybeOf(context);
    if (identical(controller, _tabController)) return;
    _tabController?.removeListener(_handleTabChanged);
    _tabController = controller;
    _lastTabIndex = controller?.index;
    _tabController?.addListener(_handleTabChanged);
  }

  /// Lädt neu, sobald der Tab-Wechsel auf diesen Tab abgeschlossen ist.
  void _handleTabChanged() {
    final controller = _tabController;
    if (controller == null || controller.indexIsChanging) return;
    if (controller.index == _lastTabIndex) return;
    _lastTabIndex = controller.index;
    if (controller.index != widget.tabIndex) return;
    _reload();
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChanged);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Gleiche Scope-Auflösung wie [AdminShiftAbsencePage]: eigener UID,
  /// sofern kein `dspUid` im Benutzerdokument hinterlegt ist.
  Future<String?> _resolveScope() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    try {
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final dspUid = ((snap.data() ?? const {})['dspUid'] ?? '')
          .toString()
          .trim();
      return dspUid.isEmpty ? uid : dspUid;
    } catch (_) {
      return uid;
    }
  }

  Future<List<_DriverAbsenceProfile>> _load() async {
    final scope = await _resolveScope();
    if (scope == null) return const [];
    if (mounted && _scope != scope) {
      // Kein setState: der FutureBuilder rebuildet ohnehin, sobald
      // dieses Future auflöst — und genau dann ist der Button aktiv.
      _scope = scope;
    }
    final db = FirebaseFirestore.instance;

    final driversSnap =
        await db.collection('users').doc(scope).collection('drivers').get();
    final absSnap = await db
        .collection('users')
        .doc(scope)
        .collection('absence_requests')
        .get();
    // Urlaubs-Töpfe des DSP (ohne Konfiguration: Ein-Topf-Bestandslogik).
    final poolsConfig = await VacationPoolsRepository.load(scope);

    // Ticket „TIME & BALANCE": Tages-Sollstunden aus derselben Quelle,
    // die auch `computeMonthlyAccount` nutzt.
    final scopeSnap = await db.collection('users').doc(scope).get();
    final scopeData = scopeSnap.data() ?? const <String, dynamic>{};
    final dailyContractMinutes = _dailyContractMinutesOf(scopeData);
    // Firmenname für den PDF-Kopf — gleiche Feldkette wie im
    // Vorschuss-PDF (`driver_da_requests_view.dart`).
    _companyName = _AbsenceAdminItem._firstNonEmpty([
      (scopeData['companyName'] ?? '').toString(),
      (scopeData['dspName'] ?? '').toString(),
      (scopeData['company'] ?? '').toString(),
    ]);

    // Anträge einmal nach Transporter-ID gruppieren (Fallback driverId,
    // damit auch Bestandsdaten ohne `driverTransporterId` landen).
    final byDriver = <String, List<_AbsenceAdminItem>>{};
    for (final doc in absSnap.docs) {
      final data = doc.data();
      // Soft-gelöschte Einträge zählen auch im DA-Balance-Blatt nicht
      // mehr mit (gleiche Regel wie in `_splitAbsenceBuckets`).
      if (data['deleted'] == true) continue;
      final tid = ((data['driverTransporterId'] ?? data['driverId'] ?? '')
              .toString())
          .trim()
          .toUpperCase();
      if (tid.isEmpty) continue;
      (byDriver[tid] ??= <_AbsenceAdminItem>[])
          .add(_AbsenceAdminItem.fromDoc(doc));
    }

    final out = <_DriverAbsenceProfile>[];
    for (final doc in driversSnap.docs) {
      final data = doc.data();
      // Archivierte DAs werden mitgeladen und in der Ansicht ueber den
      // Archiv-Umschalter getrennt (Ticket „DA balance: show ARCHIVE
      // employees"). Quelle der Aktiv-Kennung wie im Drivers Hub.
      final isActive = isDriverWorking(data);
      final tid =
          ((data['transporterId'] ?? doc.id).toString()).trim().toUpperCase();
      if (tid.isEmpty) continue;
      final items = byDriver[tid] ?? const <_AbsenceAdminItem>[];
      final sorted = items.toList()
        // Gleiche Sortierung wie im Rest der Seite: `historySortDate`
        // (Storno-, sonst Prüf-, sonst Einreichzeitpunkt), neueste
        // zuerst — nicht das Antragsdatum.
        ..sort((a, b) => b.historySortDate.compareTo(a.historySortDate));

      // ── Onboarding-Felder für die PTO-Balance ──
      // Alle Leser stammen aus `utils/vacation_pools.dart`, damit hier
      // keine zweite Parse-Implementierung entsteht.
      final rawOnboarding = data['onboarding'];
      final onboarding = rawOnboarding is Map
          ? rawOnboarding.map((k, v) => MapEntry(k.toString(), v))
          : const <String, dynamic>{};

      final annual = annualVacationDaysOf(onboarding);
      final override = vacationOverrideOf(onboarding);
      final overrideAt = vacationOverrideAtOf(onboarding);

      // ── Vertragszeitraum (laufender, sonst jüngster) ──
      final periods = employmentPeriodsOf(data);
      final current = currentEmploymentPeriod(periods);
      final start = current?.startDate;
      final end = current?.endDate;
      final periodText = start == null
          ? ''
          : '${formatShortDate(start)} – '
              '${end == null ? '∞' : formatShortDate(end)}';

      out.add(
        _DriverAbsenceProfile(
          driverId: tid,
          isActive: isActive,
          driverName: _AbsenceAdminItem._firstNonEmpty([
            (data['driverName'] ?? '').toString(),
            (data['name'] ?? '').toString(),
            (data['fullName'] ?? '').toString(),
            tid,
          ]),
          employeeNumber: (data['employeeNumber'] ?? '').toString().trim(),
          contractPeriodText: periodText,
          contractStart: start,
          contractEnd: end,
          vacation: sorted
              .where((it) => it.type != 'sick_leave')
              .toList(growable: false),
          sick: sorted
              .where((it) => it.type == 'sick_leave')
              .toList(growable: false),
          overtimeMonths: _overtimeMonthsOf(data),
          annualVacationDays: annual,
          workStartDate: parseVacationDate(onboarding['workStartDate']),
          vacationOverride: override,
          vacationOverrideAt: overrideAt,
          poolsConfig: poolsConfig.forDriver(onboarding),
          dailyContractMinutes: dailyContractMinutes,
        ),
      );
    }

    out.sort(
      (a, b) => a.driverName.toLowerCase().compareTo(b.driverName.toLowerCase()),
    );
    return out;
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final de = _de;
    return Container(
      color: _kPageBg,
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<_DriverAbsenceProfile>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                de
                    ? 'Fahrer konnten nicht geladen werden: ${snap.error}'
                    : 'Failed to load drivers: ${snap.error}',
              ),
            );
          }

          final all = snap.data ?? const <_DriverAbsenceProfile>[];
          // Aktive und archivierte Fahrer sind zwei getrennte Ansichten —
          // der Umschalter oben entscheidet, welche gezeigt wird.
          final activeCount = all.where((d) => d.isActive).length;
          final archivedCount = all.length - activeCount;
          final scoped = all
              .where((d) => d.isActive != _showArchived)
              .toList(growable: false);
          final needle = _search.trim().toLowerCase();
          final matched = needle.isEmpty
              ? scoped
              : scoped
                  .where((d) =>
                      d.driverName.toLowerCase().contains(needle) ||
                      d.driverId.toLowerCase().contains(needle) ||
                      d.employeeNumber.toLowerCase().contains(needle))
                  .toList(growable: false);
          // Nach Ueberstunden sortieren heisst: nach dem Saldo, den die
          // Zeile auch anzeigt (erfasste Monate minus unbezahltem
          // Urlaub) — sonst weicht die Reihenfolge vom sichtbaren Wert ab.
          final drivers = [...matched];
          switch (_sort) {
            case _DaSort.name:
              break; // _load() liefert bereits alphabetisch
            case _DaSort.overtimeDesc:
              drivers.sort((a, b) =>
                  b.overtimeBalanceMinutes.compareTo(a.overtimeBalanceMinutes));
            case _DaSort.overtimeAsc:
              drivers.sort((a, b) =>
                  a.overtimeBalanceMinutes.compareTo(b.overtimeBalanceMinutes));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          // Ticket RsRiTdR: DE wie EN „DA Balance".
                          'DA Balance',
                          style: TextStyle(
                            color: _kText,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          de
                              ? (_showArchived
                                  ? 'Archivierte DAs — Salden ausgetretener '
                                        'Fahrer bleiben nachvollziehbar. Auf '
                                        'einen Fahrer tippen für die '
                                        'komplette Historie.'
                                  : 'Aktive DAs mit Krankheitstagen, PTO- und Overtime-Balance — auf einen Fahrer tippen für die komplette Historie.')
                              : (_showArchived
                                  ? 'Archived DAs — balances of former '
                                        'drivers stay available. Tap a driver '
                                        'for the full history.'
                                  : 'Active DAs with sick days, PTO and overtime balance — tap a driver for the full history.'),
                          style: const TextStyle(
                            color: _kMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Ticket RsRiTdR / Review F1: „DA Balance" zeigt das
                  // Zeitkonto nur an — geschrieben (Excel-Import,
                  // manuelle Monatspflege, Monat löschen) und als PDF
                  // exportiert wird weiterhin im [ZeitkontoTab]. Der
                  // Zugang dorthin darf beim Tab-Merge nicht verloren
                  // gehen, deshalb dieser Button.
                  _ManageTimeAccountsButton(
                    enabled: _scope != null,
                    onPressed: _openZeitkontoManager,
                  ),
                  const SizedBox(width: 4),
                  // Ticket „DA balance PDF": exportiert exakt die gerade
                  // sichtbare Liste (Suche + Aktiv/Archiv-Umschalter).
                  _DaBalancePdfButton(
                    enabled: !_exportingPdf,
                    onPressed: () => _exportPdf(drivers),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: de ? 'Aktualisieren' : 'Refresh',
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _AbsenceSearchField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      onChanged: (value) {
                        if (_search == value) return;
                        setState(() => _search = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  _DaSortMenu(
                    value: _sort,
                    de: de,
                    onChanged: (v) => setState(() => _sort = v),
                  ),
                  const SizedBox(width: 10),
                  _ArchiveToggle(
                    showArchived: _showArchived,
                    activeCount: activeCount,
                    archivedCount: archivedCount,
                    de: de,
                    onChanged: (v) => setState(() => _showArchived = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _kBorder),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: drivers.isEmpty
                      ? _EmptyState(
                          title: de ? 'Keine Fahrer' : 'No drivers',
                          subtitle: _showArchived
                              ? (de
                                  ? 'Im Archiv gibt es dazu keinen Fahrer.'
                                  : 'No archived driver matches this.')
                              : (de
                                  ? 'Für diese Suche gibt es keinen aktiven Fahrer.'
                                  : 'No active driver matches this search.'),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: drivers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) => _DriverRow(
                            profile: drivers[index],
                            onTap: () => _openDriverHistory(drivers[index]),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── PDF-Export „DA Balance" (Ticket: download as PDF) ──────────────
  //
  // Vorbild ist bewusst der Zeitkonto-Report in `zeitkonto_tab.dart`:
  // dieselben Pakete (`pdf` + `printing`), dieselbe PDF-Standardschrift
  // (Helvetica, Latin-1 — deshalb [_daPdfSafe] für alle Texte) und
  // derselbe Ausgabeweg `Printing.sharePdf` (im Web ein Download, auf
  // Mobile das Share-Sheet).

  /// Exportiert GENAU die übergebene Liste — also die Ansicht inklusive
  /// Suchbegriff und Aktiv/Archiv-Umschalter.
  Future<void> _exportPdf(List<_DriverAbsenceProfile> drivers) async {
    final de = _de;
    final messenger = ScaffoldMessenger.of(context);
    if (drivers.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            de
                ? 'Keine Fahrer in dieser Ansicht — es gibt nichts zu '
                    'exportieren.'
                : 'No drivers in this view — nothing to export.',
          ),
        ),
      );
      return;
    }
    if (_exportingPdf) return;
    setState(() => _exportingPdf = true);
    final archived = _showArchived;
    try {
      final bytes = await _buildBalancePdf(drivers, de: de, archived: archived);
      final stamp = formatIsoDate(DateTime.now());
      final company = _companyName.isEmpty ? 'codriver' : _companyName;
      final slug = _daPdfSafe(company)
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'da-balance_'
            '${slug.isEmpty ? 'codriver' : slug}_'
            '${archived ? 'archiv_' : ''}$stamp.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            de
                ? 'PDF konnte nicht erstellt werden: $e'
                : 'Could not create the PDF: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  Future<Uint8List> _buildBalancePdf(
    List<_DriverAbsenceProfile> drivers, {
    required bool de,
    required bool archived,
  }) async {
    final doc = pw.Document();
    final brand = PdfColor.fromInt(0xFF00B287);
    final brandDeep = PdfColor.fromInt(0xFF006047);
    final ink = PdfColor.fromInt(0xFF111827);
    final muted = PdfColor.fromInt(0xFF6B7280);
    final soft = PdfColor.fromInt(0xFFF3F6F7);
    final line = PdfColor.fromInt(0xFFE5E7EB);
    final danger = PdfColor.fromInt(0xFFB91C1C);

    final today = DateTime.now();
    final todayText = DateFormat('dd.MM.yyyy').format(today);
    String dateText(DateTime d) => DateFormat('dd.MM.yyyy').format(d);

    // Fußnoten nur setzen, wenn sie in dieser Liste auch vorkommen.
    final hasEnded = drivers.any((d) => d.contractEndedBy(today));
    final hasOverride =
        drivers.any((d) => d.vacationBalance.overrideApplied);

    pw.Widget cell(
      String text, {
      bool bold = false,
      PdfColor? color,
      pw.TextAlign align = pw.TextAlign.left,
      double size = 8,
    }) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: pw.Text(
            _daPdfSafe(text),
            textAlign: align,
            style: pw.TextStyle(
              fontSize: size,
              color: color ?? ink,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        );

    pw.Widget headerCell(String text, {pw.TextAlign align = pw.TextAlign.left}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          child: pw.Text(
            _daPdfSafe(text),
            textAlign: align,
            style: pw.TextStyle(
              fontSize: 7.5,
              color: muted,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );

    final headers = de
        ? const [
            'Fahrer',
            'Personalnr.',
            'Transporter-ID',
            'Vertragszeitraum',
            'Gerechnet bis',
            'Krankheits-\ntage',
            'Urlaub\ngenommen',
            'Urlaub\nAnspruch',
            'Rest',
            'davon\nunbezahlt',
            'Überstunden-\nSaldo',
          ]
        : const [
            'Driver',
            'Employee no.',
            'Transporter ID',
            'Contract period',
            'Counted until',
            'Sick leave\ndays',
            'Vacation\ntaken',
            'Vacation\nentitlement',
            'Remaining',
            'thereof\nunpaid',
            'Overtime\nbalance',
          ];

    final rows = <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        decoration: pw.BoxDecoration(color: soft),
        children: [
          for (var i = 0; i < headers.length; i++)
            headerCell(
              headers[i],
              align: i >= 5 ? pw.TextAlign.right : pw.TextAlign.left,
            ),
        ],
      ),
    ];

    var sumSick = 0;
    var sumTaken = 0.0;
    var sumUnpaid = 0;

    for (final d in drivers) {
      final balance = d.vacationBalance;
      final taken = balance.totalUsed;
      final entitlement = balance.totalEntitlement;
      final remaining = d.ptoBalanceDays;
      final ended = d.contractEndedBy(today);
      final reference = d.balanceReferenceDate(today);
      final overtime = d.overtimeBalanceMinutes;

      sumSick += d.approvedSickDays;
      sumTaken += taken;
      sumUnpaid += d.approvedUnpaidVacationDays;

      // Zweite Zeile der „Rest"-Spalte. Ein negativer Saldo heißt
      // „zu viel genommen" — „-3 Tage übrig" läse sich falsch.
      final restLine = remaining < 0
          ? (de
              ? '${_daFormatDays(-remaining)} Tage zu viel'
              : '${_daFormatDays(-remaining)} days over')
          : (de
              ? '${_daFormatDays(remaining)} '
                  '${remaining == 1 ? 'Tag' : 'Tage'} übrig'
              : '${_daFormatDays(remaining)} '
                  '${remaining == 1 ? 'day' : 'days'} left');

      final start = d.contractStart;
      final end = d.contractEnd;
      // Zweizeilig, sonst passen zwei volle Daten nicht in die Spalte.
      final periodText = start == null
          ? (d.contractPeriodText.isEmpty ? '-' : d.contractPeriodText)
          : '${dateText(start)}\n${de ? 'bis' : 'to'} '
              '${end == null ? (de ? 'offen' : 'open') : dateText(end)}';

      rows.add(
        pw.TableRow(
          children: [
            cell(d.driverName, bold: true),
            cell(d.employeeNumber.isEmpty ? '-' : d.employeeNumber),
            // Transporter-IDs sind reine Versalien und damit breit —
            // eine halbe Stufe kleiner, sonst brechen sie um.
            cell(d.driverId, size: 7.5),
            cell(periodText),
            cell(
              '${dateText(reference)}\n'
              '${ended ? (de ? 'Vertragsende *' : 'contract end *') : (de ? 'heute' : 'today')}',
              color: ended ? brandDeep : muted,
            ),
            cell('${d.approvedSickDays}', align: pw.TextAlign.right),
            cell(_daFormatDays(taken), align: pw.TextAlign.right),
            cell(_daFormatDays(entitlement), align: pw.TextAlign.right),
            cell(
              '${_daFormatDays(taken)} / ${_daFormatDays(entitlement)}\n'
              '$restLine',
              bold: true,
              align: pw.TextAlign.right,
              color: remaining < 0 ? danger : ink,
            ),
            cell(
              d.approvedUnpaidVacationDays == 0
                  ? '-'
                  : '${d.approvedUnpaidVacationDays}',
              align: pw.TextAlign.right,
            ),
            cell(
              d.hasOvertime ? '${_daFormatDuration(overtime)} h' : '-',
              align: pw.TextAlign.right,
              bold: d.hasOvertime && overtime < 0,
              color: d.hasOvertime && overtime < 0 ? danger : ink,
            ),
          ],
        ),
      );
    }

    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: soft),
        children: [
          cell(
            de
                ? 'Summe — ${drivers.length} Fahrer'
                : 'Total — ${drivers.length} drivers',
            bold: true,
          ),
          cell(''),
          cell(''),
          cell(''),
          cell(''),
          cell('$sumSick', bold: true, align: pw.TextAlign.right),
          cell(_daFormatDays(sumTaken), bold: true, align: pw.TextAlign.right),
          cell(''),
          cell(''),
          cell(
            sumUnpaid == 0 ? '-' : '$sumUnpaid',
            bold: true,
            align: pw.TextAlign.right,
          ),
          cell(''),
        ],
      ),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 30),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            _daPdfSafe(
              de
                  ? '${_companyName.isEmpty ? 'CoDriver' : _companyName}  ·  '
                      'Seite ${ctx.pageNumber} von ${ctx.pagesCount}'
                  : '${_companyName.isEmpty ? 'CoDriver' : _companyName}  ·  '
                      'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            ),
            style: pw.TextStyle(fontSize: 7.5, color: muted),
          ),
        ),
        build: (ctx) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            color: brand,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DA Balance',
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  _daPdfSafe([
                    if (_companyName.isNotEmpty) _companyName,
                    de
                        ? (archived
                            ? 'Archivierte DAs'
                            : 'Aktive DAs')
                        : (archived ? 'Archived DAs' : 'Active DAs'),
                    de
                        ? 'Erstellt am $todayText'
                        : 'Created on $todayText',
                    de
                        ? '${drivers.length} Fahrer'
                        : '${drivers.length} drivers',
                  ].join('  |  ')),
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: soft,
              border: pw.Border.all(color: line),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  _daPdfSafe(
                    de
                        ? 'Urlaubsanspruch anteilig ab Vertragsbeginn, '
                            'gerechnet bis zum letzten Vertragstag. '
                            'Wochenenden und bundesweite Feiertage zählen '
                            'nicht als Urlaubstage. Berücksichtigt werden '
                            'nur genehmigte Anträge; unbezahlter Urlaub '
                            'belastet das Urlaubskonto nicht, wohl aber den '
                            'Überstunden-Saldo.'
                        : 'PTO entitlement accrues pro rata from the start '
                            'of the contract and is counted until the last '
                            'day of the contract. Weekends and nationwide '
                            'public holidays do not count as vacation days. '
                            'Only approved requests are included; unpaid '
                            'leave does not reduce the PTO pool, but it does '
                            'reduce the overtime balance.',
                  ),
                  style: pw.TextStyle(fontSize: 8, color: ink),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _daPdfSafe(
                    de
                        ? 'Spalte „Rest": genommene / zustehende Urlaubstage '
                            '(z. B. 12 / 21) mit den verbleibenden Tagen '
                            'darunter. Die Spalte „Gerechnet bis" nennt je '
                            'Fahrer den Stichtag der Auswertung.'
                        : 'Column "Remaining": PTO taken / PTO entitlement '
                            '(e.g. 12 / 21) with the remaining days below. '
                            'The column "Counted until" states the cut-off '
                            'date used for each driver.',
                  ),
                  style: pw.TextStyle(fontSize: 8, color: muted),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: line, width: 0.6),
              top: pw.BorderSide(color: line, width: 0.6),
              bottom: pw.BorderSide(color: line, width: 0.6),
            ),
            // Summe der festen Spalten = 632 pt; der Rest (~162 pt der
            // 794 pt Satzspiegel im Querformat) bleibt dem Namen.
            columnWidths: const {
              0: pw.FlexColumnWidth(),
              1: pw.FixedColumnWidth(50),
              2: pw.FixedColumnWidth(84),
              3: pw.FixedColumnWidth(74),
              4: pw.FixedColumnWidth(74),
              5: pw.FixedColumnWidth(50),
              6: pw.FixedColumnWidth(54),
              7: pw.FixedColumnWidth(52),
              8: pw.FixedColumnWidth(82),
              9: pw.FixedColumnWidth(50),
              10: pw.FixedColumnWidth(62),
            },
            children: rows,
          ),
          if (hasEnded || hasOverride) ...[
            pw.SizedBox(height: 8),
            if (hasEnded)
              pw.Text(
                _daPdfSafe(
                  de
                      ? '* Vertrag beendet — der Stichtag ist der letzte '
                          'Vertragstag. Die ausgewiesenen Werte entsprechen '
                          'exakt der Bildschirmansicht; der anteilige '
                          'Urlaubsanspruch wird dort systemseitig bis zum '
                          'aktuellen Tagesdatum fortgeschrieben.'
                      : '* Contract ended — the cut-off date is the last day '
                          'of the contract. The figures match the on-screen '
                          'view exactly; there the pro-rata PTO entitlement '
                          'keeps accruing up to the current date.',
                ),
                style: pw.TextStyle(fontSize: 7.5, color: muted),
              ),
            if (hasOverride) ...[
              pw.SizedBox(height: 3),
              pw.Text(
                _daPdfSafe(
                  de
                      ? 'Bei einzelnen Fahrern ist ein manueller Startwert '
                          '(Override) hinterlegt: „Urlaub Anspruch" zeigt '
                          'dann diesen Wert, „Urlaub genommen" nur die seit '
                          'der Erfassung genehmigten Tage.'
                      : 'Some drivers have a manual starting value '
                          '(override): "PTO entitlement" then shows that '
                          'value and "PTO taken" only the days approved '
                          'since it was set.',
                ),
                style: pw.TextStyle(fontSize: 7.5, color: muted),
              ),
            ],
          ],
        ],
      ),
    );

    return doc.save();
  }

  /// Öffnet den [ZeitkontoTab] als Vollbild-Dialog. Er ist der einzige
  /// Ort, an dem `overtimeAccount` geschrieben wird (Excel-Import,
  /// manuelle Monatspflege, Monat löschen) und an dem der
  /// Zeitkonto-PDF-Report entsteht. Nach dem Schließen wird die
  /// DA-Balance-Liste neu geladen, damit geänderte Overtime-Werte
  /// sofort sichtbar sind.
  Future<void> _openZeitkontoManager() async {
    final scope = _scope;
    if (scope == null) return;
    final de = _de;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: _kPageBg,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(18, 12, 10, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_calendar_outlined,
                    size: 20,
                    color: Color(0xFF006047),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      de
                          ? 'Zeitkonto verwalten'
                          : 'Manage time accounts',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _kText,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: de ? 'Schließen' : 'Close',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _kBorder),
            Expanded(child: ZeitkontoTab(dspUid: scope)),
          ],
        ),
      ),
    );
    // Import / manuelle Änderungen wirken sich direkt auf die
    // Overtime-Balance aus → neu laden.
    _reload();
  }

  Future<void> _openDriverHistory(_DriverAbsenceProfile profile) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: _DriverAbsenceHistoryView(
          profile: profile,
          company: _companyName,
        ),
      ),
    );
  }
}

/// Header-Aktion „Zeitkonto verwalten / Manage time accounts".
///
/// Ab 560 px mit sichtbarem Label (der Einstieg muss auffindbar sein —
/// er ist der einzige Weg zum Excel-Import und zum PDF-Report),
/// darunter platzsparend als Icon-Button mit Tooltip.
class _ManageTimeAccountsButton extends StatelessWidget {
  const _ManageTimeAccountsButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final label = de ? 'Zeitkonto verwalten' : 'Manage time accounts';
    final wide = MediaQuery.sizeOf(context).width >= 560;
    if (!wide) {
      return IconButton(
        tooltip: label,
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.edit_calendar_outlined),
      );
    }
    return Tooltip(
      message: de
          ? 'Soll-/Ist-Stunden importieren, Monate pflegen und den '
              'Zeitkonto-Report als PDF exportieren'
          : 'Import target/worked hours, edit months and export the '
              'time-account report as PDF',
      child: TextButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.edit_calendar_outlined, size: 18),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF006047),
          backgroundColor: const Color(0xFFE6F8F2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Header-Aktion „PDF" der DA-Balance-Ansicht (Ticket „DA balance:
/// option to download as PDF").
///
/// Gleiche Responsive-Regel wie [_ManageTimeAccountsButton]: ab 560 px
/// mit Label, darunter nur das Icon mit Tooltip.
class _DaBalancePdfButton extends StatelessWidget {
  const _DaBalancePdfButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final tooltip = de
        ? 'Aktuelle Liste als PDF exportieren — Krankheitstage, '
            'genommener und verfügbarer Urlaub, gerechnet bis zum '
            'letzten Vertragstag'
        : 'Export the current list as PDF — sick leave days, PTO taken '
            'and available, counted until the last day of the contract';
    final wide = MediaQuery.sizeOf(context).width >= 560;
    if (!wide) {
      return IconButton(
        tooltip: tooltip,
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.picture_as_pdf_outlined),
      );
    }
    return Tooltip(
      message: tooltip,
      child: TextButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
        // „PDF" ist in beiden Sprachen identisch — die zweisprachige
        // Erklärung steckt im Tooltip.
        label: const Text(
          'PDF',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF374151),
          backgroundColor: const Color(0xFFF3F4F6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Eine Zeile der „DA Balance"-Liste: Avatar/Initialen, Name,
/// Vertragszeitraum, Personalnr. + Transporter-ID und die drei
/// Kennzahlen — Krankheitstage, PTO-Balance und Overtime-Balance.
class _DriverRow extends StatelessWidget {
  const _DriverRow({required this.profile, required this.onTap});

  final _DriverAbsenceProfile profile;
  final VoidCallback onTap;

  /// Ab dieser Breite passen Stammdaten und Kennzahlen nebeneinander;
  /// darunter rutschen die Kennzahlen unter den Namen.
  static const double _kWideRow = 680;

  static String _initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final overtime = profile.overtimeBalanceMinutes;
    final hasOvertime = profile.hasOvertime;

    final metrics = <Widget>[
      _BalanceMetric(
        label: de ? 'Krankheitstage' : 'Sick leave days',
        value: '${profile.approvedSickDays}',
        unit: de ? 'Tage' : 'days',
        color: const Color(0xFFB45309),
        tooltip: de
            ? 'Genommene Krankheitstage — Summe aller genehmigten '
                'Krankmeldungen'
            : 'Number of sick leave days taken — sum of all approved '
                'sick leave',
      ),
      _BalanceMetric(
        // DE wie EN „PTO Balance" — der Kunde nutzt den Begriff so.
        label: 'PTO Balance',
        value: _daFormatDays(profile.ptoBalanceDays),
        unit: de ? 'Tage' : 'days',
        // Negativer Saldo (mehr genommen als erworben) in Rot.
        color: profile.ptoBalanceDays < 0
            ? const Color(0xFFB91C1C)
            : const Color(0xFF1D7F5A),
        tooltip: <String>[
          de
              ? 'Verbleibende BEZAHLTE Urlaubstage — anteilig nach '
                  'Beschäftigungsmonaten, abzüglich genehmigter bezahlter '
                  'Urlaubstage'
              : 'Remaining PAID vacation days — pro rata by months '
                  'employed, minus approved paid vacation days',
          // Bei aktivierten Töpfen die Aufteilung mit Verfallsdatum.
          if (profile.vacationBalance.pooled)
            for (final pool in profile.vacationBalance.pools)
              vacationPoolSummary(context, pool),
        ].join('\n'),
      ),
      _BalanceMetric(
        label: 'Overtime Balance',
        value: hasOvertime ? '${_daFormatDuration(overtime)} h' : '—',
        unit: null,
        color: !hasOvertime
            ? const Color(0xFF94A3B8)
            : (overtime < 0
                ? const Color(0xFFB91C1C)
                : const Color(0xFF006047)),
        tooltip: <String>[
          de
              ? 'Offene Überstunden (Ist − Soll − ausgezahlt), abzüglich '
                  'der Sollstunden unbezahlter Urlaubstage'
              : 'Open overtime (worked − target − paid out), minus the '
                  'target hours of unpaid vacation days',
          // Ticket „TIME & BALANCE": die Herkunft des Abzugs offenlegen,
          // sonst wirkt ein negativer Saldo unerklärlich.
          if (profile.unpaidVacationChargeMinutes > 0)
            de
                ? 'davon unbezahlter Urlaub: '
                    '${profile.approvedUnpaidVacationDays} Werktage × '
                    '${_daFormatDuration(profile.dailyContractMinutes)} h = '
                    '−${_daFormatDuration(profile.unpaidVacationChargeMinutes)} h'
                : 'thereof unpaid vacation: '
                    '${profile.approvedUnpaidVacationDays} working days × '
                    '${_daFormatDuration(profile.dailyContractMinutes)} h = '
                    '−${_daFormatDuration(profile.unpaidVacationChargeMinutes)} h',
        ].join('\n'),
      ),
    ];

    final identity = Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE4F5EC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _initialsOf(profile.driverName),
            style: const TextStyle(
              color: Color(0xFF1D7F5A),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profile.driverName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                profile.contractPeriodText.isEmpty
                    ? (de ? 'Kein Vertragszeitraum hinterlegt' : 'No contract period on file')
                    : profile.contractPeriodText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                [
                  if (profile.employeeNumber.isNotEmpty)
                    '${de ? 'Personalnr.' : 'Emp. no.'} ${profile.employeeNumber}',
                  'ID: ${profile.driverId}',
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Ticket „DA Balance": Gesamt-Anspruch seit Vertragsbeginn
              // direkt im Kopf. Auf schmalen Zeilen die Kurzfassung und
              // als eigenes Pill, damit nichts mehr abschneidet
              // (Ticket „TIME & BALANCE").
              if (profile.ptoHeaderLine(de) != null) ...[
                const SizedBox(height: 5),
                LayoutBuilder(
                  builder: (context, c) {
                    final compact = c.maxWidth < 260;
                    final negative = profile.ptoBalanceDays < 0;
                    final color = negative
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF1D7F5A);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        profile.ptoHeaderLine(de, compact: compact)!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 11.5,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= _kWideRow;
              if (wide) {
                return Row(
                  children: [
                    Expanded(flex: 5, child: identity),
                    const SizedBox(width: 12),
                    for (var i = 0; i < metrics.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      SizedBox(width: 132, child: metrics[i]),
                    ],
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: identity),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < metrics.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(child: metrics[i]),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Eine Kennzahl-Kachel der „DA Balance"-Zeile: Label, Wert, Einheit.
class _BalanceMetric extends StatelessWidget {
  const _BalanceMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.tooltip,
  });

  final String label;
  final String value;
  final String? unit;
  final Color color;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10.5,
                height: 1.2,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit!,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Wie viele Einträge je Sektion direkt im Fahrer-Dialog stehen. Alles
/// darüber liegt hinter „Mehr anzeigen" — gleiche Mechanik wie in den
/// Antragslisten der Haupt-Tabs (Ticket RsRiTdR).
const int _kDriverHistoryPreview = 3;

/// Überstunden zeigen bewusst einen Monat mehr — die Monatszeilen sind
/// kompakter und ein Quartal auf einen Blick ist hier nützlich.
const int _kDriverOvertimePreview = 4;

/// Popup mit ALLEN Einträgen einer Sektion. Bewusst schlank gehalten:
/// dieselben Zeilen-Widgets wie inline, nur ohne Limit.
Future<void> _openAllDriverEntries(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color accent,
  required List<Widget> children,
}) {
  final de = Localizations.localeOf(context).languageCode == 'de';
  final media = MediaQuery.sizeOf(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        width: math.max(280.0, math.min(560.0, media.width - 48)),
        height: math.max(300.0, media.height * 0.8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 10, 10),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: de ? 'Schließen' : 'Close',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                children: children,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Detail-Ansicht eines Fahrers: „Urlaub & Sonderurlaub (PTO)",
/// „Krankmeldungen" und „Überstunden / Overtime" — je Sektion nur die
/// jüngsten Einträge inline, der Rest per „Mehr anzeigen"-Popup.
class _DriverAbsenceHistoryView extends StatelessWidget {
  const _DriverAbsenceHistoryView({
    required this.profile,
    this.company = '',
  });

  final _DriverAbsenceProfile profile;

  /// Firmenname für die Kopfzeile des Fahrer-PDFs.
  final String company;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final media = MediaQuery.sizeOf(context);
    final width = math.max(280.0, math.min(640.0, media.width - 48));
    final height = math.max(300.0, media.height * 0.86);

    final subtitleParts = <String>[
      if (profile.employeeNumber.isNotEmpty)
        '${de ? 'Personalnr.' : 'Emp. no.'} ${profile.employeeNumber}',
      'ID: ${profile.driverId}',
      if (profile.contractPeriodText.isNotEmpty) profile.contractPeriodText,
      de ? 'komplette Abwesenheits-Historie' : 'full absence history',
    ];
    // Der Urlaubsstand steht bewusst NICHT in der Untertitelzeile: die
    // ist auf zwei Zeilen begrenzt und schnitt ihn auf dem Handy ab
    // (Ticket „TIME & BALANCE"). Er bekommt darunter ein eigenes Pill.
    final ptoLine = profile.ptoHeaderLine(de);

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.driverName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitleParts.join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (ptoLine != null) ...[
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (profile.ptoBalanceDays < 0
                                    ? const Color(0xFFB91C1C)
                                    : const Color(0xFF1D7F5A))
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            ptoLine,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: profile.ptoBalanceDays < 0
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFF1D7F5A),
                              fontSize: 12,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Ticket „per employee profile": Blatt dieses Fahrers als
                // PDF — mit allen einzelnen Kranken- und Urlaubszeiträumen.
                // Beschriftet statt nur als Icon: als blosses Symbol neben
                // dem X wurde der Export schlicht uebersehen.
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 2),
                  child: TextButton.icon(
                    onPressed: () => exportDriverBalancePdf(
                      context: context,
                      profile: profile,
                      company: company,
                      de: de,
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('PDF'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1D7F5A),
                      backgroundColor: const Color(0xFF1D7F5A)
                          .withValues(alpha: 0.08),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 40),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: de ? 'Schließen' : 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(
            child: profile.isEmpty
                ? _EmptyState(
                    title: de ? 'Keine Abwesenheiten' : 'No absences',
                    subtitle: de
                        ? 'Für diesen Fahrer ist noch nichts erfasst.'
                        : 'Nothing recorded for this driver yet.',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    children: [
                      _DriverAbsenceCategory(
                        // Enthält bewusst auch Sonderurlaub — beides ist
                        // geplante Freizeit; die Art steht je Zeile.
                        title: de
                            ? 'Urlaub & Sonderurlaub (PTO)'
                            : 'Vacation & special leave (PTO)',
                        icon: Icons.beach_access_rounded,
                        accent: const Color(0xFF1D7F5A),
                        items: profile.vacation,
                        summary: de
                            ? 'Genehmigt gesamt: ${profile.approvedVacationDays} Tage'
                            : 'Approved total: ${profile.approvedVacationDays} days',
                        // Ticket KJV4n2S: unbezahlte Tage getrennt
                        // ausweisen — sie zehren kein Kontingent auf.
                        // Zusätzlich die PTO-Balance, damit der Dialog
                        // dieselbe Zahl zeigt wie die Listenzeile.
                        subSummary: [
                          if (profile.approvedUnpaidVacationDays > 0)
                            de
                                ? 'davon unbezahlt: ${profile.approvedUnpaidVacationDays} Tage'
                                : 'thereof unpaid: ${profile.approvedUnpaidVacationDays} days',
                          'PTO Balance: '
                              '${_daFormatDays(profile.ptoBalanceDays)} '
                              '${de ? 'Tage' : 'days'}',
                          // Getrennte Töpfe inkl. Verfallsdatum, sofern
                          // der DSP sie eingeschaltet hat.
                          if (profile.vacationBalance.pooled)
                            for (final pool in profile.vacationBalance.pools)
                              vacationPoolSummary(context, pool),
                        ].join(' · '),
                        emptyLabel: de
                            ? 'Kein Urlaub erfasst.'
                            : 'No vacation recorded.',
                      ),
                      const SizedBox(height: 18),
                      _DriverAbsenceCategory(
                        title: de ? 'Krankmeldungen' : 'Sick leave',
                        icon: Icons.sick_rounded,
                        accent: const Color(0xFFB45309),
                        items: profile.sick,
                        summary: de
                            ? 'Genehmigt gesamt: ${profile.approvedSickDays} Tage'
                            : 'Approved total: ${profile.approvedSickDays} days',
                        emptyLabel: de
                            ? 'Keine Krankmeldung erfasst.'
                            : 'No sick leave recorded.',
                      ),
                      const SizedBox(height: 18),
                      // Ticket RsRiTdR: dritte Sektion — das frühere
                      // „Zeitkonto" pro Monat, jetzt im Fahrer-Blatt.
                      _DriverOvertimeCategory(profile: profile),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _DriverAbsenceCategory extends StatelessWidget {
  const _DriverAbsenceCategory({
    required this.title,
    required this.icon,
    required this.accent,
    required this.items,
    required this.summary,
    required this.emptyLabel,
    this.subSummary,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<_AbsenceAdminItem> items;
  final String summary;
  final String? subSummary;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final preview = items.take(_kDriverHistoryPreview).toList(growable: false);
    final hidden = items.length - preview.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DriverSectionHeader(
          title: title,
          icon: icon,
          accent: accent,
          count: items.length,
        ),
        const SizedBox(height: 10),
        _DriverSectionSummary(
          accent: accent,
          summary: summary,
          subSummary: subSummary,
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Text(
            emptyLabel,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          )
        else ...[
          for (var i = 0; i < preview.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _DriverAbsenceEntryTile(item: preview[i], de: de),
          ],
          if (hidden > 0) ...[
            const SizedBox(height: 4),
            _ShowMoreButton(
              label: de
                  ? 'Mehr anzeigen (+$hidden)'
                  : 'Show more (+$hidden)',
              onTap: () => _openAllDriverEntries(
                context,
                title: title,
                icon: icon,
                accent: accent,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _DriverAbsenceEntryTile(item: items[i], de: de),
                  ],
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Dritte Sektion des Fahrer-Dialogs: Überstunden je Monat aus dem
/// `overtimeAccount` des Fahrer-Dokuments — neueste zuerst.
class _DriverOvertimeCategory extends StatelessWidget {
  const _DriverOvertimeCategory({required this.profile});

  final _DriverAbsenceProfile profile;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    const accent = Color(0xFF006047);
    final months = profile.overtimeMonths;
    final preview = months.take(_kDriverOvertimePreview).toList(growable: false);
    final hidden = months.length - preview.length;
    final total = profile.overtimeBalanceMinutes;
    final unpaidCharge = profile.unpaidVacationChargeMinutes;
    final subSummaryLines = <String>[
      if (months.isNotEmpty)
        de
            ? 'über ${months.length} erfasste Monate (Ist − Soll − '
                'ausgezahlt): '
                '${_daFormatDuration(profile.recordedOvertimeMinutes)} h'
            : 'across ${months.length} recorded months (worked − target − '
                'paid out): '
                '${_daFormatDuration(profile.recordedOvertimeMinutes)} h',
      if (unpaidCharge > 0)
        de
            ? 'abzüglich unbezahlter Urlaub: '
                '${profile.approvedUnpaidVacationDays} Werktage × '
                '${_daFormatDuration(profile.dailyContractMinutes)} h = '
                '−${_daFormatDuration(unpaidCharge)} h'
            : 'minus unpaid vacation: '
                '${profile.approvedUnpaidVacationDays} working days × '
                '${_daFormatDuration(profile.dailyContractMinutes)} h = '
                '−${_daFormatDuration(unpaidCharge)} h',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DriverSectionHeader(
          title: de ? 'Überstunden / Overtime' : 'Overtime',
          icon: Icons.timelapse_rounded,
          accent: accent,
          count: months.length,
        ),
        const SizedBox(height: 10),
        _DriverSectionSummary(
          accent: total < 0 ? const Color(0xFFB91C1C) : accent,
          summary: de
              ? 'Gesamtsaldo: ${_daFormatDuration(total)} h'
              : 'Total balance: ${_daFormatDuration(total)} h',
          // Ticket „TIME & BALANCE": unbezahlter Urlaub wird als eigener
          // Posten ausgewiesen, damit der Abzug nachvollziehbar bleibt.
          subSummary: subSummaryLines.isEmpty
              ? null
              : subSummaryLines.join('\n'),
        ),
        const SizedBox(height: 10),
        if (months.isEmpty)
          Text(
            de
                ? 'Kein Zeitkonto erfasst.'
                : 'No time account recorded.',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          )
        else ...[
          for (var i = 0; i < preview.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _DriverOvertimeTile(month: preview[i], de: de),
          ],
          if (hidden > 0) ...[
            const SizedBox(height: 4),
            _ShowMoreButton(
              label:
                  de ? 'Mehr anzeigen (+$hidden)' : 'Show more (+$hidden)',
              onTap: () => _openAllDriverEntries(
                context,
                title: de ? 'Überstunden / Overtime' : 'Overtime',
                icon: Icons.timelapse_rounded,
                accent: accent,
                children: [
                  for (var i = 0; i < months.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _DriverOvertimeTile(month: months[i], de: de),
                  ],
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Kopfzeile einer Sektion: Icon, Titel und Anzahl der Einträge.
class _DriverSectionHeader extends StatelessWidget {
  const _DriverSectionHeader({
    required this.title,
    required this.icon,
    required this.accent,
    required this.count,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

/// Summenzeile je Sektion — es zählen nur genehmigte Einträge.
class _DriverSectionSummary extends StatelessWidget {
  const _DriverSectionSummary({
    required this.accent,
    required this.summary,
    required this.subSummary,
  });

  final Color accent;
  final String summary;
  final String? subSummary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary,
            style: TextStyle(
              color: accent,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subSummary != null) ...[
            const SizedBox(height: 3),
            Text(
              subSummary!,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Eine Zeile der Fahrer-Historie: Zeitraum, Tage, Status und — beim
/// Urlaub — bezahlt/unbezahlt.
class _DriverAbsenceEntryTile extends StatelessWidget {
  const _DriverAbsenceEntryTile({required this.item, required this.de});

  final _AbsenceAdminItem item;
  final bool de;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.fromDateText} – ${item.toDateText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.typeLabel(de)} · ${item.daysLabel(de)}'
                  '${item.hasPaidFlag ? ' · ${item.paidLabel(de)}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Ticket „TIME & ABSENCE - HISTORY": Ablehngrund auch im
                // Fahrer-Blatt sichtbar.
                if (item.rejectionReason.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${de ? 'Grund' : 'Reason'}: ${item.rejectionReason}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFB91C1C),
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusChip(status: item.status),
        ],
      ),
    );
  }
}

/// Eine Monatszeile der Überstunden-Sektion: Monat, Soll/Target,
/// Ist/Worked und die Überstunden des Monats als Stundenwert.
class _DriverOvertimeTile extends StatelessWidget {
  const _DriverOvertimeTile({required this.month, required this.de});

  final _DriverOvertimeMonth month;
  final bool de;

  @override
  Widget build(BuildContext context) {
    final overtime = month.overtimeMinutes;
    final negative = overtime < 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  month.monthLabel(de),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${de ? 'Soll' : 'Target'} '
                  '${_daFormatDuration(month.targetMinutes)} h · '
                  '${de ? 'Ist' : 'Worked'} '
                  '${_daFormatDuration(month.workedMinutes)} h'
                  '${month.paidMinutes != 0 ? ' · ${de ? 'ausgezahlt' : 'paid out'} ${_daFormatDuration(month.paidMinutes)} h' : ''}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: negative
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFE6F8F2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'O/T ${_daFormatDuration(overtime)} h',
              style: TextStyle(
                color: negative
                    ? const Color(0xFFB91C1C)
                    : const Color(0xFF006047),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Umschalter „Aktiv ↔ Archiv" über der DA-Balance-Liste.
///
/// Archivierte Fahrer wurden früher gar nicht geladen; ihre Urlaubs- und
/// Überstundensalden waren nach dem Austritt nicht mehr einsehbar. Der
/// Umschalter blendet sie auf Wunsch ein, ohne die Alltagsansicht zu
/// überfrachten — Vorgabe bleibt „Aktiv".
/// Sortierung der DA-Balance-Liste.
enum _DaSort {
  /// Alphabetisch nach Fahrername (Standard).
  name,

  /// Meiste Ueberstunden zuerst.
  overtimeDesc,

  /// Wenigste zuerst — zeigt zugleich die Minusstunden ganz oben.
  overtimeAsc,
}

/// Sortier-Auswahl neben dem Archiv-Umschalter.
///
/// Bewusst ein Menue und keine dritte Segment-Leiste: die Kopfzeile
/// traegt schon Suche und Aktiv/Archiv, eine weitere Leiste wuerde auf
/// dem Handy umbrechen.
class _DaSortMenu extends StatelessWidget {
  const _DaSortMenu({
    required this.value,
    required this.de,
    required this.onChanged,
  });

  final _DaSort value;
  final bool de;
  final ValueChanged<_DaSort> onChanged;

  String _label(_DaSort sort) {
    switch (sort) {
      case _DaSort.name:
        return de ? 'Name A–Z' : 'Name A–Z';
      case _DaSort.overtimeDesc:
        return de ? 'Überstunden: meiste zuerst' : 'Overtime: most first';
      case _DaSort.overtimeAsc:
        return de ? 'Überstunden: wenigste zuerst' : 'Overtime: fewest first';
    }
  }

  String _shortLabel(_DaSort sort) {
    switch (sort) {
      case _DaSort.name:
        return de ? 'Name' : 'Name';
      case _DaSort.overtimeDesc:
        return de ? 'Meiste Ü-Std.' : 'Most OT';
      case _DaSort.overtimeAsc:
        return de ? 'Wenigste Ü-Std.' : 'Fewest OT';
    }
  }

  IconData _icon(_DaSort sort) {
    switch (sort) {
      case _DaSort.name:
        return Icons.sort_by_alpha_rounded;
      case _DaSort.overtimeDesc:
        return Icons.arrow_downward_rounded;
      case _DaSort.overtimeAsc:
        return Icons.arrow_upward_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = value != _DaSort.name;
    return PopupMenuButton<_DaSort>(
      tooltip: de ? 'Sortieren' : 'Sort',
      initialValue: value,
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => _DaSort.values
          .map(
            (sort) => PopupMenuItem<_DaSort>(
              value: sort,
              child: Row(
                children: [
                  Icon(
                    _icon(sort),
                    size: 18,
                    color: sort == value
                        ? const Color(0xFF111827)
                        : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _label(sort),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          sort == value ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon(value),
              size: 17,
              color: active ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 7),
            Text(
              _shortLabel(value),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.expand_more_rounded,
              size: 17,
              color: active ? Colors.white : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveToggle extends StatelessWidget {
  const _ArchiveToggle({
    required this.showArchived,
    required this.activeCount,
    required this.archivedCount,
    required this.de,
    required this.onChanged,
  });

  final bool showArchived;
  final int activeCount;
  final int archivedCount;
  final bool de;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment({
      required String label,
      required int count,
      required bool active,
      required VoidCallback onTap,
    }) {
      return Material(
        color: active ? const Color(0xFF111827) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: active ? null : onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              '$label $count',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment(
            label: de ? 'Aktiv' : 'Active',
            count: activeCount,
            active: !showArchived,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 3),
          segment(
            label: de ? 'Archiv' : 'Archive',
            count: archivedCount,
            active: showArchived,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  PDF je Fahrer (Ticket: „The data to be generated per employee profile")
// ═══════════════════════════════════════════════════════════════════════
//
// Der Listen-Export deckt die Übersicht ab; hier geht es um das Blatt
// EINES Fahrers — mit allen einzelnen Kranken- und Urlaubszeiträumen
// statt nur der Summen. Gleiche Bausteine wie dort: Pakete `pdf` +
// `printing`, PDF-Standardschrift (deshalb [_daPdfSafe] für jeden Text)
// und `Printing.sharePdf` als Ausgabeweg.

/// Erzeugt das Fahrerblatt und reicht es an den Browser weiter.
Future<void> exportDriverBalancePdf({
  required BuildContext context,
  required _DriverAbsenceProfile profile,
  required String company,
  required bool de,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final bytes = await _buildDriverBalancePdf(
      profile: profile,
      de: de,
      company: company,
    );
    final slug = _daPdfSafe(profile.driverName)
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'da-balance_'
          '${slug.isEmpty ? profile.driverId.toLowerCase() : slug}_'
          '${formatIsoDate(DateTime.now())}.pdf',
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          de
              ? 'PDF konnte nicht erstellt werden: $e'
              : 'Could not create the PDF: $e',
        ),
      ),
    );
  }
}

Future<Uint8List> _buildDriverBalancePdf({
  required _DriverAbsenceProfile profile,
  required bool de,
  required String company,
}) async {
  const ink = PdfColor.fromInt(0xFF111827);
  const muted = PdfColor.fromInt(0xFF6B7280);
  const line = PdfColor.fromInt(0xFFE5E7EB);
  const green = PdfColor.fromInt(0xFF1D7F5A);
  const red = PdfColor.fromInt(0xFFB91C1C);
  const zebra = PdfColor.fromInt(0xFFF7F8FA);

  final today = DateTime.now();
  final reference = profile.balanceReferenceDate(today);
  final ended = profile.contractEndedBy(today);
  final balance = profile.vacationBalance;

  String fmt(DateTime d) => formatShortDate(d);
  String days(double v) => _daFormatDays(v);

  pw.Widget label(String text) => pw.Text(
        _daPdfSafe(text),
        style: const pw.TextStyle(fontSize: 8, color: muted),
      );

  pw.Widget value(String text, {PdfColor? color, double size = 12}) => pw.Text(
        _daPdfSafe(text),
        style: pw.TextStyle(
          fontSize: size,
          color: color ?? ink,
          fontWeight: pw.FontWeight.bold,
        ),
      );

  /// Kennzahlen-Kachel im Kopf.
  pw.Widget metric(String title, String text, {PdfColor? color}) =>
      pw.Container(
        width: 122,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: line, width: 0.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [label(title), pw.SizedBox(height: 3), value(text, color: color)],
        ),
      );

  /// Tabelle über eine Abwesenheitsart.
  pw.Widget table({
    required String title,
    required List<_AbsenceAdminItem> items,
    required String emptyText,
    required bool showPaid,
  }) {
    final rows = items.where((i) => i.status == 'approved').toList()
      ..sort((a, b) => b.fromDate.compareTo(a.fromDate));
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 16),
        pw.Text(
          _daPdfSafe(title),
          style: pw.TextStyle(
            fontSize: 11,
            color: ink,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        if (rows.isEmpty)
          pw.Text(
            _daPdfSafe(emptyText),
            style: const pw.TextStyle(fontSize: 9, color: muted),
          )
        else
          pw.TableHelper.fromTextArray(
            headerHeight: 20,
            cellHeight: 18,
            headerDecoration: const pw.BoxDecoration(color: zebra),
            headerStyle: pw.TextStyle(
              fontSize: 8,
              color: muted,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8.5, color: ink),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
            },
            border: pw.TableBorder.all(color: line, width: 0.4),
            headers: <String>[
              de ? 'Zeitraum' : 'Period',
              de ? 'Tage' : 'Days',
              if (showPaid) (de ? 'Bezahlt' : 'Paid'),
              de ? 'Grund / Notiz' : 'Reason / note',
            ],
            data: <List<String>>[
              for (final r in rows)
                <String>[
                  _daPdfSafe('${fmt(r.fromDate)} - ${fmt(r.toDate)}'),
                  '${r.totalDays}',
                  if (showPaid)
                    _daPdfSafe(
                      r.hasPaidFlag
                          ? r.paidLabel(de)
                          : (de ? 'Bezahlt' : 'Paid'),
                    ),
                  _daPdfSafe(r.reason.trim()),
                ],
            ],
          ),
      ],
    );
  }

  final doc = pw.Document();
  final entitlement = balance.totalEntitlement;
  final taken = balance.totalUsed;
  final remaining = balance.totalRemainingSigned;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 32),
      footer: (ctx) => pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          _daPdfSafe(
            de
                ? 'Seite ${ctx.pageNumber} von ${ctx.pagesCount}'
                : 'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
          ),
          style: const pw.TextStyle(fontSize: 7.5, color: muted),
        ),
      ),
      build: (ctx) => [
        // ── Kopf ──
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  _daPdfSafe(profile.driverName),
                  style: pw.TextStyle(
                    fontSize: 18,
                    color: ink,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  _daPdfSafe(
                    <String>[
                      if (profile.employeeNumber.isNotEmpty)
                        '${de ? 'Personalnr.' : 'Emp. no.'} ${profile.employeeNumber}',
                      'ID: ${profile.driverId}',
                      if (profile.contractPeriodText.isNotEmpty)
                        '${de ? 'Vertrag' : 'Contract'} '
                            '${profile.contractPeriodText}',
                      // Ausgeschiedene Fahrer: das Vertragsende noch
                      // einmal ausgeschrieben, damit im Blatt nicht nur
                      // eine Zahlenspanne steht.
                      if (profile.contractEnd != null)
                        '${de ? 'Vertragsende' : 'Contract ended'}: '
                            '${fmt(profile.contractEnd!)}',
                    ].join('  ·  '),
                  ),
                  style: const pw.TextStyle(fontSize: 9, color: muted),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  _daPdfSafe(company.isEmpty ? 'CoDriver' : company),
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: ink,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  _daPdfSafe(
                    de
                        ? 'DA Balance · erstellt am ${fmt(today)}'
                        : 'DA balance · created on ${fmt(today)}',
                  ),
                  style: const pw.TextStyle(fontSize: 8, color: muted),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(color: line, height: 12),

        // ── Stichtag ──
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: zebra,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            _daPdfSafe(
              ended
                  ? (de
                      ? 'Alle Zahlen sind bis zum letzten Vertragstag am '
                          '${fmt(reference)} gerechnet. Nach dem Vertragsende '
                          'entsteht kein weiterer Urlaubsanspruch.'
                      : 'All figures are counted until the last day of the '
                          'contract on ${fmt(reference)}. No further holiday '
                          'entitlement accrues after the contract ends.')
                  : (de
                      ? 'Alle Zahlen sind bis heute (${fmt(reference)}) '
                          'gerechnet; der Vertrag laeuft weiter. Der '
                          'Urlaubsanspruch waechst anteilig ab Vertragsbeginn.'
                      : 'All figures are counted until today '
                          '(${fmt(reference)}); the contract is still running. '
                          'Entitlement accrues pro rata from the start date.'),
            ),
            style: const pw.TextStyle(fontSize: 8.5, color: ink),
          ),
        ),
        pw.SizedBox(height: 12),

        // ── Kennzahlen ──
        pw.Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            metric(
              // „PTO" versteht nicht jeder Mitarbeiter — im PDF
              // steht deshalb ueberall Urlaub bzw. Vacation.
              de ? 'Urlaub genommen' : 'Vacation taken',
              '${days(taken)} / ${days(entitlement)}',
            ),
            metric(
              de ? 'Urlaub verbleibend' : 'Vacation remaining',
              '${days(remaining)} ${de ? 'Tage' : 'days'}',
              color: remaining < 0 ? red : green,
            ),
            metric(
              de ? 'davon unbezahlt' : 'thereof unpaid',
              '${profile.approvedUnpaidVacationDays} ${de ? 'Tage' : 'days'}',
            ),
            metric(
              de ? 'Krankheitstage' : 'Sick leave days',
              '${profile.approvedSickDays} ${de ? 'Tage' : 'days'}',
            ),
            metric(
              de ? 'Ueberstunden' : 'Overtime',
              profile.hasOvertime
                  ? '${_daFormatDuration(profile.overtimeBalanceMinutes)} h'
                  : '-',
              color: profile.overtimeBalanceMinutes < 0 ? red : null,
            ),
          ],
        ),

        // ── Monatsübersicht Soll / Ist ──
        //
        // Kundenwunsch: „für jeden Monat aufgelistet die Soll- und
        // Iststunden und die Differenz". Quelle ist dasselbe Zeitkonto,
        // aus dem auch der Überstunden-Saldo oben stammt.
        _overtimeMonthsTable(profile: profile, de: de),

        // ── Einzelposten ──
        table(
          title: de
              ? 'Urlaub & Sonderurlaub (genehmigt)'
              : 'Vacation & special leave (approved)',
          items: profile.vacation,
          emptyText: de ? 'Kein Urlaub erfasst.' : 'No vacation recorded.',
          showPaid: true,
        ),
        table(
          title: de ? 'Krankmeldungen (genehmigt)' : 'Sick leave (approved)',
          items: profile.sick,
          emptyText:
              de ? 'Keine Krankmeldung erfasst.' : 'No sick leave recorded.',
          showPaid: false,
        ),

        pw.SizedBox(height: 14),
        pw.Text(
          _daPdfSafe(
            de
                ? 'Wochenenden und bundesweite Feiertage zaehlen nicht als '
                    'Urlaubstage. Krankmeldungen werden kalendarisch gezaehlt.'
                : 'Weekends and nationwide public holidays do not count as '
                    'holiday. Sick leave is counted in calendar days.',
          ),
          style: const pw.TextStyle(fontSize: 7.5, color: muted),
        ),
        if (balance.overrideApplied)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(
              _daPdfSafe(
                de
                    ? 'Fuer diesen Fahrer wurde der Resturlaub manuell '
                        'gesetzt; "genommen" zaehlt ab diesem Zeitpunkt.'
                    : 'Remaining holiday was set manually for this driver; '
                        '"taken" counts from that point on.',
              ),
              style: const pw.TextStyle(fontSize: 7.5, color: muted),
            ),
          ),
      ],
    ),
  );

  return doc.save();
}

/// Monatsweise Gegenüberstellung von Soll- und Iststunden für das
/// Fahrer-PDF.
///
/// Zeigt je Monat: Sollstunden, Iststunden, Differenz (Ist − Soll),
/// bereits ausgezahlte Überstunden und den daraus offenen Rest — genau
/// die Rechnung, die auch den Saldo oben im Blatt ergibt. Ohne erfasste
/// Monate erscheint statt der Tabelle ein Hinweis, damit im PDF nicht
/// stillschweigend ein Block fehlt.
pw.Widget _overtimeMonthsTable({
  required _DriverAbsenceProfile profile,
  required bool de,
}) {
  const ink = PdfColor.fromInt(0xFF111827);
  const muted = PdfColor.fromInt(0xFF6B7280);
  const line = PdfColor.fromInt(0xFFE5E7EB);
  const zebra = PdfColor.fromInt(0xFFF3F4F6);
  const white = PdfColor.fromInt(0xFFFFFFFF);
  const headerBg = PdfColor.fromInt(0xFFE8EAED);
  const green = PdfColor.fromInt(0xFF1D7F5A);
  const red = PdfColor.fromInt(0xFFB91C1C);

  /// Plusstunden gruen, Minusstunden rot, glatte Null neutral.
  PdfColor signColor(int minutes) {
    if (minutes > 0) return green;
    if (minutes < 0) return red;
    return ink;
  }

  pw.Widget headerCell(String text, {bool left = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: pw.Text(
          _daPdfSafe(text),
          textAlign: left ? pw.TextAlign.left : pw.TextAlign.right,
          style: pw.TextStyle(
            fontSize: 8,
            color: muted,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );

  /// Von wann bis wann dieser Monat gezaehlt wurde.
  ///
  /// Normalerweise der ganze Monat; im ersten Monat ab Vertragsbeginn und
  /// im letzten ab-/bis zum Vertragsende. Ohne diese Zeile ist im PDF
  /// nicht erkennbar, warum ein Rumpfmonat weniger Sollstunden hat.
  String? countedRange(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length < 2) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (y == null || m == null) return null;

    final monthStart = DateTime(y, m, 1);
    final monthEnd = DateTime(y, m + 1, 0);
    var from = monthStart;
    var to = monthEnd;

    final start = profile.contractStart;
    if (start != null && start.isAfter(from)) from = start;
    final end = profile.contractEnd;
    if (end != null && end.isBefore(to)) to = end;

    if (to.isBefore(from)) return null;
    // Voller Monat: keine Zusatzzeile, das waere nur Rauschen.
    if (from == monthStart && to == monthEnd) return null;

    String d(DateTime v) =>
        '${v.day.toString().padLeft(2, '0')}.${v.month.toString().padLeft(2, '0')}.';
    return '${d(from)} - ${d(to)}';
  }

  pw.Widget monthCell(String label, String? range) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: <pw.Widget>[
            pw.Text(
              _daPdfSafe(label),
              style: const pw.TextStyle(fontSize: 8.5, color: ink),
            ),
            if (range != null)
              pw.Text(
                _daPdfSafe(
                  de ? 'gezaehlt $range' : 'counted $range',
                ),
                style: const pw.TextStyle(fontSize: 7, color: muted),
              ),
          ],
        ),
      );

  pw.Widget cell(
    String text, {
    bool left = false,
    PdfColor? color,
    bool bold = false,
  }) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: pw.Text(
          _daPdfSafe(text),
          textAlign: left ? pw.TextAlign.left : pw.TextAlign.right,
          style: pw.TextStyle(
            fontSize: 8.5,
            color: color ?? ink,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );

  final months = profile.overtimeMonths.toList()
    // Neuester Monat zuerst — wie in der Bildschirmansicht.
    ..sort((a, b) => b.month.compareTo(a.month));

  String hhmm(int minutes) => _daFormatDuration(minutes);

  final title = de
      ? 'Arbeitszeit je Monat (Soll / Ist)'
      : 'Working time per month (target / actual)';

  if (months.isEmpty) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 16),
        pw.Text(
          _daPdfSafe(title),
          style: pw.TextStyle(
            fontSize: 11,
            color: ink,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          _daPdfSafe(
            de
                ? 'Fuer diesen Fahrer ist kein Zeitkonto erfasst.'
                : 'No time account recorded for this driver.',
          ),
          style: const pw.TextStyle(fontSize: 9, color: muted),
        ),
      ],
    );
  }

  final totalTarget =
      months.fold<int>(0, (acc, m) => acc + m.targetMinutes);
  final totalWorked =
      months.fold<int>(0, (acc, m) => acc + m.workedMinutes);
  final totalPaid = months.fold<int>(0, (acc, m) => acc + m.paidMinutes);
  final totalDiff = totalWorked - totalTarget;
  final totalOpen = totalDiff - totalPaid;
  final unpaidCharge = profile.unpaidVacationChargeMinutes;

  String signed(int minutes) =>
      '${minutes < 0 ? '-' : ''}${hhmm(minutes.abs())}';

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 16),
      pw.Text(
        _daPdfSafe(title),
        style: pw.TextStyle(
          fontSize: 11,
          color: ink,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 6),
      // Von Hand gebaut statt ueber `TableHelper.fromTextArray`: nur so
      // laesst sich JEDE Zelle einzeln einfaerben — Plusstunden gruen,
      // Minusstunden rot — und die Zeilen abwechselnd hellgrau/weiss
      // hinterlegen. `fromTextArray` kennt nur einen Stil fuer alle Zellen.
      pw.Table(
        border: pw.TableBorder.all(color: line, width: 0.4),
        columnWidths: const <int, pw.TableColumnWidth>{
          0: pw.FlexColumnWidth(2.4),
          1: pw.FlexColumnWidth(1),
          2: pw.FlexColumnWidth(1),
          3: pw.FlexColumnWidth(1.1),
          4: pw.FlexColumnWidth(1.1),
          5: pw.FlexColumnWidth(1),
        },
        children: <pw.TableRow>[
          pw.TableRow(
            repeat: true,
            decoration: const pw.BoxDecoration(color: headerBg),
            children: <pw.Widget>[
              headerCell(de ? 'Monat' : 'Month', left: true),
              headerCell(de ? 'Soll' : 'Target'),
              headerCell(de ? 'Ist' : 'Actual'),
              headerCell(de ? 'Differenz' : 'Difference'),
              headerCell(de ? 'ausgezahlt' : 'paid out'),
              headerCell(de ? 'offen' : 'open'),
            ],
          ),
          for (var i = 0; i < months.length; i++)
            pw.TableRow(
              // Zebra: gerade Zeilen weiss, ungerade hellgrau.
              decoration: pw.BoxDecoration(color: i.isOdd ? zebra : white),
              children: <pw.Widget>[
                monthCell(
                  months[i].monthLabel(de),
                  countedRange(months[i].month),
                ),
                cell(hhmm(months[i].targetMinutes)),
                cell(hhmm(months[i].workedMinutes)),
                cell(
                  signed(months[i].overtimeMinutes),
                  color: signColor(months[i].overtimeMinutes),
                  bold: true,
                ),
                cell(hhmm(months[i].paidMinutes)),
                cell(
                  signed(months[i].remainingMinutes),
                  color: signColor(months[i].remainingMinutes),
                ),
              ],
            ),
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: headerBg),
            children: <pw.Widget>[
              cell(de ? 'Summe' : 'Total', left: true, bold: true),
              cell(hhmm(totalTarget), bold: true),
              cell(hhmm(totalWorked), bold: true),
              cell(
                signed(totalDiff),
                color: signColor(totalDiff),
                bold: true,
              ),
              cell(hhmm(totalPaid), bold: true),
              cell(
                signed(totalOpen),
                color: signColor(totalOpen),
                bold: true,
              ),
            ],
          ),
          // Unbezahlter Urlaub belastet das Konto (Ticket „TIME &
          // BALANCE"). Ohne diese Zeile ergaebe die Summenspalte nicht
          // den Saldo, der oben im Blatt steht.
          if (unpaidCharge > 0)
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: white),
              children: <pw.Widget>[
                cell(
                  de ? 'abzgl. unbezahlter Urlaub' : 'less unpaid leave',
                  left: true,
                ),
                cell(''),
                cell(''),
                cell(''),
                cell(''),
                cell(signed(-unpaidCharge), color: red),
              ],
            ),
          if (unpaidCharge > 0)
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: headerBg),
              children: <pw.Widget>[
                cell(de ? 'Saldo' : 'Balance', left: true, bold: true),
                cell(''),
                cell(''),
                cell(''),
                cell(''),
                cell(
                  signed(totalOpen - unpaidCharge),
                  color: signColor(totalOpen - unpaidCharge),
                  bold: true,
                ),
              ],
            ),
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        _daPdfSafe(
          de
              ? 'Differenz = Ist − Soll. „offen" = Differenz abzueglich '
                  'bereits ausgezahlter Ueberstunden. Der letzte Wert '
                  'entspricht dem Ueberstunden-Saldo oben im Blatt.'
              : 'Difference = actual − target. "open" = difference minus '
                  'overtime already paid out. The final value matches the '
                  'overtime balance shown above.',
        ),
        style: const pw.TextStyle(fontSize: 7.5, color: muted),
      ),
    ],
  );
}
