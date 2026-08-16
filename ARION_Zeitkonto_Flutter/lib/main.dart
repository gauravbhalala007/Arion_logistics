import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ArionZeitkontoApp());
}

const _brand = Color(0xFFF59A00);
const _brandDark = Color(0xFFDF7F00);
const _ink = Color(0xFF24160A);
const _muted = Color(0xFF7B6856);
const _bg = Color(0xFFFFF7EC);
const _card = Color(0xFFFFFCF7);

const _employeesKey = 'arion_zeitkonto_employees';
const _entriesKey = 'arion_zeitkonto_entries';

class ArionZeitkontoApp extends StatelessWidget {
  const ArionZeitkontoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ARION Zeitkonto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _brand),
        scaffoldBackgroundColor: _bg,
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: _ink),
          headlineMedium: TextStyle(fontWeight: FontWeight.w900, color: _ink),
          titleLarge: TextStyle(fontWeight: FontWeight.w800, color: _ink),
          titleMedium: TextStyle(fontWeight: FontWeight.w800, color: _ink),
          bodyMedium: TextStyle(color: _ink),
        ),
      ),
      home: const ZeitkontoPage(),
    );
  }
}

class Employee {
  Employee({
    required this.id,
    required this.name,
    required this.daId,
    required this.position,
    required this.workType,
    required this.startDate,
    this.endDate,
  });

  final String id;
  final String name;
  final String daId;
  final String position;
  final String workType;
  final DateTime startDate;
  final DateTime? endDate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'daId': daId,
        'position': position,
        'workType': workType,
        'startDate': dateInput(startDate),
        'endDate': endDate == null ? '' : dateInput(endDate!),
      };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        daId: '${json['daId'] ?? ''}',
        position: '${json['position'] ?? ''}',
        workType: '${json['workType'] ?? 'full_time'}',
        startDate: parseDate('${json['startDate'] ?? ''}') ?? DateTime(2025, 1, 1),
        endDate: parseDate('${json['endDate'] ?? ''}'),
      );
}

class OvertimeEntry {
  OvertimeEntry({
    required this.id,
    required this.employeeId,
    required this.month,
    required this.targetMinutes,
    required this.workedMinutes,
    required this.paidMinutes,
    required this.paidInPeriod,
  });

  final String id;
  final String employeeId;
  final String month;
  final int targetMinutes;
  final int workedMinutes;
  final int paidMinutes;
  final String paidInPeriod;

  int get overtimeMinutes => workedMinutes - targetMinutes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'month': month,
        'targetMinutes': targetMinutes,
        'workedMinutes': workedMinutes,
        'paidMinutes': paidMinutes,
        'paidInPeriod': paidInPeriod,
      };

  factory OvertimeEntry.fromJson(Map<String, dynamic> json) => OvertimeEntry(
        id: '${json['id'] ?? ''}',
        employeeId: '${json['employeeId'] ?? ''}',
        month: '${json['month'] ?? ''}',
        targetMinutes: minutesFromAny(json['targetMinutes']),
        workedMinutes: minutesFromAny(json['workedMinutes']),
        paidMinutes: minutesFromAny(json['paidMinutes']),
        paidInPeriod: '${json['paidInPeriod'] ?? 'period_2'}',
      );
}

class PeriodPart {
  const PeriodPart({
    required this.months,
    required this.overtimeMinutes,
    required this.paidMinutes,
  });

  final int months;
  final int overtimeMinutes;
  final int paidMinutes;

  int get remainingMinutes => overtimeMinutes - paidMinutes;
}

class PeriodSummary {
  const PeriodSummary({required this.periodOne, required this.periodTwo});

  final PeriodPart periodOne;
  final PeriodPart periodTwo;

  int get overtimeMinutes => periodOne.overtimeMinutes + periodTwo.overtimeMinutes;
  int get paidMinutes => periodOne.paidMinutes + periodTwo.paidMinutes;
  int get remainingMinutes => periodOne.remainingMinutes + periodTwo.remainingMinutes;
}

class ZeitkontoPage extends StatefulWidget {
  const ZeitkontoPage({super.key});

