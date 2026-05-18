import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'co_pressable.dart';

/// Shift bracket for one dispatcher — start + end time as HH:MM strings.
class DispatcherShiftRange {
  String start;
  String end;
  DispatcherShiftRange({required this.start, required this.end});

  Map<String, String> toMap() => {'start': start, 'end': end};
  List<String> toList() => <String>[start, end];

  factory DispatcherShiftRange.fromList(List<String> v) {
    if (v.length < 2) return DispatcherShiftRange(start: '06:00', end: '14:30');
    return DispatcherShiftRange(start: v[0], end: v[1]);
  }
}

/// All valid HH:MM values in 30-minute steps (04:00 → 23:30). Used by
/// every shift-time dropdown across Waveplan and Shift Plan so the
/// time grid stays consistent.
final List<String> halfHourTimes = () {
  final out = <String>[];
  for (var h = 4; h <= 23; h++) {
    final hh = h.toString().padLeft(2, '0');
    out.add('$hh:00');
    out.add('$hh:30');
  }
  return List<String>.unmodifiable(out);
}();

/// Default shift bracket for the i-th selected dispatcher.
DispatcherShiftRange defaultShiftFor(int index) {
  switch (index) {
    case 0:
      return DispatcherShiftRange(start: '06:00', end: '14:30');
    case 1:
      return DispatcherShiftRange(start: '14:30', end: '22:00');
    default:
      return DispatcherShiftRange(start: '06:00', end: '14:30');
  }
}

/// Waveplan-style dispatcher bar. Each selected dispatcher appears as
/// a green pill with start/end HH:MM dropdowns; not-yet-selected names
/// appear as outline-style add chips. Capped at [maxSelectable].
///
/// The widget is fully controlled — caller owns the lists/maps and
/// applies state changes via the callbacks.
class DispatcherBar extends StatelessWidget {
  const DispatcherBar({
    super.key,
    required this.available,
    required this.selected,
    required this.shiftByDispatcher,
    required this.maxSelectable,
    required this.onAddDispatcher,
    required this.onRemoveDispatcher,
    required this.onShiftChanged,
    this.label = 'DISPATCHER',
    this.emptyLabel = 'No dispatchers configured yet.',
    this.compact = false,
    this.stacked = false,
  });

  final List<String> available;
  final List<String> selected;
  final Map<String, DispatcherShiftRange> shiftByDispatcher;
  final int maxSelectable;
  final ValueChanged<String> onAddDispatcher;
  final ValueChanged<String> onRemoveDispatcher;
  final void Function(String name, DispatcherShiftRange newRange)
      onShiftChanged;
  final String label;
  final String emptyLabel;
  final bool compact;

  /// When true the widget renders vertically with no outer frame and
  /// no name-pill icon — the "right column" variant used inside the
  /// shift-plan page. The default horizontal pill is used in Waveplan.
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final remaining =
        available.where((n) => !selected.contains(n)).toList();
    final canAddMore = selected.length < maxSelectable;

