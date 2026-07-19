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
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

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
    return Container(
      color: const Color(0xFFF3F6F7),
      child: StreamBuilder<List<SesoConfirmation>>(
        stream: _repo.watch(widget.dspUid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                      'SESO Fahrzeuge',
                      style: AppTypography.title2.copyWith(
                        color: AppColors.codriverGraphite,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _openCreateOrEditDialog(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Anlegen'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Confirmations für selbst beschaffte Fahrzeuge + Zahlungs-Tracking.',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.labelSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Offen',
                        value: _euro(totalOpen),
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Bezahlt',
                        value: _euro(totalPaid),
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: '# Unbezahlte Wochen',
                        value: '$openWeeks',
                        color: AppColors.codriverDeep,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: items.isEmpty
                      ? _EmptyState(onAdd: _openCreateOrEditDialog)
                      : ListView.separated(
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
    final c = confirmation;
    final typeColor = c.vehicleType == SesoVehicleType.lwb
        ? const Color(0xFF7B5BFF)
        : AppColors.codriverGreen;
    return InkWell(
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
                          'Auftrag: ${c.orderId}',
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
                      ? '€${c.dailyRate.toStringAsFixed(2)}/T · Off-Peak'
                      : '€${c.dailyRate.toStringAsFixed(2)}/T',
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
                          'KW ${w.weekNumber.toString().padLeft(2, '0')}',
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
                  label: 'Bezahlt',
                  value: _euro(c.paidCost),
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  label: 'Offen',
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
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
          const SizedBox(height: 14),
          Text(
            'Noch keine SESO-Confirmations.',
            style: AppTypography.subheadline.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Lege eine Confirmation an: Fahrzeugtyp, Tagespreis und KWs.',
            style: AppTypography.footnote.copyWith(
              color: AppColors.labelSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Confirmation anlegen'),
          ),
        ],
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
  late TextEditingController _noteCtrl;
  late TextEditingController _transactionIdCtrl;
  late TextEditingController _orderIdCtrl;
  late TextEditingController _pickupCountCtrl;
  late TextEditingController _returnCountCtrl;
  late int _year;
  late Set<int> _selectedWeeks;
  String? _rentalCompanyId;
  DateTime? _pickupDate;
  DateTime? _returnDate;
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
    _noteCtrl = TextEditingController(text: ex?.note ?? '');
    _transactionIdCtrl = TextEditingController(text: ex?.transactionId ?? '');
    _orderIdCtrl = TextEditingController(text: ex?.orderId ?? '');
    _pickupCountCtrl = TextEditingController(
      text: ex?.pickupVehicleCount?.toString() ?? '',
    );
    _returnCountCtrl = TextEditingController(
      text: ex?.returnVehicleCount?.toString() ?? '',
    );
    final now = DateTime.now();
    _year = ex?.weeks.isNotEmpty == true ? ex!.weeks.first.year : now.year;
    _selectedWeeks = {
      for (final w in ex?.weeks ?? const <SesoWeekEntry>[]) w.weekNumber,
    };
    _rentalCompanyId = ex?.rentalCompanyId;
    _pickupDate = ex?.pickupDate;
    _returnDate = ex?.returnDate;
  }

  @override
  void dispose() {
    _rateCtrl.dispose();
    _noteCtrl.dispose();
    _transactionIdCtrl.dispose();
    _orderIdCtrl.dispose();
    _pickupCountCtrl.dispose();
    _returnCountCtrl.dispose();
    super.dispose();
  }

  double get _rate => double.tryParse(_rateCtrl.text.replaceAll(',', '.')) ?? 0;

  void _applyStandardRate() {
    final rate =
        (_offPeak ? _offPeakRates[_type]! : _peakRates[_type]!);
    _rateCtrl.text = rate.toStringAsFixed(2);
  }

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

  Future<void> _pickDate(bool isPickup) async {
    final now = DateTime.now();
    final initial =
        (isPickup ? _pickupDate : _returnDate) ?? DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isPickup) {
        _pickupDate = picked;
      } else {
        _returnDate = picked;
      }
    });
  }

  Future<void> _save() async {
    final rate = _rate;
    final txId = _transactionIdCtrl.text.trim();
    final orderId = _orderIdCtrl.text.trim();
    if (txId.isEmpty && orderId.isEmpty) {
      setState(() => _error = 'Mindestens Transaktions-ID oder Auftrags-ID eingeben.');
      return;
    }
    if (rate <= 0) {
      setState(() => _error = 'Tagespreis muss > 0 sein.');
      return;
    }
    if (_selectedWeeks.isEmpty) {
      setState(() => _error = 'Mindestens eine KW auswählen.');
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

      final pickupCount = int.tryParse(_pickupCountCtrl.text.trim()) ?? 0;
      final returnCount = int.tryParse(_returnCountCtrl.text.trim()) ?? 0;

      String confirmationId;
      if (existing == null) {
        confirmationId = await widget.repo.create(
          dspUid: widget.dspUid,
          transactionId: txId,
          orderId: orderId,
          vehicleType: _type,
          dailyRate: rate,
          offPeak: _offPeak,
          weeks: newWeeks,
          note: _noteCtrl.text.trim(),
          rentalCompanyId: _rentalCompanyId,
          pickupDate: _pickupDate,
          pickupVehicleCount: pickupCount > 0 ? pickupCount : null,
          returnDate: _returnDate,
          returnVehicleCount: returnCount > 0 ? returnCount : null,
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
          offPeak: _offPeak,
          weeks: newWeeks,
          note: _noteCtrl.text.trim(),
          rentalCompanyId: _rentalCompanyId,
          clearRentalCompany: _rentalCompanyId == null,
          pickupDate: _pickupDate,
          clearPickupDate: _pickupDate == null,
          pickupVehicleCount: pickupCount > 0 ? pickupCount : null,
          returnDate: _returnDate,
          clearReturnDate: _returnDate == null,
          returnVehicleCount: returnCount > 0 ? returnCount : null,
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
    final isEdit = widget.existing != null;
    final weekCount = _selectedWeeks.length;
    final weeklyCost = sesoWeeklyCost(_rate);
    final totalCost = sesoTotalCost(_rate, weekCount);

    return AlertDialog(
      title: Text(isEdit ? 'Confirmation bearbeiten' : 'Neue Confirmation'),
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
                      decoration: const InputDecoration(
                        labelText: 'Transaktions-ID',
                        hintText: 'aus der E-Mail einfügen',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _orderIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Auftrags-ID',
                        hintText: 'aus der E-Mail einfügen',
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
                          decoration: const InputDecoration(
                            labelText: 'Mietfirma',
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('— keine —'),
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
                        tooltip: 'Mietfirmen verwalten',
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
              // Pickup + Return for the calendar.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Abholung',
                      date: _pickupDate,
                      onTap: () => _pickDate(true),
                      onClear: _pickupDate == null
                          ? null
                          : () => setState(() => _pickupDate = null),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _pickupCountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Anz.',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Abgabe',
                      date: _returnDate,
                      onTap: () => _pickDate(false),
                      onClear: _returnDate == null
                          ? null
                          : () => setState(() => _returnDate = null),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _returnCountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Anz.',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rateCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Tagespreis (€) — überschreibbar',
                  prefixText: '€ ',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Jahr:',
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
                      '$weekCount KWs',
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
                    Text(
                      'Wochenpreis: ${_euro(weeklyCost)}',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.codriverDeep,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Gesamt: ${_euro(totalCost)}  ($weekCount × ${_euro(weeklyCost)})',
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.codriverDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notiz (optional)',
                ),
              ),
              const SizedBox(height: 12),
              _FilePickRow(
                label: 'Confirmation (E-Mail/Screenshot)',
                pickedName: _confirmationFileName,
                existingPlaceholder:
                    widget.existing?.confirmationScreenshotPath != null
                        ? 'Bereits hochgeladen'
                        : 'Keine Datei ausgewählt',
                onPick: _saving ? null : _pickConfirmationFile,
              ),
              const SizedBox(height: 8),
              _FilePickRow(
                label: 'Bezahlte Rechnung',
                pickedName: _invoiceFileName,
                existingPlaceholder:
                    widget.existing?.invoiceScreenshotPath != null
                        ? 'Bereits hochgeladen'
                        : 'Keine Datei ausgewählt',
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
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Speichern'),
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Löschen'),
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
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Eintrag nicht gefunden.'));
          }
          final c = SesoConfirmation.fromDoc(snap.data!);
          return Padding(
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
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final isPdf = path.toLowerCase().endsWith('.pdf');
        return GestureDetector(
          onTap: () => _openFullscreen(context, snap.data!, isPdf),
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
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final isPdf = path.toLowerCase().endsWith('.pdf');
        if (isPdf) {
          return GestureDetector(
            onTap: () => _openFullscreen(context, snap.data!, true),
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
        return GestureDetector(
          onTap: () => _openFullscreen(context, snap.data!, false),
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
                child: TextButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('PDF im neuen Tab öffnen'),
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
//  Editor helpers (date picker field, file pick row, rental-company dialog)
// ════════════════════════════════════════════════════════════════════════════

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: onClear == null
              ? const Icon(Icons.event_rounded)
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
        ),
        child: Text(
          date == null
              ? '— Datum wählen —'
              : '${date!.day.toString().padLeft(2, '0')}.'
                  '${date!.month.toString().padLeft(2, '0')}.${date!.year}',
          style: AppTypography.subheadline.copyWith(
            color: date == null
                ? AppColors.labelTertiaryLight
                : AppColors.codriverGraphite,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

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
        OutlinedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.attach_file_rounded),
          label: Text(label),
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Löschen'),
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
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data ?? const <RentalCompany>[];
            if (items.isEmpty) {
              return const Center(
                child: Text('Noch keine Mietfirmen angelegt.'),
              );
            }
            return ListView.separated(
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
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Schliessen'),
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
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Speichern'),
        ),
      ],
    );
  }
}
