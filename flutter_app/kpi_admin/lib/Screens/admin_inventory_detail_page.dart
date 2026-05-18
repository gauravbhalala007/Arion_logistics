import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/inventory_item.dart';
import '../services/inventory_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/inventory_l10n.dart';
import '../widgets/admin_scope.dart';
import '../widgets/co_button.dart';
import '../widgets/inventory_shared.dart';

/// Standalone item detail page. Shows the full product photo,
/// per-size stock breakdown with `+` / `−` adjust buttons (each
/// confirmed before writing), and an order button that bundles
/// requested quantities per size into cart lines.
class AdminInventoryDetailPage extends StatelessWidget {
  const AdminInventoryDetailPage({super.key, required this.itemId});

  final String itemId;

  String? _adminUid(BuildContext context) {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final adminUid = _adminUid(context);
    if (adminUid == null) {
      return const Scaffold(
        backgroundColor: InvTokens.pageBg,
        body: Center(child: Text('—')),
      );
    }
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(adminUid)
        .collection('inventory')
        .doc(itemId);

    return Scaffold(
      backgroundColor: InvTokens.pageBg,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: ref.snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snap.hasData || !snap.data!.exists) {
              return _NotFound();
            }
            final item = InventoryItem.fromDoc(snap.data!);
            return _DetailBody(item: item, adminUid: adminUid);
          },
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Artikel nicht gefunden.',
          style: AppTypography.body.copyWith(color: InvTokens.muted),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.item, required this.adminUid});

  final InventoryItem item;
  final String adminUid;

  @override
  Widget build(BuildContext context) {
    final l = InvL10n.of(context);
    final repo = InventoryRepository();

    return Column(
      children: [
        const _Header(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= 960;
              if (wide) {
                // Desktop: hero + product info on the left, the
                // per-size stock list on the right.
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: SizedBox(
                          width: c.maxWidth * 0.42,
                          child: _ProductColumn(item: item, l: l),
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: _SizesColumn(
                          item: item,
                          repo: repo,
                          adminUid: adminUid,
                          l: l,
                        ),
                      ),
                    ],
                  ),
                );
              }
              // Mobile / narrow: product column first, sizes after.
              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                children: [
                  _ProductColumn(item: item, l: l),
                  const SizedBox(height: 24),
                  _SizesColumn(
                    item: item,
                    repo: repo,
                    adminUid: adminUid,
                    l: l,
                  ),
                ],
              );
            },
          ),
        ),
        _BottomActionBar(item: item, repo: repo, adminUid: adminUid),
      ],
    );
  }
}

/// Left column on desktop / top stack on mobile.
/// Hero photo → product name → short description → available badge.
class _ProductColumn extends StatelessWidget {
  const _ProductColumn({required this.item, required this.l});

  final InventoryItem item;
  final InvL10n l;