    if (stacked) return _buildStacked(remaining, canAddMore);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppElevation.level1,
        border: Border.all(
          color: AppColors.separatorLight.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          const Icon(
            Icons.headset_mic_rounded,
            size: 16,
            color: AppColors.codriverDeep,
          ),
          const SizedBox(width: 6),
          if (!compact) ...[
            Text(
              label,
              style: AppTypography.caption2.copyWith(
                color: AppColors.labelSecondaryLight,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: available.isEmpty
                ? Text(
                    emptyLabel,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.labelSecondaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final name in selected)
                        _DispatcherRow(
                          name: name,
                          range: shiftByDispatcher[name] ??
                              defaultShiftFor(selected.indexOf(name)),
                          onShiftChanged: (r) => onShiftChanged(name, r),
                          onRemove: () => onRemoveDispatcher(name),
                        ),
                      if (canAddMore && remaining.isNotEmpty)
                        for (final name in remaining)
                          _AddDispatcherChip(
                            name: name,
                            onTap: () => onAddDispatcher(name),
                          ),
                      if (!canAddMore)
                        Text(
                          'Max $maxSelectable',
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.labelTertiaryLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Vertical layout for narrow right-rail use-cases. No outer frame,
  /// each selected dispatcher on its own row with name + time picker
  /// stacked side-by-side. Add-chips render in a wrap below the list.
  Widget _buildStacked(List<String> remaining, bool canAddMore) {
    if (available.isEmpty) {
      return Text(
        emptyLabel,
        style: AppTypography.footnote.copyWith(
          color: AppColors.labelSecondaryLight,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < selected.length; i++) ...[
          _StackedDispatcherRow(
            name: selected[i],
            range: shiftByDispatcher[selected[i]] ??
                defaultShiftFor(i),
            onShiftChanged: (r) => onShiftChanged(selected[i], r),
            onRemove: () => onRemoveDispatcher(selected[i]),
          ),
          if (i < selected.length - 1) const SizedBox(height: 6),
        ],
        if (canAddMore && remaining.isNotEmpty) ...[
          if (selected.isNotEmpty) const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final name in remaining)
                _AddDispatcherChip(
                  name: name,
                  onTap: () => onAddDispatcher(name),
                ),
            ],
          ),
        ],
        if (!canAddMore) ...[
          const SizedBox(height: 8),
          Text(
            'Max $maxSelectable',
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelTertiaryLight,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class _AddDispatcherChip extends StatelessWidget {
  const _AddDispatcherChip({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CoPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.separatorLight.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 13,
                color: AppColors.codriverDeep,
              ),
              const SizedBox(width: 4),
              Text(
                name,
                style: AppTypography.footnote.copyWith(
                  color: AppColors.codriverGraphite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DispatcherRow extends StatelessWidget {
  const _DispatcherRow({
    required this.name,
    required this.range,
    required this.onShiftChanged,
    required this.onRemove,
  });

  final String name;
  final DispatcherShiftRange range;
  final ValueChanged<DispatcherShiftRange> onShiftChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: CoPressable(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 4, 5),
              decoration: BoxDecoration(
                color: AppColors.codriverGreen,
                borderRadius: BorderRadius.circular(999),
                boxShadow: AppElevation.level1,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    name,
                    style: AppTypography.footnote.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _TimeDropdown(
          value: range.start,
          onChanged: (v) => onShiftChanged(
            DispatcherShiftRange(start: v, end: range.end),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text('–'),
        ),
        _TimeDropdown(
          value: range.end,
          onChanged: (v) => onShiftChanged(
            DispatcherShiftRange(start: range.start, end: v),
          ),
        ),
      ],
    );
  }
}

class _TimeDropdown extends StatelessWidget {
  const _TimeDropdown({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final inList = halfHourTimes.contains(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: inList ? value : null,
          isDense: true,
          hint: Text(
            value,
            style: AppTypography.footnote.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            size: 18,
            color: AppColors.labelSecondaryLight,
          ),
          items: [
            for (final t in halfHourTimes)
              DropdownMenuItem(
                value: t,
                child: Text(
                  t,
                  style: AppTypography.footnote.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
          ],
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Borderless stacked-mode row: name text + remove X + time range.
/// No green pill, no check icon — minimal so it fits the narrow
/// right column of the shift plan.
class _StackedDispatcherRow extends StatelessWidget {
  const _StackedDispatcherRow({
    required this.name,
    required this.range,
    required this.onShiftChanged,
    required this.onRemove,
  });

  final String name;
  final DispatcherShiftRange range;
  final ValueChanged<DispatcherShiftRange> onShiftChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        _TimeDropdown(
          value: range.start,
          onChanged: (v) => onShiftChanged(
            DispatcherShiftRange(start: v, end: range.end),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text('–'),
        ),
        _TimeDropdown(
          value: range.end,
          onChanged: (v) => onShiftChanged(
            DispatcherShiftRange(start: range.start, end: v),
          ),
        ),
        InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(999),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.labelSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }
}
