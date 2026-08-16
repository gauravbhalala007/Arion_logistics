// lib/Screens/seso_overview_page.dart
//
// "SESO" tab inside the Fleet-Hub. Lets the DSP admin record
// confirmations for self-sourced vehicles, track per-week payment
// status, and attach screenshots of the original confirmation + the
// payment receipt.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/seso_confirmation.dart';
import '../services/seso_confirmation_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_typography.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';

class SesoOverviewPage extends StatefulWidget {
  /// The DSP admin UID whose SESO data this page operates on.
  /// For an admin this is their own uid; for a dispatcher it's
  /// `AdminScope.adminUidOf(context)` — passed in by the caller.
  final String dspUid;
  const SesoOverviewPage({super.key, required this.dspUid});

  @override
  State<SesoOverviewPage> createState() => _SesoOverviewPageState();
}

class _SesoOverviewPageState extends State<SesoOverviewPage> {
  final _repo = SesoConfirmationRepository();

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Container(
      color: const Color(0xFFF3F6F7),
      child: StreamBuilder<List<SesoConfirmation>>(
        stream: _repo.watch(widget.dspUid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const CoStateSwitcher(
              child: Center(
                key: ValueKey('seso-loading'),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.codriverGreen,
                  ),
                ),
              ),
            );
          }
          final items = snap.data ?? const [];

          final totalOpen = items.fold<double>(0, (s, c) => s + c.openCost);
          final totalPaid = items.fold<double>(0, (s, c) => s + c.paidCost);
          final openWeeks = items.fold<int>(
            0,
            (s, c) => s + c.weeks.where((w) => !w.paid).length,
          );

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      de ? 'SESO Fahrzeuge' : 'SESO vehicles',
                      style: AppTypography.title2.copyWith(
                        color: AppColors.codriverGraphite,
                      ),
                    ),
                    const Spacer(),
                    CoButton(
                      onPressed: () => _openCreateOrEditDialog(),
                      icon: Icons.add_rounded,
                      label: de ? 'Anlegen' : 'Add',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  de
                      ? 'Confirmations für selbst beschaffte Fahrzeuge + Zahlungs-Tracking.'
                      : 'Confirmations for self-sourced vehicles + payment tracking.',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.labelSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: de ? 'Offen' : 'Open',
                        value: _euro(totalOpen),
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: de ? 'Bezahlt' : 'Paid',
                        value: _euro(totalPaid),
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: de ? '# Unbezahlte Wochen' : '# Unpaid weeks',
                        value: '$openWeeks',
                        color: AppColors.codriverDeep,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: CoStateSwitcher(
                    child: items.isEmpty
                        ? _EmptyState(
                            key: const ValueKey('seso-empty'),
                            onAdd: _openCreateOrEditDialog,
                          )
                        : ListView.separated(
                            key: const ValueKey('seso-list'),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) => _ConfirmationCard(
                              dspUid: widget.dspUid,
                              confirmation: items[i],
                              onTap: () => _openDetail(items[i]),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openCreateOrEditDialog([SesoConfirmation? existing]) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _SesoEditorDialog(
        dspUid: widget.dspUid,
        repo: _repo,
        existing: existing,
      ),
    );
  }

  Future<void> _openDetail(SesoConfirmation c) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SesoDetailPage(
          dspUid: widget.dspUid,
          confirmationId: c.id,
        ),
      ),
    );
  }
}

String _euro(double v) => '€${v.toStringAsFixed(2)}';

