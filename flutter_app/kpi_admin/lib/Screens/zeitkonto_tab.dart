// lib/Screens/zeitkonto_tab.dart
//
// "Zeitkonto" tab inside the Zeiten-und-Abwesenheiten admin page.
// Zeigt alle Fahrer aus dem Drivers Hub (users/{uid}/drivers) — mit
// Suche und Archiv-Toggle wie dort. Pro Fahrer: Überstunden-Konto nach
// dem ARION-Zeitkonto-Modell — monatliche Einträge (Soll-, Ist- und
// bezahlte Stunden), Overtime = Ist − Soll, zwei Abrechnungsperioden
// (Jan–Okt 2025 / Nov 2025–heute), Monats-Historie und PDF-Report.
// UI ist zweisprachig DE/EN (Sprache des Admins).
//
// Speicherung: Map-Feld `overtimeAccount` direkt im Fahrer-Dokument
// (users/{uid}/drivers/{driverId}), Werte in Minuten:
//   overtimeAccount: { '2025-11': {target, worked, paid, period}, ... }
// Bewusst KEINE eigene Subcollection — so sind keine Rules-Änderungen
// nötig und die bestehende Drivers-Hub-Stream-Abfrage liefert alles mit.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/employment_period.dart';
import '../services/time_account_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_typography.dart';
import '../widgets/clearable_search_field.dart';

// ── Zeit-Helfer (H:MM ↔ Minuten, wie im ARION-Zeitkonto-Beispiel) ──

const _kMonthNamesDe = [
  'Januar',
  'Februar',
  'März',
  'April',
  'Mai',
  'Juni',
  'Juli',
  'August',
  'September',
  'Oktober',
  'November',
  'Dezember',
];

const _kMonthNamesEn = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

List<String> _monthNames(bool de) => de ? _kMonthNamesDe : _kMonthNamesEn;

String _monthKey(int year, int month) =>
    '$year-${month.toString().padLeft(2, '0')}';

String _monthLabel(String key, bool de) {
  final parts = key.split('-');
  if (parts.length != 2) return key;
  final m = int.tryParse(parts[1]) ?? 1;
  return '${_monthNames(de)[(m - 1).clamp(0, 11)]} ${parts[0]}';
}


