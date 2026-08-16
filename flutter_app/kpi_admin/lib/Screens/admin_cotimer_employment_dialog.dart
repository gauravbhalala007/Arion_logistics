// lib/Screens/admin_cotimer_employment_dialog.dart
//
// Vertrags-Editor auf Unternehmens-Ebene als Vollbild-Unterseite (kein
// Popup mehr). Soll-Modus + Vertragsstunden + Arbeitstage + Bundesland
// gelten für ALLE Fahrer dieses DSP-Admins. Schreibt nach
// `users/{adminUid}.cotimerEmployment` — wird vom
// computeMonthlyAccount-Cron gelesen, um Soll-Werte zu berechnen.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class EmploymentEditDialog extends StatefulWidget {
  final String adminUid;

  const EmploymentEditDialog({
    super.key,
    required this.adminUid,
  });

  /// Pusht die Vertragseinstellungen als Vollbild-Unterseite auf den
  /// Navigation-Stack. Rückgabe-Bool zeigt ob etwas gespeichert wurde.
  static Future<bool?> show(
    BuildContext context, {
    required String adminUid,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EmploymentEditDialog(adminUid: adminUid),
      ),
    );
  }

  @override
  State<EmploymentEditDialog> createState() => _EmploymentEditDialogState();
}

enum _SollMode { fixedMonthly, workdayBased }

class _EmploymentEditDialogState extends State<EmploymentEditDialog> {
  late _SollMode _mode;
  late TextEditingController _monthlyCtrl;
  late TextEditingController _weeklyCtrl;
  late TextEditingController _dailyCtrl;
  late Set<String> _workingDays;
  late String _bundesland;
  bool _saving = false;
  String? _error;