  @override
  Widget build(BuildContext context) {
    final total = _aggregateStock(item);
    final isOut = total <= 0;
    final lowAgg = item.lowStockThreshold > 0 &&
        total > 0 &&
        total <= item.lowStockThreshold;
    final badgeBg = isOut
        ? InvTokens.dangerBg
        : lowAgg
            ? InvTokens.warningBg
            : AppColors.green50;
    final badgeFg = isOut
        ? InvTokens.danger
        : lowAgg
            ? InvTokens.warning
            : AppColors.codriverDeep;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroCard(item: item),
        const SizedBox(height: 16),
        // Title
        Text(
          item.name.isEmpty ? '—' : item.name,
          style: AppTypography.title2.copyWith(
            color: InvTokens.text,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        // Short description directly under the title
        if (item.notes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            item.notes,
            style: AppTypography.body.copyWith(
              color: InvTokens.muted,
              height: 1.5,
            ),
          ),
        ],
        // Meta row: SKU + supplier as quiet chips
        if (item.sku.isNotEmpty || item.supplier.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (item.sku.isNotEmpty)
                _MetaChip(label: 'SKU ${item.sku}', accent: false),
              if (item.supplier.isNotEmpty)
                _MetaChip(label: item.supplier, accent: true),
            ],
          ),
        ],
        const SizedBox(height: 16),
        // Available quantity badge — bold, prominent
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOut
                    ? Icons.error_outline_rounded
                    : Icons.inventory_2_outlined,
                size: 18,
                color: badgeFg,
              ),
              const SizedBox(width: 8),
              Text(
                isOut ? 'Nicht verfügbar' : 'Verfügbar',
                style: AppTypography.caption1.copyWith(
                  color: badgeFg,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 1,
                height: 16,
                color: badgeFg.withValues(alpha: 0.25),
              ),
              const SizedBox(width: 10),
              Text(
                '$total ${item.unit}',
                style: AppTypography.subheadline.copyWith(
                  color: badgeFg,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Right column on desktop / bottom stack on mobile.
/// Per-size stock breakdown with adjust controls.
class _SizesColumn extends StatelessWidget {
  const _SizesColumn({
    required this.item,
    required this.repo,
    required this.adminUid,
    required this.l,
  });

  final InventoryItem item;
  final InventoryRepository repo;
  final String adminUid;
  final InvL10n l;

  @override
  Widget build(BuildContext context) {
    final hasSizes = item.sizeOptions.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: hasSizes ? 'Größen' : 'Bestand',
          trailing: hasSizes
              ? '${item.sizeOptions.length} Optionen'
              : null,
        ),
        const SizedBox(height: 12),
        _SizeStockGrid(item: item, repo: repo, adminUid: adminUid, l: l),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
//   HEADER
// ──────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: InvTokens.border)),
      ),
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
      child: Row(
        children: [
          if (canPop)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: InvTokens.text,
              tooltip: 'Zurück',
            )
          else
            const SizedBox(height: 48, width: 8),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final photo = item.photoBase64.isNotEmpty
        ? _safeDecode(item.photoBase64)
        : null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InvTokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: photo != null
            ? Image.memory(photo, fit: BoxFit.contain)
            : const Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppColors.codriverDeep,
                ),
              ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.accent});
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent ? AppColors.green50 : InvTokens.softSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent ? AppColors.codriverGreen : InvTokens.border,
          width: 0.6,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption1.copyWith(
          color: accent ? AppColors.codriverDeep : InvTokens.text,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final String? trailing;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppTypography.headline.copyWith(
            color: InvTokens.text,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: InvTokens.softSurface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: InvTokens.border),
            ),
            child: Text(
              trailing!,
              style: AppTypography.caption2.copyWith(
                color: InvTokens.muted,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 12),
            child: Divider(height: 1, color: InvTokens.border),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
//   PER-SIZE STOCK
// ──────────────────────────────────────────────────────────────────────

class _SizeStockGrid extends StatelessWidget {
  const _SizeStockGrid({
    required this.item,
    required this.repo,
    required this.adminUid,
    required this.l,
  });

  final InventoryItem item;
  final InventoryRepository repo;
  final String adminUid;
  final InvL10n l;

  @override
  Widget build(BuildContext context) {
    final sizes = item.sizeOptions;
    if (sizes.isEmpty) {
      // Items without variants: a single bucket using the aggregate.
      return _SizeRow(
        label: item.unit,
        count: item.stock,
        lowThreshold:
            item.lowStockThreshold > 0 ? item.lowStockThreshold : 5,
        onThresholdChanged: (v) async {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(adminUid)
              .collection('inventory')
              .doc(item.id)
              .update(<String, dynamic>{
            'lowStockThreshold': v,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        },
        onAdjust: (delta) => _confirmAndAdjust(
          context,
          delta: delta,
          currentCount: item.stock,
          itemName: item.name,
          apply: () => repo.adjustStock(
            adminUid: adminUid,
            itemId: item.id,
            delta: delta,
          ),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < sizes.length; i++) ...[
          if (i != 0) const SizedBox(height: 8),
          _SizeRow(
            label: sizes[i],
            count: item.stockBySize[sizes[i]] ?? 0,
            lowThreshold: item.lowStockBySize[sizes[i]] ?? 5,
            onThresholdChanged: (v) => repo.setLowStockForSize(
              adminUid: adminUid,
              itemId: item.id,
              size: sizes[i],
              threshold: v,
            ),
            onAdjust: (delta) => _confirmAndAdjust(
              context,
              delta: delta,
              currentCount: item.stockBySize[sizes[i]] ?? 0,
              itemName: '${item.name} · ${sizes[i]}',
              apply: () => repo.adjustStockForSize(
                adminUid: adminUid,
                itemId: item.id,
                size: sizes[i],
                delta: delta,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmAndAdjust(
    BuildContext context, {
    required int delta,
    required int currentCount,
    required String itemName,
    required Future<void> Function() apply,
  }) async {
    final isAdd = delta > 0;
    final after = currentCount + delta;
    if (after < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bestand kann nicht negativ werden.'),
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAdd ? 'Bestand erhöhen' : 'Bestand reduzieren'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(itemName, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Aktuell: $currentCount'),
            Text('Änderung: ${delta > 0 ? '+' : ''}$delta'),
            const Divider(height: 16),
            Text('Neu: $after',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: 'Abbrechen',
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            label: isAdd ? 'Erhöhen' : 'Reduzieren',
            variant: isAdd
                ? CoButtonVariant.primary
                : CoButtonVariant.destructive,
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await apply();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.genericError)),
      );
    }
  }
}

class _SizeRow extends StatefulWidget {
  const _SizeRow({
    required this.label,
    required this.count,
    required this.lowThreshold,
    required this.onThresholdChanged,
    required this.onAdjust,
  });

  final String label;
  final int count;
  final int lowThreshold;
  final ValueChanged<int> onThresholdChanged;
  final ValueChanged<int> onAdjust;

  @override
  State<_SizeRow> createState() => _SizeRowState();
}

class _SizeRowState extends State<_SizeRow> {
  int _qty = 1;
  late final TextEditingController _minCtrl;
  late FocusNode _minFocus;

  @override
  void initState() {
    super.initState();
    _minCtrl = TextEditingController(text: widget.lowThreshold.toString());
    _minFocus = FocusNode()..addListener(_commitOnFocusLoss);
  }

  @override
  void didUpdateWidget(covariant _SizeRow old) {
    super.didUpdateWidget(old);
    // Sync external updates only when the field is not being edited.
    if (!_minFocus.hasFocus && old.lowThreshold != widget.lowThreshold) {
      _minCtrl.text = widget.lowThreshold.toString();
    }
  }

  void _commitOnFocusLoss() {
    if (_minFocus.hasFocus) return;
    final parsed = int.tryParse(_minCtrl.text.trim());
    final clamped = (parsed ?? widget.lowThreshold).clamp(0, 9999);
    if (clamped != widget.lowThreshold) {
      widget.onThresholdChanged(clamped);
    }
    _minCtrl.text = clamped.toString();
  }

  @override
  void dispose() {
    _minFocus.removeListener(_commitOnFocusLoss);
    _minFocus.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final low = widget.lowThreshold > 0 &&
        widget.count > 0 &&
        widget.count <= widget.lowThreshold;
    final out = widget.count <= 0;
    final badgeBg = out
        ? InvTokens.dangerBg
        : low
            ? InvTokens.warningBg
            : AppColors.green50;
    final badgeFg = out
        ? InvTokens.danger
        : low
            ? InvTokens.warning
            : AppColors.codriverDeep;

    final summaryRow = Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            widget.label,
            style: AppTypography.subheadline.copyWith(
              color: InvTokens.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${widget.count}',
            style: AppTypography.subheadline.copyWith(
              color: badgeFg,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Min.',
          style: AppTypography.caption1.copyWith(
            color: InvTokens.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 60,
          height: 36,
          child: TextField(
            controller: _minCtrl,
            focusNode: _minFocus,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _minFocus.unfocus(),
            style: AppTypography.subheadline.copyWith(
              color: InvTokens.text,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: InvTokens.softSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: InvTokens.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: InvTokens.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: InvTokens.text,
                  width: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    // Full-width quantity control: a single bar that spans the row.
    // Layout: [−button] [stepper centered] [+button] — each side has
    // the same target size so the bar feels balanced edge to edge.
    final controlBar = Container(
      height: 44,
      decoration: BoxDecoration(
        color: InvTokens.softSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: InvTokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _WideAdjustButton(
              icon: Icons.remove_rounded,
              danger: true,
              onTap: () => widget.onAdjust(-_qty),
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: InvTokens.border,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InvStepper(
              value: _qty,
              min: 1,
              onChanged: (v) => setState(() => _qty = v),
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: InvTokens.border,
          ),
          Expanded(
            child: _WideAdjustButton(
              icon: Icons.add_rounded,
              danger: false,
              onTap: () => widget.onAdjust(_qty),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: InvTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          summaryRow,
          const SizedBox(height: 10),
          controlBar,
        ],
      ),
    );
  }
}

/// Flat full-width tap target inside the size adjustment bar. The
/// red `−` and green `+` halves share the same visual weight so the
/// row feels balanced edge-to-edge.
class _WideAdjustButton extends StatelessWidget {
  const _WideAdjustButton({
    required this.icon,
    required this.danger,
    required this.onTap,
  });

  final IconData icon;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = danger ? InvTokens.danger : AppColors.codriverGreen;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Center(
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
//   ORDER BUTTON  →  per-size quantity sheet  →  adds to cart
// ──────────────────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.item,
    required this.repo,
    required this.adminUid,
  });

  final InventoryItem item;
  final InventoryRepository repo;
  final String adminUid;

  @override
  Widget build(BuildContext context) {
    final l = InvL10n.of(context);
    final total = _aggregateStock(item);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: InvTokens.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: LayoutBuilder(
            builder: (context, c) {
              final stat = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gesamt-Bestand',
                    style: AppTypography.caption2.copyWith(
                      color: InvTokens.muted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$total ${item.unit}',
                    style: AppTypography.title3.copyWith(
                      color: InvTokens.text,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              );

              final orderBtn = CoButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _OrderSheet(
                    item: item,
                    repo: repo,
                    adminUid: adminUid,
                  ),
                ),
                label: l.cart,
                icon: Icons.add_shopping_cart_outlined,
                fullWidth: true,
              );

              // Narrow screens: stack — stat on top, full-width
              // primary action below. Wide: keep them side-by-side.
              if (c.maxWidth < 560) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    stat,
                    const SizedBox(height: 10),
                    orderBtn,
                  ],
                );
              }
              return Row(
                children: [
                  stat,
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 280,
                    ),
                    child: orderBtn,
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

class _OrderSheet extends StatefulWidget {
  const _OrderSheet({
    required this.item,
    required this.repo,
    required this.adminUid,
  });

  final InventoryItem item;
  final InventoryRepository repo;
  final String adminUid;

  @override
  State<_OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<_OrderSheet> {
  late Map<String, int> _qty;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _qty = <String, int>{
      for (final s in widget.item.sizeOptions) s: 0,
    };
  }

  int get _total => _qty.values.fold(0, (a, b) => a + b);

  Future<void> _addToCart() async {
    if (_total <= 0) return;
    setState(() => _adding = true);
    try {
      for (final entry in _qty.entries) {
        if (entry.value <= 0) continue;
        await widget.repo.addToCart(
          adminUid: widget.adminUid,
          line: CartLine(
            id: '',
            itemId: widget.item.id,
            name: widget.item.name,
            category: widget.item.category,
            quantity: entry.value,
            size: entry.key,
            unit: widget.item.unit,
            note: '',
            createdAt: null,
          ),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.codriverDeep,
          content: Text(
            '$_total Position(en) zum Warenkorb hinzugefügt.',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _adding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(InvL10n.of(context).genericError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxH = media.size.height * 0.9;
    final sizes = widget.item.sizeOptions;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: InvTokens.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Bestellen',
                          style: AppTypography.title3
                              .copyWith(color: InvTokens.text),
                        ),
                        Text(
                          widget.item.name,
                          style: AppTypography.footnote
                              .copyWith(color: InvTokens.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: InvTokens.muted,
                  ),
                ],
              ),
            ),
            Expanded(
              child: sizes.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: _OrderRow(
                        label: widget.item.unit,
                        qty: _qty[''] ?? 0,
                        onChanged: (v) => setState(() => _qty[''] = v),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: sizes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final s = sizes[i];
                        return _OrderRow(
                          label: s,
                          qty: _qty[s] ?? 0,
                          onChanged: (v) => setState(() => _qty[s] = v),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CoButton(
                onPressed: (_adding || _total <= 0) ? null : _addToCart,
                label: _total > 0
                    ? 'In den Warenkorb · $_total'
                    : 'Mengen festlegen',
                icon: Icons.add_shopping_cart_outlined,
                fullWidth: true,
                busy: _adding,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.label,
    required this.qty,
    required this.onChanged,
  });

  final String label;
  final int qty;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: InvTokens.softSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: InvTokens.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: AppTypography.subheadline.copyWith(
                color: InvTokens.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Spacer(),
          InvStepper(
            value: qty,
            min: 0,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
//   helpers
// ──────────────────────────────────────────────────────────────────────

int _aggregateStock(InventoryItem item) {
  if (item.stockBySize.isEmpty) return item.stock;
  return item.stockBySize.values.fold<int>(0, (a, b) => a + b);
}

dynamic _safeDecode(String b64) {
  try {
    return base64Decode(b64);
  } catch (_) {
    return null;
  }
}