String _dmy(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.${d.year}';

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool bold;
  const _PreviewRow({
    required this.label,
    required this.value,
    this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.codriverDeep;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.footnote.copyWith(
                color: c,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.footnote.copyWith(
              color: c,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Cards / overview rows
// ════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.title2.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationCard extends StatelessWidget {
  final String dspUid;
  final SesoConfirmation confirmation;
  final VoidCallback onTap;
  const _ConfirmationCard({
    required this.dspUid,
    required this.confirmation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final c = confirmation;
    final typeColor = c.vehicleType == SesoVehicleType.lwb
        ? const Color(0xFF7B5BFF)
        : AppColors.codriverGreen;
    return CoPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: AppElevation.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    c.vehicleType.label,
                    style: AppTypography.caption1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.transactionId.isEmpty
                            ? (c.orderId.isEmpty ? '—' : c.orderId)
                            : c.transactionId,
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.codriverGraphite,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (c.orderId.isNotEmpty &&
                          c.transactionId.isNotEmpty)
                        Text(
                          de
                              ? 'Auftrag: ${c.orderId}'
                              : 'Order: ${c.orderId}',
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.labelSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  c.offPeak
                      ? '€${c.dailyRate.toStringAsFixed(2)}/${de ? 'T' : 'd'} · Off-Peak'
                      : '€${c.dailyRate.toStringAsFixed(2)}/${de ? 'T' : 'd'}',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF9CA3AF)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final w in c.weeks)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: w.paid
                          ? AppColors.green50
                          : const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: w.paid
                            ? AppColors.codriverGreen.withOpacity(0.45)
                            : AppColors.warning.withOpacity(0.45),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          w.paid
                              ? Icons.check_rounded
                              : Icons.hourglass_empty_rounded,
                          size: 11,
                          color: w.paid
                              ? AppColors.codriverDeep
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${de ? 'KW' : 'CW'} '
                          '${w.weekNumber.toString().padLeft(2, '0')}',
                          style: AppTypography.caption2.copyWith(
                            color: w.paid
                                ? AppColors.codriverDeep
                                : AppColors.warning,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MetricChip(
                  label: 'Total',
                  value: _euro(c.totalCost),
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  label: de ? 'Bezahlt' : 'Paid',
                  value: _euro(c.paidCost),
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  label: de ? 'Offen' : 'Open',
                  value: _euro(c.openCost),
                  color: c.openCost > 0 ? AppColors.warning : AppColors.success,
                ),
                const Spacer(),
                if (c.confirmationScreenshotPath != null)
                  _ConfirmationThumb(path: c.confirmationScreenshotPath!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _MetricChip({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label:',
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTypography.caption1.copyWith(
              color: color ?? AppColors.codriverGraphite,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationThumb extends StatelessWidget {
  final String path;
  const _ConfirmationThumb({required this.path});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: FirebaseStorage.instance.ref(path).getDownloadURL(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.image_outlined,
              size: 18,
              color: Color(0xFF9CA3AF),
            ),
          );
        }
        final url = snap.data!;
        final isPdf = path.toLowerCase().endsWith('.pdf');
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isPdf
              ? Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  color: AppColors.surfaceLight,
                  child: const Icon(Icons.picture_as_pdf_rounded,
                      color: Color(0xFF6B7280)),
                )
              : Image.network(
                  url,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Center(
      child: SizedBox(
        width: 360,
        child: CoStaggerList(
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  size: 28,
                  color: AppColors.codriverDeep,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              de
                  ? 'Noch keine SESO-Confirmations.'
                  : 'No SESO confirmations yet.',
              style: AppTypography.subheadline.copyWith(
                color: AppColors.codriverGraphite,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              de
                  ? 'Lege eine Confirmation an: Fahrzeugtyp, Tagespreis und KWs.'
                  : 'Create a confirmation: vehicle type, daily rate and CWs.',
              style: AppTypography.footnote.copyWith(
                color: AppColors.labelSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Center(
              child: CoButton(
                onPressed: onAdd,
                icon: Icons.add_rounded,
                label: de ? 'Confirmation anlegen' : 'Add confirmation',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Editor dialog (create + edit)
// ════════════════════════════════════════════════════════════════════════════

class _SesoEditorDialog extends StatefulWidget {
  final String dspUid;
  final SesoConfirmationRepository repo;
  final SesoConfirmation? existing;
  const _SesoEditorDialog({
    required this.dspUid,
    required this.repo,
    this.existing,
  });

  @override
  State<_SesoEditorDialog> createState() => _SesoEditorDialogState();
}

class _SesoEditorDialogState extends State<_SesoEditorDialog> {
  late SesoVehicleType _type;
  bool _offPeak = false;
  late TextEditingController _rateCtrl;
  late TextEditingController _partnerRateCtrl;
  late TextEditingController _noteCtrl;
  late TextEditingController _transactionIdCtrl;
  late TextEditingController _orderIdCtrl;
  late TextEditingController _vehicleCountCtrl;
  late int _year;
  late Set<int> _selectedWeeks;
  String? _rentalCompanyId;
  bool _saving = false;
  String? _error;
  Uint8List? _confirmationFileBytes;
  String? _confirmationFileName;
  Uint8List? _invoiceFileBytes;
  String? _invoiceFileName;

  static const Map<SesoVehicleType, double> _peakRates = {
    SesoVehicleType.swb: 53.23,
    SesoVehicleType.lwb: 57.26,
  };
  static const Map<SesoVehicleType, double> _offPeakRates = {
    SesoVehicleType.swb: 41.63,
    SesoVehicleType.lwb: 48.63,
  };

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _type = ex?.vehicleType ?? SesoVehicleType.swb;
    _offPeak = ex?.offPeak ?? false;
    _rateCtrl = TextEditingController(
      text: ex == null
          ? _peakRates[_type]!.toStringAsFixed(2)
          : ex.dailyRate.toStringAsFixed(2),
    );
    _partnerRateCtrl = TextEditingController(
      text: (ex?.partnerDailyRate ?? 0) > 0
          ? ex!.partnerDailyRate.toStringAsFixed(2)
          : '',
    );
    _noteCtrl = TextEditingController(text: ex?.note ?? '');
    _transactionIdCtrl = TextEditingController(text: ex?.transactionId ?? '');
    _orderIdCtrl = TextEditingController(text: ex?.orderId ?? '');
    final initialCount = ex?.vehicleCount ??
        ex?.pickupVehicleCount ??
        ex?.returnVehicleCount;
    _vehicleCountCtrl = TextEditingController(
      text: initialCount?.toString() ?? '',
    );
    final now = DateTime.now();
    _year = ex?.weeks.isNotEmpty == true ? ex!.weeks.first.year : now.year;
    _selectedWeeks = {
      for (final w in ex?.weeks ?? const <SesoWeekEntry>[]) w.weekNumber,
    };
    _rentalCompanyId = ex?.rentalCompanyId;
  }

  @override
  void dispose() {
    _rateCtrl.dispose();
    _partnerRateCtrl.dispose();
    _noteCtrl.dispose();
    _transactionIdCtrl.dispose();
    _orderIdCtrl.dispose();
    _vehicleCountCtrl.dispose();
    super.dispose();
  }

  double get _rate => double.tryParse(_rateCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _partnerRate =>
      double.tryParse(_partnerRateCtrl.text.replaceAll(',', '.')) ?? 0;

  void _applyStandardRate() {
    final rate =
        (_offPeak ? _offPeakRates[_type]! : _peakRates[_type]!);
    _rateCtrl.text = rate.toStringAsFixed(2);
  }

  /// Monday of the given ISO week (1..53). Matches the week-number
  /// convention used by `_isoWeek` elsewhere in the app (Jan-4 rule).
  static DateTime _mondayOfIsoWeek(int year, int week) {
    final jan4 = DateTime(year, 1, 4);
    final firstMonday = jan4.subtract(Duration(days: jan4.weekday - 1));
    return firstMonday.add(Duration(days: (week - 1) * 7));
  }

  /// Sunday of the given ISO week (= Monday + 6 days).
  static DateTime _sundayOfIsoWeek(int year, int week) =>
      _mondayOfIsoWeek(year, week).add(const Duration(days: 6));

  Future<void> _pickConfirmationFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    if (f.bytes == null) return;
    setState(() {
      _confirmationFileBytes = f.bytes;
      _confirmationFileName = f.name;
    });
  }

  Future<void> _pickInvoiceFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    if (f.bytes == null) return;
    setState(() {
      _invoiceFileBytes = f.bytes;
      _invoiceFileName = f.name;
    });
  }

  Future<void> _save() async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final rate = _rate;
    final partnerRate = _partnerRate;
    final txId = _transactionIdCtrl.text.trim();
    final orderId = _orderIdCtrl.text.trim();
    if (txId.isEmpty && orderId.isEmpty) {
      setState(() => _error = de
          ? 'Mindestens Transaktions-ID oder Auftrags-ID eingeben.'
          : 'Enter at least a transaction ID or an order ID.');
      return;
    }
    if (rate <= 0) {
      setState(() => _error = de
          ? 'Tagespreis muss > 0 sein.'
          : 'Daily rate must be > 0.');
      return;
    }
    if (_selectedWeeks.isEmpty) {
      setState(() => _error = de
          ? 'Mindestens eine KW auswählen.'
          : 'Select at least one calendar week.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final weeks = _selectedWeeks.toList()..sort();
      final existing = widget.existing;

      final priorByKey = <String, SesoWeekEntry>{
        for (final w in existing?.weeks ?? const <SesoWeekEntry>[])
          '${w.year}_${w.weekNumber}': w,
      };

      final newWeeks = [
        for (final wn in weeks)
          priorByKey['${_year}_$wn'] ??
              SesoWeekEntry(year: _year, weekNumber: wn),
      ];

      // Pickup = Monday of first selected KW; Return = Sunday of last.
      final firstWeek = weeks.first;
      final lastWeek = weeks.last;
      final pickupDate = _mondayOfIsoWeek(_year, firstWeek);
      final returnDate = _sundayOfIsoWeek(_year, lastWeek);
      final vehicleCount =
          int.tryParse(_vehicleCountCtrl.text.trim()) ?? 0;

      String confirmationId;
      if (existing == null) {
        confirmationId = await widget.repo.create(
          dspUid: widget.dspUid,
          transactionId: txId,
          orderId: orderId,
          vehicleType: _type,
          dailyRate: rate,
          partnerDailyRate: partnerRate,
          offPeak: _offPeak,
          weeks: newWeeks,
          note: _noteCtrl.text.trim(),
          rentalCompanyId: _rentalCompanyId,
          pickupDate: pickupDate,
          returnDate: returnDate,
          vehicleCount: vehicleCount > 0 ? vehicleCount : null,
        );
      } else {
        confirmationId = existing.id;
        await widget.repo.update(
          dspUid: widget.dspUid,
          confirmationId: existing.id,
          transactionId: txId,
          orderId: orderId,
          vehicleType: _type,
          dailyRate: rate,
          partnerDailyRate: partnerRate,
          offPeak: _offPeak,
          weeks: newWeeks,
          note: _noteCtrl.text.trim(),
          rentalCompanyId: _rentalCompanyId,
          clearRentalCompany: _rentalCompanyId == null,
          pickupDate: pickupDate,
          returnDate: returnDate,
          vehicleCount: vehicleCount > 0 ? vehicleCount : null,
        );
      }

      if (_confirmationFileBytes != null && _confirmationFileName != null) {
        final path = await widget.repo.uploadConfirmationScreenshot(
          dspUid: widget.dspUid,
          confirmationId: confirmationId,
          bytes: _confirmationFileBytes!,
          filename: _confirmationFileName!,
        );
        await widget.repo.update(
          dspUid: widget.dspUid,
          confirmationId: confirmationId,
          confirmationScreenshotPath: path,
        );
      }
      if (_invoiceFileBytes != null && _invoiceFileName != null) {
        final path = await widget.repo.uploadInvoiceScreenshot(
          dspUid: widget.dspUid,
          confirmationId: confirmationId,
          bytes: _invoiceFileBytes!,
          filename: _invoiceFileName!,
        );
        await widget.repo.update(
          dspUid: widget.dspUid,
          confirmationId: confirmationId,
          invoiceScreenshotPath: path,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final isEdit = widget.existing != null;
    final weekCount = _selectedWeeks.length;
    final vehicleCount =
        int.tryParse(_vehicleCountCtrl.text.trim()) ?? 0;
    final units = vehicleCount > 0 ? vehicleCount : 1;
    final weeklyCost = sesoWeeklyCost(_rate) * units;
    final totalCost = sesoTotalCost(_rate, weekCount) * units;
    final weeklyPartner = _partnerRate * 7 * units;
    final totalPartner = weeklyPartner * weekCount;
    final dailyDiff = _rate - _partnerRate;
    final weeklyDiff = dailyDiff * 7 * units;
    final totalDiff = weeklyDiff * weekCount;
    final hasPartner = _partnerRate > 0;

    // Derived period — Monday of first selected KW → Sunday of last.
    DateTime? periodStart;
    DateTime? periodEnd;
    if (_selectedWeeks.isNotEmpty) {
      final sorted = _selectedWeeks.toList()..sort();
      periodStart = _mondayOfIsoWeek(_year, sorted.first);
      periodEnd = _sundayOfIsoWeek(_year, sorted.last);
    }

    return AlertDialog(
      title: Text(
        isEdit
            ? (de ? 'Confirmation bearbeiten' : 'Edit confirmation')
            : (de ? 'Neue Confirmation' : 'New confirmation'),
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _transactionIdCtrl,
                      decoration: InputDecoration(
                        labelText: de ? 'Transaktions-ID' : 'Transaction ID',
                        hintText: de
                            ? 'aus der E-Mail einfügen'
                            : 'paste from the email',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _orderIdCtrl,
                      decoration: InputDecoration(
                        labelText: de ? 'Auftrags-ID' : 'Order ID',
                        hintText: de
                            ? 'aus der E-Mail einfügen'
                            : 'paste from the email',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('SWB'),
                      selected: _type == SesoVehicleType.swb,
                      onSelected: (_) {
                        setState(() {
                          _type = SesoVehicleType.swb;
                          _applyStandardRate();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('LWB'),
                      selected: _type == SesoVehicleType.lwb,
                      onSelected: (_) {
                        setState(() {
                          _type = SesoVehicleType.lwb;
                          _applyStandardRate();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Peak vs Off-Peak — mutually exclusive ChoiceChips.
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text('Peak (${_euro(_peakRates[_type]!)})'),
                      selected: !_offPeak,
                      onSelected: (_) {
                        setState(() {
                          _offPeak = false;
                          _applyStandardRate();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: Text('Off-Peak (${_euro(_offPeakRates[_type]!)})'),
                      selected: _offPeak,
                      onSelected: (_) {
                        setState(() {
                          _offPeak = true;
                          _applyStandardRate();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Mietfirma picker — streams the admin's rental_companies.
              StreamBuilder<List<RentalCompany>>(
                stream: widget.repo.watchRentalCompanies(widget.dspUid),
                builder: (context, snap) {
                  final companies = snap.data ?? const <RentalCompany>[];
                  final exists = _rentalCompanyId == null
                      ? true
                      : companies.any((c) => c.id == _rentalCompanyId);
                  if (!exists) {
                    // The previously-selected company was deleted while
                    // this dialog was open; clear the selection.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _rentalCompanyId = null);
                    });
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _rentalCompanyId,
                          decoration: InputDecoration(
                            labelText: de ? 'Mietfirma' : 'Rental company',
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(de ? '— keine —' : '— none —'),
                            ),
                            for (final c in companies)
                              DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(c.name),
                              ),
                          ],
                          onChanged: (v) =>
                              setState(() => _rentalCompanyId = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: de
                            ? 'Mietfirmen verwalten'
                            : 'Manage rental companies',
                        icon: const Icon(Icons.business_rounded),
                        onPressed: () => _showRentalCompaniesDialog(
                          context: context,
                          repo: widget.repo,
                          dspUid: widget.dspUid,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              // Number of vehicles for the whole period (not per
              // pickup/return). Pickup-date = Monday of first selected
              // KW, return-date = Sunday of last selected KW — both
              // derived from the KW grid below.
              TextField(
                controller: _vehicleCountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: de
                      ? 'Anzahl Fahrzeuge im Zeitraum'
                      : 'Number of vehicles in period',
                  prefixIcon: const Icon(Icons.local_shipping_outlined),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              // Side-by-side: DSP-Vergütung (Income) ↔ Mietpartner-Kosten
              // (Cost). Beide pro Tag und Fahrzeug. Differenz = Marge/Tag.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _rateCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: de
                            ? 'Vergüteter DSP-Tagespreis (netto)'
                            : 'DSP daily rate paid (net)',
                        helperText: de
                            ? 'Was Amazon pro Tag zahlt'
                            : 'What Amazon pays per day',
                        prefixText: '€ ',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _partnerRateCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: de
                            ? 'Tatsächlicher Mietpreis / Tag'
                            : 'Actual rental price / day',
                        helperText: de
                            ? 'Was die Mietfirma pro Tag berechnet'
                            : 'What the rental company charges per day',
                        prefixText: '€ ',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    de ? 'Jahr:' : 'Year:',
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.codriverGraphite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _year--),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text(
                    '$_year',
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.codriverGraphite,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _year++),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                  const Spacer(),
                  if (weekCount > 0)
                    Text(
                      de ? '$weekCount KWs' : '$weekCount CWs',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.codriverDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (var w = 1; w <= 53; w++)
                    ChoiceChip(
                      label: Text('${w.toString().padLeft(2, '0')}'),
                      selected: _selectedWeeks.contains(w),
                      onSelected: (s) {
                        setState(() {
                          if (s) {
                            _selectedWeeks.add(w);
                          } else {
                            _selectedWeeks.remove(w);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (periodStart != null && periodEnd != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${de ? 'Zeitraum' : 'Period'}: '
                          '${_dmy(periodStart)} → ${_dmy(periodEnd)}',
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.codriverDeep,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    _PreviewRow(
                      label: vehicleCount > 0
                          ? (de
                              ? 'Wochenpreis ($vehicleCount Fahrzeug${vehicleCount == 1 ? '' : 'e'})'
                              : 'Weekly cost ($vehicleCount vehicle${vehicleCount == 1 ? '' : 's'})')
                          : (de ? 'Wochenpreis' : 'Weekly cost'),
                      value: _euro(weeklyCost),
                    ),
                    _PreviewRow(
                      label: de ? 'Gesamt DSP' : 'Total DSP',
                      value:
                          '${_euro(totalCost)}  ($weekCount × ${_euro(weeklyCost)})',
                      bold: true,
                    ),
                    if (hasPartner) ...[
                      const Divider(height: 16, thickness: 0.5),
                      _PreviewRow(
                        label: vehicleCount > 0
                            ? (de
                                ? 'Mietpartner pro Woche ($vehicleCount Fahrzeug${vehicleCount == 1 ? '' : 'e'})'
                                : 'Rental partner per week ($vehicleCount vehicle${vehicleCount == 1 ? '' : 's'})')
                            : (de
                                ? 'Mietpartner pro Woche'
                                : 'Rental partner per week'),
                        value: _euro(weeklyPartner),
                      ),
                      _PreviewRow(
                        label: de
                            ? 'Gesamt Mietpartner'
                            : 'Total rental partner',
                        value: _euro(totalPartner),
                        bold: true,
                      ),
                      const SizedBox(height: 6),
                      _PreviewRow(
                        label: de ? 'Differenz / Tag' : 'Difference / day',
                        value:
                            '${dailyDiff >= 0 ? '+' : ''}${dailyDiff.toStringAsFixed(2)} €',
                        color: dailyDiff >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      _PreviewRow(
                        label: de ? 'Marge Woche' : 'Margin week',
                        value:
                            '${weeklyDiff >= 0 ? '+' : ''}${_euro(weeklyDiff)}',
                        color: weeklyDiff >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      _PreviewRow(
                        label: de ? 'Marge Gesamt' : 'Margin total',
                        value:
                            '${totalDiff >= 0 ? '+' : ''}${_euro(totalDiff)}',
                        color: totalDiff >= 0
                            ? AppColors.success
                            : AppColors.error,
                        bold: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: de ? 'Notiz (optional)' : 'Note (optional)',
                ),
              ),
              const SizedBox(height: 12),
              _FilePickRow(
                label: de
                    ? 'Confirmation (E-Mail/Screenshot)'
                    : 'Confirmation (email/screenshot)',
                pickedName: _confirmationFileName,
                existingPlaceholder:
                    widget.existing?.confirmationScreenshotPath != null
                        ? (de ? 'Bereits hochgeladen' : 'Already uploaded')
                        : (de ? 'Keine Datei ausgewählt' : 'No file selected'),
                onPick: _saving ? null : _pickConfirmationFile,
              ),
              const SizedBox(height: 8),
              _FilePickRow(
                label: de ? 'Bezahlte Rechnung' : 'Paid invoice',
                pickedName: _invoiceFileName,
                existingPlaceholder:
                    widget.existing?.invoiceScreenshotPath != null
                        ? (de ? 'Bereits hochgeladen' : 'Already uploaded')
                        : (de ? 'Keine Datei ausgewählt' : 'No file selected'),
                onPick: _saving ? null : _pickInvoiceFile,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(color: AppColors.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        CoButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          label: 'Abbrechen',
          variant: CoButtonVariant.quiet,
        ),
        CoButton(
          onPressed: _saving ? null : _save,
          label: 'Speichern',
          busy: _saving,
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Detail page
// ════════════════════════════════════════════════════════════════════════════

class _SesoDetailPage extends StatefulWidget {
  final String dspUid;
  final String confirmationId;
  const _SesoDetailPage({
    required this.dspUid,
    required this.confirmationId,
  });

  @override
  State<_SesoDetailPage> createState() => _SesoDetailPageState();
}

class _SesoDetailPageState extends State<_SesoDetailPage> {
  final _repo = SesoConfirmationRepository();

  Stream<DocumentSnapshot<Map<String, dynamic>>> _stream() => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('seso_confirmations')
      .doc(widget.confirmationId)
      .snapshots();

  Future<void> _togglePaid(
    SesoConfirmation c,
    SesoWeekEntry week,
  ) async {
    final newWeeks = [
      for (final w in c.weeks)
        if (w.year == week.year && w.weekNumber == week.weekNumber)
          w.copyWith(
            paid: !w.paid,
            paidAt: !w.paid ? DateTime.now() : null,
            clearPaidAt: w.paid,
          )
        else
          w,
    ];
    await _repo.update(
      dspUid: widget.dspUid,
      confirmationId: c.id,
      weeks: newWeeks,
    );
  }

  Future<void> _uploadPaymentScreenshot(
    SesoConfirmation c,
    SesoWeekEntry week,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    if (f.bytes == null) return;
    final path = await _repo.uploadPaymentScreenshot(
      dspUid: widget.dspUid,
      confirmationId: c.id,
      week: week,
      bytes: f.bytes!,
      filename: f.name,
    );
    final newWeeks = [
      for (final w in c.weeks)
        if (w.year == week.year && w.weekNumber == week.weekNumber)
          w.copyWith(
            paid: true,
            paidAt: w.paidAt ?? DateTime.now(),
            paymentScreenshotPath: path,
          )
        else
          w,
    ];
    await _repo.update(
      dspUid: widget.dspUid,
      confirmationId: c.id,
      weeks: newWeeks,
    );
  }

  Future<void> _delete(SesoConfirmation c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmation löschen?'),
        content: const Text('Alle Wochen-Einträge und Screenshots werden entfernt.'),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: 'Abbrechen',
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            label: 'Löschen',
            variant: CoButtonVariant.destructive,
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _repo.delete(dspUid: widget.dspUid, confirmationId: c.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _edit(SesoConfirmation c) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _SesoEditorDialog(
        dspUid: widget.dspUid,
        repo: _repo,
        existing: c,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SESO-Confirmation'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _stream(),
        builder: (context, snap) {
          final Widget content;
          if (snap.connectionState == ConnectionState.waiting) {
            content = const Center(
              key: ValueKey('seso-detail-loading'),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.codriverGreen,
                ),
              ),
            );
            return CoStateSwitcher(child: content);
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const CoStateSwitcher(
              child: Center(
                key: ValueKey('seso-detail-missing'),
                child: Text('Eintrag nicht gefunden.'),
              ),
            );
          }
          final c = SesoConfirmation.fromDoc(snap.data!);
          return CoStateSwitcher(
            child: Padding(
              key: const ValueKey('seso-detail-loaded'),
              padding: const EdgeInsets.all(24),
              child: ListView(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: c.vehicleType == SesoVehicleType.lwb
                            ? const Color(0xFF7B5BFF)
                            : AppColors.codriverGreen,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        c.vehicleType.label,
                        style: AppTypography.subheadline.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.transactionId.isEmpty
                                ? (c.orderId.isEmpty ? '—' : c.orderId)
                                : c.transactionId,
                            style: AppTypography.title3.copyWith(
                              color: AppColors.codriverGraphite,
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (c.orderId.isNotEmpty &&
                              c.transactionId.isNotEmpty)
                            Text(
                              'Auftrag: ${c.orderId}',
                              style: AppTypography.footnote.copyWith(
                                color: AppColors.labelSecondaryLight,
                              ),
                            ),
                          Text(
                            '€${c.dailyRate.toStringAsFixed(2)} / Tag',
                            style: AppTypography.footnote.copyWith(
                              color: AppColors.labelSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _edit(c),
                      icon: const Icon(Icons.edit_rounded),
                      tooltip: 'Bearbeiten',
                    ),
                    IconButton(
                      onPressed: () => _delete(c),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      tooltip: 'Löschen',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: [
                    _MetricChip(
                      label: 'Wochenpreis',
                      value: _euro(c.weeklyCost),
                    ),
                    _MetricChip(label: 'Total', value: _euro(c.totalCost)),
                    _MetricChip(
                      label: 'Bezahlt',
                      value: _euro(c.paidCost),
                      color: AppColors.success,
                    ),
                    _MetricChip(
                      label: 'Offen',
                      value: _euro(c.openCost),
                      color: c.openCost > 0
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ],
                ),
                if (c.note != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(c.note!),
                  ),
                ],
                if (c.confirmationScreenshotPath != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Confirmation',
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.codriverGraphite,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _StoragePreview(path: c.confirmationScreenshotPath!),
                ],
                const SizedBox(height: 18),
                Text(
                  'Wochen',
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverGraphite,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                ...c.weeks.map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _WeekRow(
                      week: w,
                      weeklyCost: c.weeklyCost,
                      onTogglePaid: () => _togglePaid(c, w),
                      onUpload: () => _uploadPaymentScreenshot(c, w),
                    ),
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  final SesoWeekEntry week;
  final double weeklyCost;
  final VoidCallback onTogglePaid;
  final VoidCallback onUpload;
  const _WeekRow({
    required this.week,
    required this.weeklyCost,
    required this.onTogglePaid,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'KW',
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  week.weekNumber.toString().padLeft(2, '0'),
                  style: AppTypography.title3.copyWith(
                    color: AppColors.codriverGraphite,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _euro(weeklyCost),
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverGraphite,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  week.paid
                      ? 'Bezahlt am ${week.paidAt != null ? _formatDate(week.paidAt!) : '—'}'
                      : 'Noch offen',
                  style: AppTypography.caption1.copyWith(
                    color: week.paid
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (week.paymentScreenshotPath != null) ...[
            _StorageThumb(path: week.paymentScreenshotPath!),
            const SizedBox(width: 8),
          ],
          IconButton(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: 'Zahlungs-Screenshot',
          ),
          Switch.adaptive(
            value: week.paid,
            onChanged: (_) => onTogglePaid(),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.${d.year}';

class _StorageThumb extends StatelessWidget {
  final String path;
  const _StorageThumb({required this.path});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: FirebaseStorage.instance.ref(path).getDownloadURL(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.codriverGreen,
                  ),
                ),
              ),
            ),
          );
        }
        final isPdf = path.toLowerCase().endsWith('.pdf');
        return CoPressable(
          onTap: () => _openFullscreen(context, snap.data!, isPdf),
          borderRadius: BorderRadius.circular(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isPdf
                ? Container(
                    width: 40,
                    height: 40,
                    color: AppColors.surfaceLight,
                    alignment: Alignment.center,
                    child: const Icon(Icons.picture_as_pdf_rounded),
                  )
                : Image.network(
                    snap.data!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
          ),
        );
      },
    );
  }
}

class _StoragePreview extends StatelessWidget {
  final String path;
  const _StoragePreview({required this.path});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: FirebaseStorage.instance.ref(path).getDownloadURL(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.codriverGreen,
                ),
              ),
            ),
          );
        }
        final isPdf = path.toLowerCase().endsWith('.pdf');
        if (isPdf) {
          return CoPressable(
            onTap: () => _openFullscreen(context, snap.data!, true),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.picture_as_pdf_rounded, size: 36),
              ),
            ),
          );
        }
        return CoPressable(
          onTap: () => _openFullscreen(context, snap.data!, false),
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(snap.data!, fit: BoxFit.contain),
          ),
        );
      },
    );
  }
}

Future<void> _openFullscreen(
  BuildContext context,
  String url,
  bool isPdf,
) async {
  await showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        child: isPdf
            ? Center(
                child: CoButton(
                  icon: Icons.open_in_new_rounded,
                  label: 'PDF im neuen Tab öffnen',
                  variant: CoButtonVariant.quiet,
                  onPressed: () {
                    // Web-only: opens in a new tab via window.open.
                    final ref = FirebaseStorage.instance.refFromURL(url);
                    ref.getDownloadURL().then((u) => null);
                  },
                ),
              )
            : InteractiveViewer(child: Image.network(url)),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
//  Editor helpers (file pick row, rental-company dialog)
// ════════════════════════════════════════════════════════════════════════════

class _FilePickRow extends StatelessWidget {
  final String label;
  final String? pickedName;
  final String existingPlaceholder;
  final VoidCallback? onPick;
  const _FilePickRow({
    required this.label,
    required this.pickedName,
    required this.existingPlaceholder,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CoButton(
          onPressed: onPick,
          icon: Icons.attach_file_rounded,
          label: label,
          variant: CoButtonVariant.secondaryOutlined,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            pickedName ?? existingPlaceholder,
            style: AppTypography.caption1.copyWith(
              color: AppColors.labelSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

Future<void> _showRentalCompaniesDialog({
  required BuildContext context,
  required SesoConfirmationRepository repo,
  required String dspUid,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _RentalCompaniesDialog(repo: repo, dspUid: dspUid),
  );
}

class _RentalCompaniesDialog extends StatelessWidget {
  final SesoConfirmationRepository repo;
  final String dspUid;
  const _RentalCompaniesDialog({required this.repo, required this.dspUid});

  Future<void> _openEditor(
    BuildContext context, [
    RentalCompany? existing,
  ]) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _RentalCompanyEditor(
        repo: repo,
        dspUid: dspUid,
        existing: existing,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    RentalCompany c,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mietfirma löschen?'),
        content: Text('"${c.name}" wirklich löschen?'),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: 'Abbrechen',
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            label: 'Löschen',
            variant: CoButtonVariant.destructive,
          ),
        ],
      ),
    );
    if (ok != true) return;
    await repo.deleteRentalCompany(dspUid: dspUid, id: c.id);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('Mietfirmen'),
          const Spacer(),
          IconButton(
            onPressed: () => _openEditor(context),
            tooltip: 'Hinzufügen',
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        height: 380,
        child: StreamBuilder<List<RentalCompany>>(
          stream: repo.watchRentalCompanies(dspUid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const CoStateSwitcher(
                child: Center(
                  key: ValueKey('rentals-loading'),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.codriverGreen,
                    ),
                  ),
                ),
              );
            }
            final items = snap.data ?? const <RentalCompany>[];
            if (items.isEmpty) {
              return const CoStateSwitcher(
                child: Center(
                  key: ValueKey('rentals-empty'),
                  child: Text('Noch keine Mietfirmen angelegt.'),
                ),
              );
            }
            return CoStateSwitcher(
              child: ListView.separated(
              key: const ValueKey('rentals-list'),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = items[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    c.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    c.address.isEmpty ? '—' : c.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _openEditor(context, c),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(context, c),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                );
              },
              ),
            );
          },
        ),
      ),
      actions: [
        CoButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Schliessen',
          variant: CoButtonVariant.quiet,
        ),
      ],
    );
  }
}

class _RentalCompanyEditor extends StatefulWidget {
  final SesoConfirmationRepository repo;
  final String dspUid;
  final RentalCompany? existing;
  const _RentalCompanyEditor({
    required this.repo,
    required this.dspUid,
    this.existing,
  });

  @override
  State<_RentalCompanyEditor> createState() => _RentalCompanyEditorState();
}

class _RentalCompanyEditorState extends State<_RentalCompanyEditor> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _note;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _name = TextEditingController(text: ex?.name ?? '');
    _address = TextEditingController(text: ex?.address ?? '');
    _phone = TextEditingController(text: ex?.phone ?? '');
    _email = TextEditingController(text: ex?.email ?? '');
    _note = TextEditingController(text: ex?.note ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _email.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final n = _name.text.trim();
    final a = _address.text.trim();
    if (n.isEmpty) {
      setState(() => _error = 'Name eingeben.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.existing == null) {
        await widget.repo.createRentalCompany(
          dspUid: widget.dspUid,
          name: n,
          address: a,
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          note: _note.text.trim(),
        );
      } else {
        await widget.repo.updateRentalCompany(
          dspUid: widget.dspUid,
          id: widget.existing!.id,
          name: n,
          address: a,
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          note: _note.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null
          ? 'Neue Mietfirma'
          : 'Mietfirma bearbeiten'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _address,
              decoration: const InputDecoration(
                labelText: 'Abhol-Adresse',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phone,
                    decoration: const InputDecoration(labelText: 'Telefon'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'E-Mail'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Notiz'),
              maxLines: 2,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
          ],
        ),
      ),
      actions: [
        CoButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          label: 'Abbrechen',
          variant: CoButtonVariant.quiet,
        ),
        CoButton(
          onPressed: _saving ? null : _save,
          label: 'Speichern',
          busy: _saving,
        ),
      ],
    );
  }
}