  // ISO-Code → ausgeschriebener Name (kurz). Wird im Cupertino-Picker
  // verwendet, damit der Admin das richtige Bundesland mit einem
  // Wisch-Gestus setzen kann.
  static const _bundeslaender = <String, String>{
    'BW': 'Baden-Württemberg',
    'BY': 'Bayern',
    'BE': 'Berlin',
    'BB': 'Brandenburg',
    'HB': 'Bremen',
    'HH': 'Hamburg',
    'HE': 'Hessen',
    'MV': 'Meck.-Vorpomm.',
    'NI': 'Niedersachsen',
    'NW': 'Nordrhein-Westf.',
    'RP': 'Rheinland-Pfalz',
    'SL': 'Saarland',
    'SN': 'Sachsen',
    'ST': 'Sachsen-Anhalt',
    'SH': 'Schleswig-Holst.',
    'TH': 'Thüringen',
  };

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Defaults bis Firestore-Load fertig ist.
    _mode = _SollMode.workdayBased;
    _monthlyCtrl = TextEditingController(text: '173');
    _weeklyCtrl = TextEditingController(text: '40');
    _dailyCtrl = TextEditingController(text: '8');
    _workingDays = {'MO', 'TU', 'WE', 'TH', 'FR'};
    _bundesland = 'NW';
    _loadCompanySettings();
  }

  Future<void> _loadCompanySettings() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.adminUid)
          .get();
      final raw = snap.data()?['cotimerEmployment'];
      if (raw is Map) {
        final e = Map<String, dynamic>.from(raw);
        final modeRaw = (e['sollMode'] ?? 'workday_based').toString();
        _mode = modeRaw == 'fixed_monthly'
            ? _SollMode.fixedMonthly
            : _SollMode.workdayBased;
        _monthlyCtrl.text =
            (e['monthlyContractHours']?.toString() ?? '173');
        _weeklyCtrl.text = (e['weeklyContractHours']?.toString() ?? '40');
        _dailyCtrl.text = (e['dailyContractHours']?.toString() ?? '8');
        final wd = e['workingDays'];
        if (wd is List && wd.isNotEmpty) {
          _workingDays =
              wd.map((d) => d.toString().toUpperCase()).toSet();
        }
        _bundesland = (e['bundesland'] ?? 'NW').toString();
      }
    } catch (_) {
      // ignore - bleibt bei Defaults
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _monthlyCtrl.dispose();
    _weeklyCtrl.dispose();
    _dailyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final monthly = double.tryParse(_monthlyCtrl.text.replaceAll(',', '.'));
    final weekly = double.tryParse(_weeklyCtrl.text.replaceAll(',', '.'));
    final daily = double.tryParse(_dailyCtrl.text.replaceAll(',', '.'));
    if (_mode == _SollMode.fixedMonthly) {
      if (monthly == null || monthly <= 0 || monthly > 250) {
        setState(() => _error = de
            ? 'Monatsstunden: Wert zwischen 1 und 250'
            : 'Monthly hours: value between 1 and 250');
        return;
      }
    } else {
      if (weekly == null || weekly <= 0 || weekly > 60) {
        setState(() => _error = de
            ? 'Wochenstunden: Wert zwischen 1 und 60'
            : 'Weekly hours: value between 1 and 60');
        return;
      }
      if (daily == null || daily <= 0 || daily > 12) {
        setState(() => _error = de
            ? 'Tagesstunden: Wert zwischen 1 und 12'
            : 'Daily hours: value between 1 and 12');
        return;
      }
      if (_workingDays.isEmpty) {
        setState(() => _error = de
            ? 'Mindestens einen Arbeitstag wählen'
            : 'Select at least one working day');
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.adminUid)
          .set({
        'cotimerEmployment': {
          'sollMode': _mode == _SollMode.fixedMonthly
              ? 'fixed_monthly'
              : 'workday_based',
          'monthlyContractHours': monthly ?? 173,
          'weeklyContractHours': weekly ?? 40,
          'dailyContractHours': daily ?? 8,
          'workingDays': _workingDays.toList()..sort(),
          'bundesland': _bundesland,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        foregroundColor: AppColors.codriverDeep,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
        ),
        title: Text(
          de ? 'Arbeitsvertrag' : 'Employment contract',
          style: AppTypography.headline.copyWith(
              color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.codriverGreen,
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    de ? 'Speichern' : 'Save',
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.codriverGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    children: [
                      Text(
                        de
                            ? 'Gilt für alle Fahrer dieses Unternehmens.'
                            : 'Applies to all drivers of this company.',
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.labelSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: de ? 'Soll-Modus' : 'Target hours mode',
                        children: [
                          _ModeRow(
                            title: de ? 'Fest pro Monat' : 'Fixed per month',
                            subtitle: de
                                ? 'z.B. 173 h/Monat (DE-Standard Vollzeit)'
                                : 'e.g. 173 h/month (German full-time standard)',
                            selected: _mode == _SollMode.fixedMonthly,
                            onTap: () => setState(
                                () => _mode = _SollMode.fixedMonthly),
                          ),
                          const _SettingsDivider(),
                          _ModeRow(
                            title: de ? 'Berechnet' : 'Calculated',
                            subtitle: de
                                ? 'Arbeitstage × Tagesstunden – Feiertage'
                                : 'Working days × daily hours – public holidays',
                            selected: _mode == _SollMode.workdayBased,
                            onTap: () => setState(
                                () => _mode = _SollMode.workdayBased),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_mode == _SollMode.fixedMonthly)
                        _SettingsSection(
                          title: de ? 'Monatsstunden' : 'Monthly hours',
                          footer: de
                              ? 'DE-Standard Vollzeit ≈ 173 h/Monat.'
                              : 'German full-time standard ≈ 173 h/month.',
                          children: [
                            _NumberInputRow(
                              title:
                                  de ? 'Stunden pro Monat' : 'Hours per month',
                              controller: _monthlyCtrl,
                              suffix: 'h',
                            ),
                          ],
                        )
                      else
                        _SettingsSection(
                          title: de ? 'Vertragsstunden' : 'Contract hours',
                          children: [
                            _NumberInputRow(
                              title: de ? 'Pro Woche' : 'Per week',
                              controller: _weeklyCtrl,
                              suffix: 'h',
                            ),
                            const _SettingsDivider(),
                            _NumberInputRow(
                              title: de ? 'Pro Tag' : 'Per day',
                              controller: _dailyCtrl,
                              suffix: 'h',
                            ),
                          ],
                        ),
                      if (_mode == _SollMode.workdayBased) ...[
                        const SizedBox(height: 20),
                        _SettingsSection(
                          title: de ? 'Arbeitswoche' : 'Working week',
                          footer: de
                              ? 'Bestimmt welche Wochentage als Werktage '
                                  'zählen.'
                              : 'Defines which weekdays count as working '
                                  'days.',
                          children: [
                            _WeekPresetRow(
                              title: de
                                  ? '5 Tage (Mo–Fr)'
                                  : '5 days (Mon–Fri)',
                              days: const {
                                'MO', 'TU', 'WE', 'TH', 'FR',
                              },
                              currentDays: _workingDays,
                              onTap: () => setState(
                                () => _workingDays = {
                                  'MO', 'TU', 'WE', 'TH', 'FR',
                                },
                              ),
                            ),
                            const _SettingsDivider(),
                            _WeekPresetRow(
                              title: de
                                  ? '6 Tage (Mo–Sa)'
                                  : '6 days (Mon–Sat)',
                              days: const {
                                'MO', 'TU', 'WE', 'TH', 'FR', 'SA',
                              },
                              currentDays: _workingDays,
                              onTap: () => setState(
                                () => _workingDays = {
                                  'MO', 'TU', 'WE', 'TH', 'FR', 'SA',
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      _SettingsSection(
                        title: de ? 'Feiertage' : 'Public holidays',
                        footer: de
                            ? 'Tippe auf das Bundesland, um es zu ändern.'
                            : 'Tap the Bundesland (German federal state) to '
                                'change it.',
                        children: [
                          _PickerRow(
                            title: de ? 'Bundesland' : 'Bundesland (state)',
                            value: _bundeslandLabel(_bundesland),
                            onTap: _openBundeslandPicker,
                          ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _bundeslandLabel(String code) {
    final name = _bundeslaender[code];
    return name == null ? code : '$name ($code)';
  }

  Future<void> _openBundeslandPicker() async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final keys = _bundeslaender.keys.toList();
    final initialIndex =
        keys.indexOf(_bundesland).clamp(0, keys.length - 1);
    var tempIndex = initialIndex;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E5EA),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(de ? 'Abbrechen' : 'Cancel'),
                    ),
                    const Spacer(),
                    Text(
                      'Bundesland',
                      style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(
                            () => _bundesland = keys[tempIndex]);
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        de ? 'Fertig' : 'Done',
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.codriverGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 36,
                  scrollController: FixedExtentScrollController(
                      initialItem: initialIndex),
                  onSelectedItemChanged: (i) => tempIndex = i,
                  children: keys.map((k) {
                    return Center(
                      child: Text(
                        '${_bundeslaender[k]!} ($k)',
                        style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// iOS Settings Primitives (lokal in dieser Datei)
// ───────────────────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final String title;
  final String? footer;
  final List<Widget> children;
  const _SettingsSection({
    required this.title,
    required this.children,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              footer!,
              style: AppTypography.caption1.copyWith(
                color: AppColors.labelSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(left: 16),
        child:
            Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA)),
      );
}

class _ModeRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _ModeRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.labelSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                size: 22,
                color: AppColors.codriverGreen,
              ),
          ],
        ),
      ),
    );
  }
}

class _NumberInputRow extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String? suffix;
  const _NumberInputRow({
    required this.title,
    required this.controller,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 92,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              textAlign: TextAlign.end,
              style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                suffixText: suffix,
                suffixStyle: AppTypography.subheadline.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekPresetRow extends StatelessWidget {
  final String title;
  final Set<String> days;
  final Set<String> currentDays;
  final VoidCallback onTap;
  const _WeekPresetRow({
    required this.title,
    required this.days,
    required this.currentDays,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected =
        currentDays.length == days.length && currentDays.containsAll(days);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                size: 22,
                color: AppColors.codriverGreen,
              ),
          ],
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;
  const _PickerRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              title,
              style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