  @override
  State<ZeitkontoPage> createState() => _ZeitkontoPageState();
}

class _ZeitkontoPageState extends State<ZeitkontoPage> {
  final _targetController = TextEditingController(text: '0:00');
  final _workedController = TextEditingController(text: '0:00');
  final _paidController = TextEditingController(text: '0:00');
  final _searchController = TextEditingController();

  List<Employee> _employees = [];
  List<OvertimeEntry> _entries = [];
  String _selectedEmployeeId = '';
  String _activeEmployeeId = '';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  String _paidPeriod = 'period_2';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _targetController.addListener(() => setState(() {}));
    _workedController.addListener(() => setState(() {}));
    _paidController.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _targetController.dispose();
    _workedController.dispose();
    _paidController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawEmployees = prefs.getString(_employeesKey);
    final rawEntries = prefs.getString(_entriesKey);
    final employees = rawEmployees == null
        ? _defaultEmployees()
        : (jsonDecode(rawEmployees) as List).map((item) => Employee.fromJson(Map<String, dynamic>.from(item))).toList();
    final entries = rawEntries == null
        ? <OvertimeEntry>[]
        : (jsonDecode(rawEntries) as List).map((item) => OvertimeEntry.fromJson(Map<String, dynamic>.from(item))).toList();

    setState(() {
      _employees = employees;
      _entries = entries;
      _selectedEmployeeId = employees.isEmpty ? '' : employees.first.id;
      _activeEmployeeId = employees.isEmpty ? '' : employees.first.id;
      _loading = false;
    });
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_employeesKey, jsonEncode(_employees.map((e) => e.toJson()).toList()));
    await prefs.setString(_entriesKey, jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  List<Employee> _defaultEmployees() => [
        Employee(
          id: 'emp-halim-osaj',
          name: 'Halim Osaj',
          daId: 'A2E8NSR90JPQC0',
          position: 'Dispatcher',
          workType: 'full_time',
          startDate: DateTime(2025, 10, 20),
        ),
      ];

  Employee? get _selectedEmployee => _employees.where((e) => e.id == _selectedEmployeeId).firstOrNull;
  Employee? get _activeEmployee => _employees.where((e) => e.id == _activeEmployeeId).firstOrNull;

  List<OvertimeEntry> _employeeEntries(String employeeId) {
    return _entries.where((entry) => entry.employeeId == employeeId).toList()
      ..sort((a, b) => b.month.compareTo(a.month));
  }

  PeriodSummary _summaryFor(String employeeId) {
    final employeeEntries = _employeeEntries(employeeId);
    final periodOneEntries = employeeEntries.where((entry) => entry.month.compareTo('2025-10') <= 0).toList();
    final periodTwoEntries = employeeEntries.where((entry) => entry.month.compareTo('2025-10') > 0).toList();
    final paidOne = employeeEntries
        .where((entry) => entry.paidInPeriod == 'period_1')
        .fold<int>(0, (sum, entry) => sum + entry.paidMinutes);
    final paidTwo = employeeEntries
        .where((entry) => entry.paidInPeriod == 'period_2')
        .fold<int>(0, (sum, entry) => sum + entry.paidMinutes);

    return PeriodSummary(
      periodOne: PeriodPart(
        months: periodOneEntries.length,
        overtimeMinutes: periodOneEntries.fold(0, (sum, entry) => sum + entry.overtimeMinutes),
        paidMinutes: paidOne,
      ),
      periodTwo: PeriodPart(
        months: periodTwoEntries.length,
        overtimeMinutes: periodTwoEntries.fold(0, (sum, entry) => sum + entry.overtimeMinutes),
        paidMinutes: paidTwo,
      ),
    );
  }

  void _saveMonth() {
    final employee = _selectedEmployee;
    if (employee == null) return;

    final month = monthKey(_selectedYear, _selectedMonth);
    final target = parseDuration(_targetController.text);
    final worked = parseDuration(_workedController.text);
    final paid = parseDuration(_paidController.text);
    final existingIndex = _entries.indexWhere((entry) => entry.employeeId == employee.id && entry.month == month);
    final entry = OvertimeEntry(
      id: existingIndex >= 0 ? _entries[existingIndex].id : 'ot-${employee.id}-$month',
      employeeId: employee.id,
      month: month,
      targetMinutes: target,
      workedMinutes: worked,
      paidMinutes: paid,
      paidInPeriod: _paidPeriod,
    );

    setState(() {
      if (existingIndex >= 0) {
        _entries[existingIndex] = entry;
      } else {
        _entries.add(entry);
      }
      _activeEmployeeId = employee.id;
      _targetController.text = '0:00';
      _workedController.text = '0:00';
      _paidController.text = '0:00';
    });
    _save();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Muaji u ruajt ne profil.')),
    );
  }

  Future<void> _addEmployeeDialog() async {
    final name = TextEditingController();
    final daId = TextEditingController();
    final position = TextEditingController(text: 'Dispatcher');
    final start = TextEditingController(text: dateInput(DateTime.now()));

    final saved = await showDialog<Employee>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regjistro punetor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Emri')),
              TextField(controller: daId, decoration: const InputDecoration(labelText: 'DA ID')),
              TextField(controller: position, decoration: const InputDecoration(labelText: 'Pozita')),
              TextField(controller: start, decoration: const InputDecoration(labelText: 'Data e fillimit YYYY-MM-DD')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anulo')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              Navigator.pop(
                context,
                Employee(
                  id: 'emp-${DateTime.now().millisecondsSinceEpoch}',
                  name: name.text.trim(),
                  daId: daId.text.trim(),
                  position: position.text.trim().isEmpty ? 'Dispatcher' : position.text.trim(),
                  workType: 'full_time',
                  startDate: parseDate(start.text.trim()) ?? DateTime.now(),
                ),
              );
            },
            child: const Text('Ruaj'),
          ),
        ],
      ),
    );

    if (saved == null) return;
    setState(() {
      _employees.add(saved);
      _employees.sort((a, b) => a.name.compareTo(b.name));
      _selectedEmployeeId = saved.id;
      _activeEmployeeId = saved.id;
    });
    _save();
  }

  Future<void> _downloadPdf(Employee employee) async {
    final summary = _summaryFor(employee.id);
    final entries = _employeeEntries(employee.id).reversed.toList();
    final doc = pw.Document();
    final orange = PdfColor.fromInt(0xFFF59A00);
    final ink = PdfColor.fromInt(0xFF24160A);
    final soft = PdfColor.fromInt(0xFFFFF7EC);

    pw.Widget statBox(String label, String value, {bool highlight = false}) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: highlight ? PdfColor.fromInt(0xFFE9F8ED) : soft,
          border: pw.Border.all(color: PdfColor.fromInt(0xFFE9D5B8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF7B6856))),
            pw.SizedBox(height: 4),
            pw.Text(value, style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: highlight ? ink : orange)),
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            color: orange,
            child: pw.Text('OverTime Report', style: pw.TextStyle(fontSize: 26, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(color: soft, border: pw.Border.all(color: PdfColor.fromInt(0xFFE9D5B8))),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(employee.name, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('DA ID: ${employee.daId.isEmpty ? '-' : employee.daId}'),
                ]),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Position: ${employee.position}'),
                  pw.Text('Work type: ${workTypeLabel(employee.workType)}'),
                ]),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(children: [
            pw.Expanded(child: statBox('Jan - October 2025', '${summary.periodOne.months} months')),
            pw.SizedBox(width: 10),
            pw.Expanded(child: statBox('Overtime', formatDuration(summary.periodOne.overtimeMinutes))),
            pw.SizedBox(width: 10),
            pw.Expanded(child: statBox('Paid hours', formatDuration(summary.periodOne.paidMinutes))),
            pw.SizedBox(width: 10),
            pw.Expanded(child: statBox('Left', formatDuration(summary.periodOne.remainingMinutes), highlight: summary.periodOne.remainingMinutes >= 0)),
          ]),
          pw.SizedBox(height: 10),
          pw.Row(children: [
            pw.Expanded(child: statBox('November 2025 - Today', '${summary.periodTwo.months} months')),
            pw.SizedBox(width: 10),
            pw.Expanded(child: statBox('Overtime', formatDuration(summary.periodTwo.overtimeMinutes))),
            pw.SizedBox(width: 10),
            pw.Expanded(child: statBox('Paid hours', formatDuration(summary.periodTwo.paidMinutes))),
            pw.SizedBox(width: 10),
            pw.Expanded(child: statBox('Left', formatDuration(summary.periodTwo.remainingMinutes), highlight: summary.periodTwo.remainingMinutes >= 0)),
          ]),
          pw.SizedBox(height: 22),
          pw.TableHelper.fromTextArray(
            headerDecoration: pw.BoxDecoration(color: soft),
            border: pw.TableBorder(horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0xFFE9D5B8), width: 0.7)),
            headers: const ['Month', 'Target', 'Worked', 'O/T', 'Paid', 'Period', 'Left'],
            data: entries
                .map((entry) => [
                      monthLabel(entry.month),
                      formatDuration(entry.targetMinutes),
                      formatDuration(entry.workedMinutes),
                      formatDuration(entry.overtimeMinutes),
                      formatDuration(entry.paidMinutes),
                      shortPeriodLabel(entry.paidInPeriod),
                      formatDuration(entry.overtimeMinutes - entry.paidMinutes),
                    ])
                .toList(),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF7B6856)),
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(color: soft, border: pw.Border.all(color: PdfColor.fromInt(0xFFE9D5B8))),
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Total OverTime', style: pw.TextStyle(color: PdfColor.fromInt(0xFF7B6856))),
                pw.Text(formatDuration(summary.remainingMinutes), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: orange)),
              ]),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'arion-zeitkonto-${employee.name.replaceAll(RegExp(r'\s+'), '-').toLowerCase()}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredEmployees = _employees
        .where((employee) => employee.name.toLowerCase().contains(_searchController.text.trim().toLowerCase()))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final active = _activeEmployee;
    final overtimePreview = parseDuration(_workedController.text) - parseDuration(_targetController.text);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEmployeeDialog,
        label: const Text('Punetor i ri'),
        icon: const Icon(Icons.person_add_alt_1),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _Header(totalEmployees: _employees.length),
            const SizedBox(height: 16),
            _EntryCard(
              employees: _employees,
              selectedEmployeeId: _selectedEmployeeId,
              selectedMonth: _selectedMonth,
              selectedYear: _selectedYear,
              paidPeriod: _paidPeriod,
              targetController: _targetController,
              workedController: _workedController,
              paidController: _paidController,
              overtimePreview: overtimePreview,
              onEmployeeChanged: (value) => setState(() {
                _selectedEmployeeId = value;
                _activeEmployeeId = value;
              }),
              onMonthChanged: (value) => setState(() {
                _selectedMonth = value;
                _paidPeriod = monthKey(_selectedYear, _selectedMonth).compareTo('2025-10') <= 0 ? 'period_1' : 'period_2';
              }),
              onYearChanged: (value) => setState(() {
                _selectedYear = value;
                _paidPeriod = monthKey(_selectedYear, _selectedMonth).compareTo('2025-10') <= 0 ? 'period_1' : 'period_2';
              }),
              onPaidPeriodChanged: (value) => setState(() => _paidPeriod = value),
              onSave: _saveMonth,
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('Puntoret', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))),
                      SizedBox(
                        width: 260,
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...filteredEmployees.map((employee) {
                    final summary = _summaryFor(employee.id);
                    final isActive = active?.id == employee.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          _EmployeeTile(
                            employee: employee,
                            summary: summary,
                            active: isActive,
                            onTap: () => setState(() {
                              _activeEmployeeId = employee.id;
                              _selectedEmployeeId = employee.id;
                            }),
                          ),
                          if (isActive)
                            _EmployeeProfile(
                              employee: employee,
                              entries: _employeeEntries(employee.id),
                              summary: summary,
                              onPdf: () => _downloadPdf(employee),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.totalEmployees});

  final int totalEmployees;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ARION OFFICE', style: TextStyle(color: _brand, fontWeight: FontWeight.w900, letterSpacing: 5)),
                const SizedBox(height: 8),
                Text('Zeitkonto', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 56)),
                const SizedBox(height: 8),
                const Text('Oret shtese, pagesat dhe mbetja sipas muajve.', style: TextStyle(color: _muted)),
              ],
            ),
          ),
          _MiniStat(label: 'Punetore', value: '$totalEmployees'),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.employees,
    required this.selectedEmployeeId,
    required this.selectedMonth,
    required this.selectedYear,
    required this.paidPeriod,
    required this.targetController,
    required this.workedController,
    required this.paidController,
    required this.overtimePreview,
    required this.onEmployeeChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onPaidPeriodChanged,
    required this.onSave,
  });

  final List<Employee> employees;
  final String selectedEmployeeId;
  final int selectedMonth;
  final int selectedYear;
  final String paidPeriod;
  final TextEditingController targetController;
  final TextEditingController workedController;
  final TextEditingController paidController;
  final int overtimePreview;
  final ValueChanged<String> onEmployeeChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<String> onPaidPeriodChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final years = List.generate(7, (index) => 2024 + index);
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Regjistro muajin', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Wrap(
            runSpacing: 14,
            spacing: 14,
            children: [
              _FieldBox(
                label: 'Punetori',
                width: 360,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedEmployeeId.isEmpty ? null : selectedEmployeeId,
                  items: employees.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.name} (${e.daId})'))).toList(),
                  onChanged: (value) => value == null ? null : onEmployeeChanged(value),
                ),
              ),
              _FieldBox(
                label: 'Muaji',
                child: DropdownButtonFormField<int>(
                  initialValue: selectedMonth,
                  items: List.generate(12, (index) {
                    final month = index + 1;
                    return DropdownMenuItem(value: month, child: Text(monthNames[month - 1]));
                  }),
                  onChanged: (value) => value == null ? null : onMonthChanged(value),
                ),
              ),
              _FieldBox(
                label: 'Viti',
                child: DropdownButtonFormField<int>(
                  initialValue: selectedYear,
                  items: years.map((year) => DropdownMenuItem(value: year, child: Text('$year'))).toList(),
                  onChanged: (value) => value == null ? null : onYearChanged(value),
                ),
              ),
              _FieldBox(label: 'Oret totale te muajit', child: TextField(controller: targetController)),
              _FieldBox(label: 'Oret e punuara', child: TextField(controller: workedController)),
              _FieldBox(label: 'Oret e paguara', child: TextField(controller: paidController)),
              _FieldBox(
                label: 'Paguar per periudhen',
                width: 360,
                child: DropdownButtonFormField<String>(
                  initialValue: paidPeriod,
                  items: const [
                    DropdownMenuItem(value: 'period_1', child: Text('Jan - October 2025')),
                    DropdownMenuItem(value: 'period_2', child: Text('November 2025 - Today')),
                  ],
                  onChanged: (value) => value == null ? null : onPaidPeriodChanged(value),
                ),
              ),
              _MiniStat(label: 'Overtime', value: formatDuration(overtimePreview), width: 220),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _brandDark, foregroundColor: Colors.white),
            onPressed: employees.isEmpty ? null : onSave,
            icon: const Icon(Icons.save_alt),
            label: const Text('Ruaj muajin'),
          ),
        ],
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.summary, required this.active, required this.onTap});

  final Employee employee;
  final PeriodSummary summary;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFF3DD) : Colors.white,
          border: Border.all(color: active ? _brand : const Color(0xFFEBD8BD)),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: _brand.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employee.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 18,
                    runSpacing: 8,
                    children: [
                      Text('DA ID: ${employee.daId.isEmpty ? '-' : employee.daId}', style: const TextStyle(color: _muted)),
                      Text('Start: ${displayDate(employee.startDate)}', style: const TextStyle(color: _muted)),
                      Text('End: ${employee.endDate == null ? '-' : displayDate(employee.endDate!)}', style: const TextStyle(color: _muted)),
                    ],
                  ),
                ],
              ),
            ),
            _MiniStat(label: 'Zeitkonto', value: formatDuration(summary.remainingMinutes), width: 160),
          ],
        ),
      ),
    );
  }
}