int _parseDuration(String value) {
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

String _formatDuration(int minutesValue) {
  final isNegative = minutesValue < 0;
  final absolute = minutesValue.abs();
  final hours = absolute ~/ 60;
  final minutes = absolute % 60;
  return '${isNegative ? '-' : ''}$hours:${minutes.toString().padLeft(2, '0')}';
}

// Ticket "Time & Absence: the whole section is not translated":
// Zeitkonto folgt jetzt wieder der Admin-Sprache (DE/EN).
bool _zeitkontoGermanOf(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'de';

int _minutesFromAny(dynamic value) {
  if (value is num) return value.round();
  return _parseDuration('$value');
}

/// Decimal hours (e.g. 173.5 from the payroll export) → minutes.
int _minutesFromDecimalHours(double hours) => (hours * 60).round();

// ── Namens-Abgleich für den Zeiterfassungs-Import ──
// Der Export enthält keine Transporter-IDs, nur Namen. Wir matchen
// normalisiert und token-basiert (auch "Nachname, Vorname" ↔
// "Vorname Nachname").

String _normName(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-zà-ÿäöüß]+'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

String _nameTokenKey(String s) {
  final tokens = _normName(s).split(' ').where((t) => t.isNotEmpty).toList()
    ..sort();
  return tokens.join(' ');
}

/// Employee-ID normalisieren: führende Nullen entfernen ("00023" → "23").
String _normEmpId(String s) =>
    s.trim().replaceFirst(RegExp(r'^0+(?=.)'), '');

/// Eine Zeile aus dem Zeiterfassungs-Export im Review-Schritt.
class _ImportRow {
  _ImportRow({
    required this.fileName,
    required this.istMinutes,
    this.fileEmployeeId = '',
    this.driverDocId,
    this.driverName,
  })  : include = driverDocId != null,
        paidCtrl = TextEditingController(text: '0:00');

  final String fileName; // Name wie im Export
  // Employee ID aus dem Export, ohne führende Nullen.
  final String fileEmployeeId;
  final int istMinutes;
  String? driverDocId; // gematchter Fahrer (null = nicht erkannt)
  String? driverName;
  bool include;
  // Bezahlte Überstunden für diesen Monat (pro Mitarbeiter im
  // Review-Schritt eintragbar).
  final TextEditingController paidCtrl;

  bool get matched => driverDocId != null;
}

/// "14,50" / "14.50" → 14.5 (Euro-Stundenlohn).
double _parseEuro(String value) {
  final cleaned =
      value.trim().replaceAll('€', '').replaceAll(',', '.').trim();
  return double.tryParse(cleaned) ?? 0;
}

String _formatEuro(double v) =>
    v <= 0 ? '—' : '${v.toStringAsFixed(2).replaceAll('.', ',')} €';

// ── Datenmodell ──

class _MonthEntry {
  const _MonthEntry({
    required this.month,
    required this.targetMinutes,
    required this.workedMinutes,
    required this.paidMinutes,
    this.hourlyRate = 0,
  });

  final String month; // YYYY-MM
  final int targetMinutes;
  final int workedMinutes;
  final int paidMinutes;

  /// Stundenlohn in €/h für diesen Monat (ändert sich von Monat zu
  /// Monat, daher pro Eintrag gespeichert). 0 = nicht gesetzt.
  final double hourlyRate;

  int get overtimeMinutes => workedMinutes - targetMinutes;

  /// Ausgezahlter Betrag: bezahlte Überstunden × Stundenlohn.
  double get paidOutEuro =>
      hourlyRate <= 0 ? 0 : paidMinutes / 60.0 * hourlyRate;

  factory _MonthEntry.fromMap(String month, Map<String, dynamic> map) =>
      _MonthEntry(
        month: month,
        targetMinutes: _minutesFromAny(map['target']),
        workedMinutes: _minutesFromAny(map['worked']),
        paidMinutes: _minutesFromAny(map['paid']),
        hourlyRate: (map['hourlyRate'] as num?)?.toDouble() ?? 0,
      );
}

/// Überstunden-Sammelblock je Stundenlohn. Es gibt genau EINE
/// Gesamtübersicht — nur bei unterschiedlichen Stundenlöhnen wird
/// pro Lohnsatz getrennt ausgewiesen.
class _RateGroup {
  _RateGroup(this.rate);

  final double rate; // 0 = kein Stundenlohn hinterlegt
  int months = 0;
  int overtimeMinutes = 0;
  int paidMinutes = 0;

  int get remainingMinutes => overtimeMinutes - paidMinutes;
  double get paidOutEuro => rate <= 0 ? 0 : paidMinutes / 60.0 * rate;
}

List<_RateGroup> _rateGroupsOf(List<_MonthEntry> entries) {
  final byRate = <double, _RateGroup>{};
  for (final e in entries) {
    final g = byRate.putIfAbsent(e.hourlyRate, () => _RateGroup(e.hourlyRate));
    g.months++;
    g.overtimeMinutes += e.overtimeMinutes;
    g.paidMinutes += e.paidMinutes;
  }
  final groups = byRate.values.toList()
    ..sort((a, b) => b.rate.compareTo(a.rate));
  return groups;
}

int _totalRemainingOf(List<_MonthEntry> entries) => entries.fold(
    0, (acc, e) => acc + e.overtimeMinutes - e.paidMinutes);

List<_MonthEntry> _entriesFromDriverData(Map<String, dynamic> data) {
  final raw = data['overtimeAccount'];
  if (raw is! Map) return const [];
  final entries = <_MonthEntry>[];
  raw.forEach((key, value) {
    if (value is Map) {
      entries.add(
        _MonthEntry.fromMap(
          key.toString(),
          Map<String, dynamic>.from(value),
        ),
      );
    }
  });
  entries.sort((a, b) => b.month.compareTo(a.month));
  return entries;
}

class ZeitkontoTab extends StatefulWidget {
  final String dspUid;
  const ZeitkontoTab({super.key, required this.dspUid});

  @override
  State<ZeitkontoTab> createState() => _ZeitkontoTabState();
}

class _ZeitkontoTabState extends State<ZeitkontoTab> {
  String _search = '';

  /// Fahrerliste als EINMALIG erzeugter Stream.
  ///
  /// Vorher stand `...snapshots()` direkt im `build()`. Damit entstand bei
  /// jedem `setState` — also bei jedem getippten Buchstaben in der Suche —
  /// ein neues Stream-Objekt. Der StreamBuilder meldete daraufhin wieder
  /// `waiting`, zeigte den Ladekreis und verwarf den kompletten Teilbaum
  /// samt Suchfeld: Der Fokus ging verloren und man musste nach jedem
  /// Buchstaben erneut ins Feld klicken (Ticket „Time Balance").
  Stream<QuerySnapshot<Map<String, dynamic>>>? _driversStreamCache;
  String? _driversStreamUid;

  Stream<QuerySnapshot<Map<String, dynamic>>> get _driversStream {
    // Neu aufsetzen nur, wenn sich das Konto wirklich aendert.
    if (_driversStreamUid != widget.dspUid || _driversStreamCache == null) {
      _driversStreamUid = widget.dspUid;
      _driversStreamCache = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid)
          .collection('drivers')
          .snapshots();
    }
    return _driversStreamCache!;
  }

  /// Owned so the search field's clear button can wipe the visible text.
  final TextEditingController _searchCtrl = TextEditingController();

  // Ticket "CTRL+F": Cmd/Ctrl+F fokussiert das Suchfeld der Seite
  // (Browser-Suche greift in Flutter-Web nicht).
  final FocusNode _searchFocus = FocusNode();

  bool _onGlobalKey(KeyEvent e) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.keyF &&
        (HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed)) {
      if (_searchFocus.canRequestFocus) {
        _searchFocus.requestFocus();
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onGlobalKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onGlobalKey);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }
  // Archive view: inactive drivers are moved out of the main list into a
  // separate archive; toggled by the "Archiv" button — same behaviour as
  // the Drivers Hub.
  bool _showArchive = false;
  // Currently expanded driver profile (Zeitkonto details), if any.
  String? _expandedDocId;
  bool _busyImport = false;

  bool get _de => _zeitkontoGermanOf(context);

  // ── Monatsleiste: ausgewählter Monat (null = Gesamt/Total) ──
  int _selYear = DateTime.now().year;
  int? _selMonth;

  // ── Import aus dem Zeiterfassungsprogramm ──
  //
  // Der Export enthält nur Namen (keine TIDs). Ablauf:
  //   1. xlsx wählen → parseExcel (Spalten "Employee"/"time tracked")
  //   2. Namen gegen driverName aller Fahrer matchen
  //   3. Review-Dialog: erkannt/nicht erkannt, Monat wählbar, Soll-
  //      Stunden pro Mitarbeiter anpassbar (z. B. Einstieg mitten im
  //      Monat), nicht erkannte Namen manuell zuordenbar
  //   4. Import schreibt overtimeAccount.<YYYY-MM> pro Fahrer
  //      (bestehende paid/period-Werte des Monats bleiben erhalten)

  Future<void> _startImport(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> driverDocs,
  ) async {
    final de = _de;
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    final file = picked?.files.firstOrNull;
    if (file == null || file.bytes == null) return;

    setState(() => _busyImport = true);
    try {
      final parsed = await TimeAccountRepository.parseExcel(
        filename: file.name,
        bytes: file.bytes!,
      );

      // Lookups: Employee-ID (primär, ohne führende Nullen) und
      // normalisierter Fahrername (Fallback) → (docId, Anzeigename).
      final byEmpId = <String, (String, String)>{};
      final byExact = <String, (String, String)>{};
      final byTokens = <String, (String, String)>{};
      final allDrivers = <(String, String)>[];
      // Bereits am Fahrer gespeicherte Employee ID (docId → ID) —
      // fehlende IDs werden beim Import automatisch nachgetragen.
      final storedEmpIdByDocId = <String, String>{};
      // IDs, die bei MEHREREN Fahrern hinterlegt sind (Duplikat im
      // Zeiterfassungssystem, z. B. "248" und "00248") — für diese
      // greift ausschließlich der Namensabgleich, sonst könnten die
      // Stunden beim falschen Fahrer landen.
      final duplicateEmpIds = <String>{};
      for (final d in driverDocs) {
        final data = d.data();
        final name = (data['driverName'] ?? '').toString().trim();
        if (name.isEmpty) continue;
        allDrivers.add((d.id, name));
        final empId =
            _normEmpId((data['employeeNumber'] ?? '').toString());
        if (empId.isNotEmpty) {
          if (byEmpId.containsKey(empId)) {
            duplicateEmpIds.add(empId);
          } else {
            byEmpId[empId] = (d.id, name);
          }
          storedEmpIdByDocId[d.id] = empId;
        }
        byExact[_normName(name)] = (d.id, name);
        byTokens[_nameTokenKey(name)] = (d.id, name);
      }
      for (final id in duplicateEmpIds) {
        byEmpId.remove(id);
      }
      allDrivers.sort(
          (a, b) => a.$2.toLowerCase().compareTo(b.$2.toLowerCase()));

      // 0-Stunden-Zeilen ("die Nuller") werden übersprungen.
      var skippedZero = 0;
      final rows = <_ImportRow>[];
      for (final p in parsed.rows) {
        if (p.istHours <= 0) {
          skippedZero++;
          continue;
        }
        final empId = _normEmpId(p.employeeId);
        final hit = (empId.isEmpty ? null : byEmpId[empId]) ??
            byExact[_normName(p.employeeName)] ??
            byTokens[_nameTokenKey(p.employeeName)];
        rows.add(_ImportRow(
          fileName: p.employeeName,
          fileEmployeeId: empId,
          istMinutes: _minutesFromDecimalHours(p.istHours),
          driverDocId: hit?.$1,
          driverName: hit?.$2,
        ));
      }
      if (rows.isEmpty) {
        throw StateError(de
            ? 'Keine Mitarbeiter-Zeilen mit Stunden in der Datei '
                'gefunden${skippedZero > 0 ? ' ($skippedZero mit 0 h übersprungen)' : ''}.'
            : 'No employee rows with hours found in the file'
                '${skippedZero > 0 ? ' ($skippedZero with 0 h skipped)' : ''}.');
      }

      if (!mounted) return;
      await _importReviewDialog(
        rows: rows,
        allDrivers: allDrivers,
        initialMonth: parsed.periodStart.month,
        initialYear: parsed.periodStart.year,
        storedEmpIdByDocId: storedEmpIdByDocId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(de ? 'Import fehlgeschlagen: $e' : 'Import failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyImport = false);
    }
  }

  Future<void> _importReviewDialog({
    required List<_ImportRow> rows,
    required List<(String, String)> allDrivers,
    required int initialMonth,
    required int initialYear,
    Map<String, String> storedEmpIdByDocId = const {},
  }) async {
    final de = _de;
    final now = DateTime.now();
    var month = initialMonth;
    var year = initialYear;
    // Monats-Soll = Arbeitstage × Stunden/Tag (Monate haben je nach
    // Feiertagen 20–23 Arbeitstage).
    final workdaysCtrl = TextEditingController(text: '21');
    final hoursPerDayCtrl = TextEditingController(text: '8:00');
    // Stundenlohn €/h — ändert sich von Monat zu Monat.
    final rateCtrl = TextEditingController();

    // Das Monats-Soll (Arbeitstage × Std./Tag) gilt für ALLE
    // Mitarbeiter gleichzeitig — keine Soll-Eingabe pro Zeile.
    int computedTarget() {
      final days = int.tryParse(workdaysCtrl.text.trim()) ?? 0;
      return days * _parseDuration(hoursPerDayCtrl.text);
    }

    // Klare, wenig abgerundete Rahmen (Ticket: Popup aufräumen) — die
    // Theme-Pills (randlos, stark gerundet) werden hier komplett
    // überschrieben, Labels schweben immer über dem Feld.
    OutlineInputBorder fieldBorder(Color color, [double w = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: w),
        );
    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 13),
          border: fieldBorder(const Color(0xFFD1D5DB)),
          enabledBorder: fieldBorder(const Color(0xFFD1D5DB)),
          focusedBorder: fieldBorder(const Color(0xFF00B287), 1.6),
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
          ),
        );

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final unmatched = rows.where((r) => !r.matched).toList();
          final matched = rows.where((r) => r.matched).toList();
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            title: Text(
              de ? 'Import prüfen' : 'Review import',
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800),
            ),
            content: SizedBox(
              width: 720,
              height: 580,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alle Kopf-Felder in einem Wrap — genug Platz für
                  // jedes Label, nichts wird abgeschnitten.
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 170,
                        child: DropdownButtonFormField<int>(
                          initialValue: month,
                          decoration: deco(de ? 'Monat' : 'Month'),
                          items: [
                            for (var m = 1; m <= 12; m++)
                              DropdownMenuItem(
                                value: m,
                                child: Text(_monthNames(de)[m - 1]),
                              ),
                          ],
                          onChanged: (v) =>
                              setLocal(() => month = v ?? month),
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: DropdownButtonFormField<int>(
                          initialValue: year,
                          decoration: deco(de ? 'Jahr' : 'Year'),
                          items: [
                            for (var y = 2024; y <= now.year + 1; y++)
                              DropdownMenuItem(
                                  value: y, child: Text('$y')),
                          ],
                          onChanged: (v) =>
                              setLocal(() => year = v ?? year),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: rateCtrl,
                          keyboardType: const TextInputType
                              .numberWithOptions(decimal: true),
                          decoration: deco(de
                              ? 'Stundenlohn €/h'
                              : 'Hourly rate €/h'),
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        child: TextField(
                          controller: workdaysCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setLocal(() {}),
                          decoration: deco(
                              de ? 'Arbeitstage' : 'Working days'),
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: TextField(
                          controller: hoursPerDayCtrl,
                          onChanged: (_) => setLocal(() {}),
                          decoration: deco(de
                              ? 'Std./Tag (H:MM)'
                              : 'Hours/day (H:MM)'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F8F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF00B287)
                                  .withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          de
                              ? 'Monats-Soll: ${_formatDuration(computedTarget())} h'
                              : 'Monthly target: ${_formatDuration(computedTarget())} h',
                          style: AppTypography.footnote.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    de
                        ? '${matched.length} von ${rows.length} Namen erkannt'
                            '${unmatched.isEmpty ? '.' : ' — ${unmatched.length} nicht erkannt (unten manuell zuordnen).'}'
                        : '${matched.length} of ${rows.length} names recognised'
                            '${unmatched.isEmpty ? '.' : ' — ${unmatched.length} not recognised (assign manually below).'}',
                    style: AppTypography.footnote.copyWith(
                      fontWeight: FontWeight.w700,
                      color: unmatched.isEmpty
                          ? const Color(0xFF047857)
                          : const Color(0xFFB45309),
                    ),
                  ),
                  Text(
                    de
                        ? 'Das Monats-Soll gilt für alle gleichzeitig. '
                            'Bezahlte Überstunden können pro Mitarbeiter '
                            'eingetragen werden.'
                        : 'The monthly target applies to everyone at '
                            'once. Paid overtime can be entered per '
                            'employee.',
                    style: AppTypography.caption2.copyWith(
                      color: AppColors.labelSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final r in matched)
                          _importRowTile(r, setLocal, de,
                              allDrivers: allDrivers),
                        if (unmatched.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            de
                                ? 'Nicht erkannt'
                                : 'Not recognised',
                            style: AppTypography.footnote.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                          const SizedBox(height: 4),
                          for (final r in unmatched)
                            _importRowTile(r, setLocal, de,
                                allDrivers: allDrivers),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(de ? 'Abbrechen' : 'Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00B287)),
                onPressed: rows.any((r) => r.include && r.matched)
                    ? () => Navigator.pop(ctx, true)
                    : null,
                child: Text(de
                    ? 'Importieren (${rows.where((r) => r.include && r.matched).length})'
                    : 'Import (${rows.where((r) => r.include && r.matched).length})'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) return;

    final key = _monthKey(year, month);
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers');

    final hourlyRate = _parseEuro(rateCtrl.text);
    // Ein Soll für alle: Arbeitstage × Std./Tag aus dem Dialog.
    final targetMinutes = (int.tryParse(workdaysCtrl.text.trim()) ?? 0) *
        _parseDuration(hoursPerDayCtrl.text);
    var written = 0;
    final batch = FirebaseFirestore.instance.batch();
    for (final r in rows) {
      if (!r.include || r.driverDocId == null) continue;
      // Employee ID automatisch am Fahrer speichern (wenn sie fehlt
      // oder abweicht) — so matchen künftige Importe ALLE Mitarbeiter
      // ohne manuelle Zuordnung.
      final persistEmpId = r.fileEmployeeId.isNotEmpty &&
          storedEmpIdByDocId[r.driverDocId] != r.fileEmployeeId;
      batch.set(
        col.doc(r.driverDocId),
        {
          if (persistEmpId) 'employeeNumber': r.fileEmployeeId,
          'overtimeAccount': {
            key: {
              'target': targetMinutes,
              'worked': r.istMinutes,
              'paid': _parseDuration(r.paidCtrl.text),
              if (hourlyRate > 0) 'hourlyRate': hourlyRate,
            },
          },
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      written++;
    }
    await batch.commit();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF067647),
        content: Text(de
            ? '$written Zeitkonto-Einträge für ${_monthLabel(key, de)} importiert.'
            : 'Imported $written time-account entries for ${_monthLabel(key, de)}.'),
      ),
    );
  }

  Widget _importRowTile(
    _ImportRow r,
    void Function(void Function()) setLocal,
    bool de, {
    required List<(String, String)> allDrivers,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: r.matched ? Colors.white : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: r.matched
              ? const Color(0xFFE5E7EB)
              : const Color(0xFFFCD34D),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: r.include,
            activeColor: const Color(0xFF00B287),
            onChanged: r.matched
                ? (v) => setLocal(() => r.include = v ?? false)
                : null,
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.fileEmployeeId.isEmpty
                      ? r.fileName
                      : '${r.fileName} · #${r.fileEmployeeId}',
                  style: AppTypography.footnote.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.codriverGraphite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (r.matched)
                  Text(
                    '→ ${r.driverName}',
                    style: AppTypography.caption2.copyWith(
                      color: const Color(0xFF047857),
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  DropdownButton<String>(
                    value: null,
                    hint: Text(
                      de ? 'Fahrer zuordnen …' : 'Assign driver …',
                      style: AppTypography.caption2.copyWith(
                        color: const Color(0xFFB45309),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final d in allDrivers)
                        DropdownMenuItem(
                          value: d.$1,
                          child: Text(d.$2,
                              style: const TextStyle(fontSize: 12.5)),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      final d =
                          allDrivers.firstWhere((e) => e.$1 == v);
                      setLocal(() {
                        r.driverDocId = d.$1;
                        r.driverName = d.$2;
                        r.include = true;
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  de ? 'Ist' : 'Worked',
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.labelSecondaryLight,
                  ),
                ),
                Text(
                  '${_formatDuration(r.istMinutes)} h',
                  style: AppTypography.footnote.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.codriverGraphite,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 150,
            child: TextField(
              controller: r.paidCtrl,
              enabled: r.matched,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText:
                    de ? 'Bez. Überstd. (H:MM)' : 'Paid O/T (H:MM)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                isDense: true,
                filled: true,
                fillColor:
                    r.matched ? Colors.white : const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 12),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: Color(0xFF00B287), width: 1.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final de = _de;
    return Container(
      color: const Color(0xFFF3F6F7),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _driversStream,
        builder: (context, snap) {
          // Nur beim allerersten Laden einen Ladekreis zeigen. Danach hat
          // der Stream Daten und der Teilbaum bleibt bestehen — sonst
          // verlöre das Suchfeld bei jeder Aktualisierung den Fokus.
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text(de
                    ? 'Fehler: ${snap.error}'
                    : 'Error: ${snap.error}'));
          }

          final docs = (snap.data?.docs ??
                  <QueryDocumentSnapshot<Map<String, dynamic>>>[])
              .toList();

          var filtered = docs.where((d) {
            final data = d.data();
            final archived = ((data['active'] as bool?) ?? true) == false;
            if (archived != _showArchive) return false;
            if (_search.isEmpty) return true;
            final name =
                (data['driverName'] ?? '').toString().toLowerCase();
            final tid =
                (data['transporterId'] ?? d.id).toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            return name.contains(_search) ||
                tid.contains(_search) ||
                email.contains(_search);
          }).toList()
            ..sort((a, b) {
              final an =
                  (a.data()['driverName'] ?? '').toString().toLowerCase();
              final bn =
                  (b.data()['driverName'] ?? '').toString().toLowerCase();
              return an.compareTo(bn);
            });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      de ? 'Zeitkonto' : 'Time Account',
                      style: AppTypography.title2.copyWith(
                        color: AppColors.codriverGraphite,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF00B287),
                        minimumSize: const Size(0, 44),
                      ),
                      onPressed: _busyImport ? null : () => _startImport(docs),
                      icon: _busyImport
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload_file_rounded, size: 18),
                      label: Text(
                          de ? 'Stunden importieren' : 'Import hours'),
                    ),
                    const SizedBox(width: 8),
                    _archiveToggle(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _showArchive
                      ? (de ? 'Archivierte Fahrer.' : 'Archived drivers.')
                      : (de
                          ? 'Überstunden, Auszahlungen und Restsaldo pro Fahrer.'
                          : 'Overtime, payouts and remaining balance per driver.'),
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.labelSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                _searchField(),
                const SizedBox(height: 12),
                // Monatsleiste: Total oder ein konkreter Monat.
                _monthBar(),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  _emptyState()
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: AppElevation.level1,
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < filtered.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          _DriverRow(
                            data: filtered[i].data(),
                            docId: filtered[i].id,
                            archived: _showArchive,
                            expanded: _expandedDocId == filtered[i].id,
                            selectedMonthKey: _selMonth == null
                                ? null
                                : _monthKey(_selYear, _selMonth!),
                            onTap: () => setState(() {
                              _expandedDocId =
                                  _expandedDocId == filtered[i].id
                                      ? null
                                      : filtered[i].id;
                            }),
                          ),
                          if (_expandedDocId == filtered[i].id)
                            _ZeitkontoProfile(
                              data: filtered[i].data(),
                              driverRef: filtered[i].reference,
                            ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Archive toggle — same look & behaviour as the Drivers Hub.
  Widget _archiveToggle() {
    final de = _de;
    return Material(
      color: _showArchive ? const Color(0xFF111827) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _showArchive = !_showArchive),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5EA), width: 0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _showArchive
                    ? Icons.arrow_back_rounded
                    : Icons.archive_outlined,
                size: 18,
                color:
                    _showArchive ? Colors.white : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                _showArchive
                    ? (de ? 'Aktive Fahrer' : 'Active drivers')
                    : (de ? 'Archiv' : 'Archive'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _showArchive
                      ? Colors.white
                      : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Monatsleiste: [Total] + Jan…Dec-Chips mit Jahres-Pfeilen. Ein
  /// gewählter Monat zeigt in jeder Fahrerzeile die Stunden dieses
  /// Monats; "Total" zeigt den Gesamt-Saldo (wie bisher).
  Widget _monthBar() {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    Widget chip(String label, bool selected, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF00B287) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? const Color(0xFF00B287)
                  : const Color(0xFFE5E5EA),
              width: selected ? 1 : 0.7,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color:
                  selected ? Colors.white : const Color(0xFF374151),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        InkWell(
          onTap: () => setState(() => _selYear--),
          borderRadius: BorderRadius.circular(999),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.chevron_left_rounded,
                size: 20, color: Color(0xFF6B7280)),
          ),
        ),
        Text(
          '$_selYear',
          style: AppTypography.footnote.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.codriverGraphite,
          ),
        ),
        InkWell(
          onTap: () => setState(() => _selYear++),
          borderRadius: BorderRadius.circular(999),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.chevron_right_rounded,
                size: 20, color: Color(0xFF6B7280)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                chip('Total', _selMonth == null,
                    () => setState(() => _selMonth = null)),
                for (var m = 1; m <= 12; m++) ...[
                  const SizedBox(width: 6),
                  chip(
                    names[m - 1],
                    _selMonth == m,
                    () => setState(
                        () => _selMonth = _selMonth == m ? null : m),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchField() {
    final de = _de;
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchCtrl,
        focusNode: _searchFocus,
        onChanged: (v) =>
            setState(() => _search = v.trim().toLowerCase()),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF9CA3AF),
            size: 20,
          ),
          suffixIcon: buildSearchClearButton(
            context: context,
            value: _search,
            focusNode: _searchFocus,
            onClear: () {
              _searchCtrl.clear();
              setState(() => _search = '');
            },
          ),
          suffixIconConstraints: kSearchClearConstraints,
          hintText: de ? 'Fahrer suchen …' : 'Search drivers …',
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9CA3AF),
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFE5E5EA), width: 0.6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFE5E5EA), width: 0.6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF00B287), width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    final de = _de;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(
            _showArchive
                ? Icons.archive_outlined
                : Icons.schedule_rounded,
            size: 36,
            color: const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 10),
          Text(
            _showArchive
                ? (de
                    ? 'Keine archivierten Fahrer.'
                    : 'No archived drivers.')
                : (de ? 'Keine Fahrer gefunden.' : 'No drivers found.'),
            style: AppTypography.subheadline.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.codriverGraphite,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final bool archived;
  final bool expanded;
  final VoidCallback onTap;

  /// Ausgewählter Monat (YYYY-MM) aus der Monatsleiste — null = Total.
  final String? selectedMonthKey;

  const _DriverRow({
    required this.data,
    required this.docId,
    required this.archived,
    required this.expanded,
    required this.onTap,
    this.selectedMonthKey,
  });

  @override
  Widget build(BuildContext context) {
    final de = _zeitkontoGermanOf(context);
    final name = (data['driverName'] ?? '').toString().trim();
    final tid = (data['transporterId'] ?? docId).toString().trim();
    // Ticket "TIME ACCOUNT: Vertragszeitraum je Fahrer anzeigen" —
    // aktueller Vertragszeitraum aus dem Drivers Hub
    // (employmentPeriods, Fallback auf die Legacy-Onboarding-Felder).
    final contract = currentEmploymentPeriod(employmentPeriodsOf(data));
    final contractStart = contract?.startDate;
    final contractEnd = contract?.endDate;
    // Employee ID (Zeiterfassung) — zusammen mit der TID anzeigen.
    final empId = (data['employeeNumber'] ?? '').toString().trim();
    final initials = _initials(name.isEmpty ? tid : name);
    final entries = _entriesFromDriverData(data);
    final remaining = _totalRemainingOf(entries);

    // Monatsansicht: Eintrag des gewählten Monats (falls vorhanden).
    _MonthEntry? monthEntry;
    if (selectedMonthKey != null) {
      for (final e in entries) {
        if (e.month == selectedMonthKey) {
          monthEntry = e;
          break;
        }
      }
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    archived ? const Color(0xFFF3F4F6) : AppColors.green50,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: AppTypography.caption2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: archived
                      ? const Color(0xFF6B7280)
                      : AppColors.codriverDeep,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? tid : name,
                    style: AppTypography.subheadline.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.codriverGraphite,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Vertragszeitraum: "17.06.26 – 30.07.26", bei
                  // laufendem Vertrag "17.06.26 – aktiv" mit grünem Punkt.
                  if (contractStart != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            contractEnd == null
                                ? '${formatShortDate(contractStart)} – '
                                    '${de ? 'aktiv' : 'active'}'
                                : '${formatShortDate(contractStart)} – '
                                    '${formatShortDate(contractEnd)}',
                            style: AppTypography.caption2.copyWith(
                              fontWeight: FontWeight.w700,
                              color: contractEnd == null
                                  ? const Color(0xFF047857)
                                  : AppColors.labelSecondaryLight,
                            ),
                          ),
                          if (contractEnd == null) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Employee ID (Zeiterfassung) vor der TID.
                      if (empId.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '#$empId',
                            style: AppTypography.caption2.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4338CA),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          tid,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.labelSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Monatsansicht: Ist-Stunden + Überstunden des gewählten
            // Monats; Total-Ansicht: Gesamt-Saldo.
            if (selectedMonthKey != null) ...[
              if (monthEntry == null)
                Text(
                  'no data',
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.labelTertiaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'worked ${_formatDuration(monthEntry.workedMinutes)} h',
                    style: AppTypography.caption2.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1D4ED8),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: monthEntry.overtimeMinutes < 0
                        ? const Color(0xFFFEF2F2)
                        : AppColors.green50,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'O/T ${_formatDuration(monthEntry.overtimeMinutes)} h',
                    style: AppTypography.caption2.copyWith(
                      fontWeight: FontWeight.w800,
                      color: monthEntry.overtimeMinutes < 0
                          ? const Color(0xFFB91C1C)
                          : AppColors.codriverDeep,
                    ),
                  ),
                ),
              ],
            ] else
              // Zeitkonto-Saldo (Überstunden minus bezahlt, gesamt).
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: remaining < 0
                      ? const Color(0xFFFEF2F2)
                      : AppColors.green50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_formatDuration(remaining)} h',
                  style: AppTypography.caption2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: remaining < 0
                        ? const Color(0xFFB91C1C)
                        : AppColors.codriverDeep,
                  ),
                ),
              ),
            const SizedBox(width: 10),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String s) {
    final parts =
        s.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

// ── Ausgeklapptes Zeitkonto-Profil eines Fahrers ──

class _ZeitkontoProfile extends StatelessWidget {
  final Map<String, dynamic> data;
  final DocumentReference<Map<String, dynamic>> driverRef;
  const _ZeitkontoProfile({required this.data, required this.driverRef});

  @override
  Widget build(BuildContext context) {
    final de = _zeitkontoGermanOf(context);
    final entries = _entriesFromDriverData(data);
    final groups = _rateGroupsOf(entries);
    final totalRemaining = _totalRemainingOf(entries);
    final name = (data['driverName'] ?? '').toString().trim();
    final tid = (data['transporterId'] ?? driverRef.id).toString().trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  de ? 'Überstunden-Konto' : 'Overtime account',
                  style: AppTypography.subheadline.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.codriverGraphite,
                  ),
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: const Color(0xFF374151),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                onPressed: entries.isEmpty
                    ? null
                    : () => _exportPdf(name.isEmpty ? tid : name, tid,
                        entries, groups, de),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                label: const Text('PDF'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: const Color(0xFF00B287),
                ),
                onPressed: () => _editMonthDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(de ? 'Monat erfassen' : 'Add month'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Eine Gesamt-Übersicht — nur bei unterschiedlichen
          // Stundenlöhnen wird pro Lohnsatz getrennt ausgewiesen.
          for (final g in groups) ...[
            if (groups.length > 1) ...[
              Text(
                g.rate > 0
                    ? _formatEuro(g.rate).replaceAll(' €', ' €/h')
                    : (de ? 'Ohne Stundenlohn' : 'No hourly rate'),
                style: AppTypography.caption2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.labelSecondaryLight,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _stat(de ? 'Überstunden' : 'Overtime',
                    _formatDuration(g.overtimeMinutes)),
                _stat(de ? 'Bezahlt' : 'Paid',
                    _formatDuration(g.paidMinutes)),
                if (g.paidOutEuro > 0)
                  _stat(de ? 'Ausgezahlt' : 'Paid out',
                      _formatEuro(g.paidOutEuro),
                      isEuro: true),
                _stat(
                    groups.length > 1
                        ? (de ? 'Rest' : 'Left')
                        : (de ? 'Zeitkonto' : 'Balance'),
                    _formatDuration(g.remainingMinutes),
                    highlight: true),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (groups.length > 1)
            _stat(de ? 'Zeitkonto gesamt' : 'Total balance',
                _formatDuration(totalRemaining),
                highlight: true),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              de ? 'Monats-Historie' : 'Monthly history',
              style: AppTypography.footnote.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.codriverGraphite,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 44,
                headingTextStyle: AppTypography.caption2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.labelSecondaryLight,
                ),
                dataTextStyle: AppTypography.footnote.copyWith(
                  color: AppColors.codriverGraphite,
                ),
                columns: [
                  DataColumn(label: Text(de ? 'Monat' : 'Month')),
                  DataColumn(label: Text(de ? 'Soll' : 'Target')),
                  DataColumn(label: Text(de ? 'Ist' : 'Worked')),
                  DataColumn(
                      label: Text(de ? 'Überstd.' : 'Overtime')),
                  DataColumn(label: Text(de ? 'Bezahlt' : 'Paid')),
                  const DataColumn(label: Text('€/h')),
                  DataColumn(
                      label: Text(de ? 'Ausgezahlt' : 'Paid out')),
                  DataColumn(label: Text(de ? 'Rest' : 'Left')),
                  const DataColumn(label: Text('')),
                ],
                rows: [
                  for (final e in entries)
                    DataRow(cells: [
                      DataCell(Text(_monthLabel(e.month, de))),
                      DataCell(Text(_formatDuration(e.targetMinutes))),
                      DataCell(Text(_formatDuration(e.workedMinutes))),
                      DataCell(Text(
                        _formatDuration(e.overtimeMinutes),
                        style: AppTypography.footnote.copyWith(
                          fontWeight: FontWeight.w800,
                          color: e.overtimeMinutes < 0
                              ? const Color(0xFFB91C1C)
                              : AppColors.codriverDeep,
                        ),
                      )),
                      DataCell(Text(_formatDuration(e.paidMinutes))),
                      DataCell(Text(_formatEuro(e.hourlyRate))),
                      DataCell(Text(
                        e.paidOutEuro <= 0
                            ? '—'
                            : _formatEuro(e.paidOutEuro),
                        style: AppTypography.footnote.copyWith(
                          fontWeight: FontWeight.w800,
                          color: e.paidOutEuro > 0
                              ? AppColors.codriverDeep
                              : AppColors.codriverGraphite,
                        ),
                      )),
                      DataCell(Text(_formatDuration(
                          e.overtimeMinutes - e.paidMinutes))),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: de ? 'Bearbeiten' : 'Edit',
                            splashRadius: 16,
                            icon: const Icon(Icons.edit_outlined,
                                size: 16, color: Color(0xFF6B7280)),
                            onPressed: () =>
                                _editMonthDialog(context, existing: e),
                          ),
                          IconButton(
                            tooltip: de ? 'Löschen' : 'Delete',
                            splashRadius: 16,
                            icon: const Icon(Icons.delete_outline,
                                size: 16, color: Color(0xFFB91C1C)),
                            onPressed: () => _deleteMonth(context, e),
                          ),
                        ],
                      )),
                    ]),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              de
                  ? 'Noch keine Monate erfasst. Über „Monat erfassen" '
                      'Soll-, Ist- und bezahlte Stunden eintragen.'
                  : 'No months recorded yet. Use "Add month" to enter '
                      'target, worked and paid hours.',
              style: AppTypography.footnote.copyWith(
                color: AppColors.labelSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(String label, String value,
      {bool highlight = false, bool isEuro = false}) {
    final negative = value.startsWith('-');
    return Container(
      width: 168,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight
              ? const Color(0xFF00B287).withValues(alpha: 0.45)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isEuro ? value : '$value h',
            style: AppTypography.subheadline.copyWith(
              fontWeight: FontWeight.w800,
              color: negative
                  ? const Color(0xFFB91C1C)
                  : AppColors.codriverGraphite,
            ),
          ),
        ],
      ),
    );
  }

  // ── Monat erfassen / bearbeiten ──

  Future<void> _editMonthDialog(
    BuildContext context, {
    _MonthEntry? existing,
  }) async {
    final de = _zeitkontoGermanOf(context);
    final now = DateTime.now();
    var year = existing != null
        ? int.tryParse(existing.month.split('-').first) ?? now.year
        : now.year;
    var month = existing != null
        ? int.tryParse(existing.month.split('-').last) ?? now.month
        : now.month;
    final targetCtrl = TextEditingController(
        text: existing == null
            ? '0:00'
            : _formatDuration(existing.targetMinutes));
    final workedCtrl = TextEditingController(
        text: existing == null
            ? '0:00'
            : _formatDuration(existing.workedMinutes));
    final paidCtrl = TextEditingController(
        text: existing == null
            ? '0:00'
            : _formatDuration(existing.paidMinutes));
    final rateCtrl = TextEditingController(
        text: existing == null || existing.hourlyRate <= 0
            ? ''
            : existing.hourlyRate
                .toStringAsFixed(2)
                .replaceAll('.', ','));

    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(
            existing == null
                ? (de ? 'Monat erfassen' : 'Add month')
                : (de ? 'Monat bearbeiten' : 'Edit month'),
            style:
                const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 380,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: month,
                          decoration: deco(de ? 'Monat' : 'Month'),
                          items: [
                            for (var m = 1; m <= 12; m++)
                              DropdownMenuItem(
                                value: m,
                                child: Text(_monthNames(de)[m - 1]),
                              ),
                          ],
                          onChanged: existing != null
                              ? null
                              : (v) =>
                                  setLocal(() => month = v ?? month),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 110,
                        child: DropdownButtonFormField<int>(
                          initialValue: year,
                          decoration: deco(de ? 'Jahr' : 'Year'),
                          items: [
                            for (var y = 2024; y <= now.year + 1; y++)
                              DropdownMenuItem(
                                  value: y, child: Text('$y')),
                          ],
                          onChanged: existing != null
                              ? null
                              : (v) =>
                                  setLocal(() => year = v ?? year),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: targetCtrl,
                    decoration: deco(de
                        ? 'Soll-Stunden (H:MM)'
                        : 'Target hours (H:MM)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: workedCtrl,
                    decoration: deco(de
                        ? 'Ist-Stunden (H:MM)'
                        : 'Worked hours (H:MM)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: paidCtrl,
                    decoration: deco(de
                        ? 'Bezahlte Stunden (H:MM)'
                        : 'Paid hours (H:MM)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rateCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: deco(de
                        ? 'Stundenlohn €/h (z. B. 14,50)'
                        : 'Hourly rate €/h (e.g. 14.50)'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(de ? 'Abbrechen' : 'Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00B287)),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(de ? 'Speichern' : 'Save'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;

    final key = existing?.month ?? _monthKey(year, month);
    final rate = _parseEuro(rateCtrl.text);
    await driverRef.set({
      'overtimeAccount': {
        key: {
          'target': _parseDuration(targetCtrl.text),
          'worked': _parseDuration(workedCtrl.text),
          'paid': _parseDuration(paidCtrl.text),
          'hourlyRate': rate > 0 ? rate : FieldValue.delete(),
        },
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _deleteMonth(BuildContext context, _MonthEntry e) async {
    final de = _zeitkontoGermanOf(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(de ? 'Monat löschen?' : 'Delete month?',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800)),
        content: Text(de
            ? '${_monthLabel(e.month, de)} wird aus dem Zeitkonto entfernt.'
            : '${_monthLabel(e.month, de)} will be removed from the time account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(de ? 'Löschen' : 'Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await driverRef.set({
      'overtimeAccount': {e.month: FieldValue.delete()},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── PDF-Report (Struktur wie im ARION-Zeitkonto-Beispiel) ──

  Future<void> _exportPdf(
    String name,
    String tid,
    List<_MonthEntry> entries,
    List<_RateGroup> groups,
    bool de,
  ) async {
    final doc = pw.Document();
    final brand = PdfColor.fromInt(0xFF00B287);
    final ink = PdfColor.fromInt(0xFF111827);
    final muted = PdfColor.fromInt(0xFF6B7280);
    final soft = PdfColor.fromInt(0xFFF3F6F7);
    final line = PdfColor.fromInt(0xFFE5E7EB);
    final totalRemaining = _totalRemainingOf(entries);

    pw.Widget statBox(String label, String value,
        {bool highlight = false, bool isEuro = false}) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: highlight ? PdfColor.fromInt(0xFFE9F8F2) : soft,
          border: pw.Border.all(color: line),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(fontSize: 9, color: muted)),
            pw.SizedBox(height: 4),
            pw.Text(
              isEuro ? value : '$value h',
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: highlight ? ink : brand,
              ),
            ),
          ],
        ),
      );
    }

    // Eine Gesamt-Übersicht — nur bei unterschiedlichen Stundenlöhnen
    // eine Zeile pro Lohnsatz.
    final summaryRows = <pw.Widget>[];
    for (final g in groups) {
      if (groups.length > 1) {
        summaryRows.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
          child: pw.Text(
            g.rate > 0
                ? '${g.rate.toStringAsFixed(2).replaceAll('.', ',')} €/h'
                : (de ? 'Ohne Stundenlohn' : 'No hourly rate'),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: muted,
            ),
          ),
        ));
      }
      summaryRows.add(pw.Row(children: [
        pw.Expanded(
            child: statBox(de ? 'Überstunden' : 'Overtime',
                _formatDuration(g.overtimeMinutes))),
        pw.SizedBox(width: 10),
        pw.Expanded(
            child: statBox(de ? 'Bezahlt' : 'Paid',
                _formatDuration(g.paidMinutes))),
        if (g.paidOutEuro > 0) ...[
          pw.SizedBox(width: 10),
          pw.Expanded(
              child: statBox(de ? 'Ausgezahlt' : 'Paid out',
                  _formatEuro(g.paidOutEuro),
                  isEuro: true)),
        ],
        pw.SizedBox(width: 10),
        pw.Expanded(
            child: statBox(
                groups.length > 1
                    ? (de ? 'Rest' : 'Left')
                    : (de ? 'Zeitkonto' : 'Balance'),
                _formatDuration(g.remainingMinutes),
                highlight: true)),
      ]));
      summaryRows.add(pw.SizedBox(height: 8));
    }

    final rows = entries.reversed
        .map((e) => [
              _monthLabel(e.month, de),
              _formatDuration(e.targetMinutes),
              _formatDuration(e.workedMinutes),
              _formatDuration(e.overtimeMinutes),
              _formatDuration(e.paidMinutes),
              e.hourlyRate > 0
                  ? e.hourlyRate
                      .toStringAsFixed(2)
                      .replaceAll('.', ',')
                  : '-',
              e.paidOutEuro > 0 ? _formatEuro(e.paidOutEuro) : '-',
              _formatDuration(e.overtimeMinutes - e.paidMinutes),
            ])
        .toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            color: brand,
            child: pw.Text(
              de
                  ? 'Zeitkonto — Überstunden-Report'
                  : 'Time Account — Overtime Report',
              style: pw.TextStyle(
                fontSize: 22,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: soft,
              border: pw.Border.all(color: line),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  name,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text('Transporter-ID: ${tid.isEmpty ? '-' : tid}'),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          ...summaryRows,
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerDecoration: pw.BoxDecoration(color: soft),
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: line, width: 0.7),
            ),
            headers: de
                ? const [
                    'Monat',
                    'Soll',
                    'Ist',
                    'Überstd.',
                    'Bezahlt',
                    '€/h',
                    'Ausgezahlt',
                    'Rest',
                  ]
                : const [
                    'Month',
                    'Target',
                    'Worked',
                    'Overtime',
                    'Paid',
                    '€/h',
                    'Paid out',
                    'Left',
                  ],
            data: rows,
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: muted,
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: soft,
              border: pw.Border.all(color: line),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(de ? 'Zeitkonto gesamt' : 'Total balance',
                    style: pw.TextStyle(color: muted)),
                pw.Text(
                  '${_formatDuration(totalRemaining)} h',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: brand,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          'zeitkonto-${name.replaceAll(RegExp(r'\s+'), '-').toLowerCase()}.pdf',
    );
  }
}