class _EmployeeProfile extends StatelessWidget {
  const _EmployeeProfile({required this.employee, required this.entries, required this.summary, required this.onPdf});

  final Employee employee;
  final List<OvertimeEntry> entries;
  final PeriodSummary summary;
  final VoidCallback onPdf;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        border: Border.all(color: const Color(0xFFEBD8BD)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('${employee.name} - Profil', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _brandDark, foregroundColor: Colors.white),
                onPressed: onPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MiniStat(label: 'Jan - Oct O/T', value: formatDuration(summary.periodOne.overtimeMinutes), width: 170),
              _MiniStat(label: 'Jan - Oct paid', value: formatDuration(summary.periodOne.paidMinutes), width: 170),
              _MiniStat(label: 'Jan - Oct left', value: formatDuration(summary.periodOne.remainingMinutes), width: 170),
              _MiniStat(label: 'Nov - Today O/T', value: formatDuration(summary.periodTwo.overtimeMinutes), width: 170),
              _MiniStat(label: 'Nov - Today paid', value: formatDuration(summary.periodTwo.paidMinutes), width: 170),
              _MiniStat(label: 'Nov - Today left', value: formatDuration(summary.periodTwo.remainingMinutes), width: 170),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Historia mujore', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Muaji')),
                DataColumn(label: Text('Target')),
                DataColumn(label: Text('Punuar')),
                DataColumn(label: Text('O/T')),
                DataColumn(label: Text('Paguar')),
                DataColumn(label: Text('Periudha')),
                DataColumn(label: Text('Mbetja')),
              ],
              rows: entries
                  .map(
                    (entry) => DataRow(cells: [
                      DataCell(Text(monthLabel(entry.month))),
                      DataCell(Text(formatDuration(entry.targetMinutes))),
                      DataCell(Text(formatDuration(entry.workedMinutes))),
                      DataCell(Text(formatDuration(entry.overtimeMinutes), style: const TextStyle(color: _brandDark, fontWeight: FontWeight.w800))),
                      DataCell(Text(formatDuration(entry.paidMinutes))),
                      DataCell(Text(shortPeriodLabel(entry.paidInPeriod))),
                      DataCell(Text(formatDuration(entry.overtimeMinutes - entry.paidMinutes))),
                    ]),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: Border.all(color: const Color(0xFFEBD8BD)),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: _brand.withValues(alpha: 0.10), blurRadius: 35, offset: const Offset(0, 18))],
      ),
      child: child,
    );
  }
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.label, required this.child, this.width = 250});

  final String label;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.width = 140});

  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF3),
        border: Border.all(color: const Color(0xFFEBD8BD)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        ],
      ),
    );
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

const monthNames = [
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

String monthKey(int year, int month) => '$year-${month.toString().padLeft(2, '0')}';

String monthLabel(String month) {
  final parts = month.split('-');
  if (parts.length != 2) return month;
  final monthNumber = int.tryParse(parts[1]) ?? 1;
  final year = parts[0];
  return '${monthNames[monthNumber - 1]} $year';
}

String shortPeriodLabel(String key) => key == 'period_1' ? 'Jan-Oct 2025' : 'Nov 2025-Today';

String workTypeLabel(String value) {
  if (value == 'part_time') return 'Part time';
  if (value == 'mini_job') return 'Mini Job';
  return 'Full time';
}

DateTime? parseDate(String value) {
  if (value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}

String dateInput(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

String displayDate(DateTime date) => DateFormat('dd.MM.yyyy').format(date);

int minutesFromAny(dynamic value) {
  if (value is num) return value.round();
  return parseDuration('$value');
}

int parseDuration(String value) {
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

String formatDuration(int minutesValue) {
  final isNegative = minutesValue < 0;
  final absolute = minutesValue.abs();
  final hours = absolute ~/ 60;
  final minutes = absolute % 60;
  return '${isNegative ? '-' : ''}$hours:${minutes.toString().padLeft(2, '0')}';
}
