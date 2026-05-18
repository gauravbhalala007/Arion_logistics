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
import '../widgets/pill_tab_bar.dart';

/// Standalone Cart page — accessible via the cart icon on the Inventory page.
///
/// Two tabs:
///   * **Cart**   — current open cart, submit order
///   * **Orders** — list of submitted orders (= goods receipts). Each order
///     has a "Goods receipt" button that opens the inspection dialog.
class AdminCartPage extends StatefulWidget {
  const AdminCartPage({super.key});

  @override
  State<AdminCartPage> createState() => _AdminCartPageState();
}

class _AdminCartPageState extends State<AdminCartPage>
    with SingleTickerProviderStateMixin {
  final InventoryRepository _repo = InventoryRepository();
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String? get _adminUid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final adminUid = _adminUid;
    final l = InvL10n.of(context);
    if (adminUid == null) {
      return const Scaffold(
        backgroundColor: InvTokens.pageBg,
        body: Center(child: Text('—')),
      );
    }
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: InvTokens.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border:
                    Border(bottom: BorderSide(color: InvTokens.border)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  if (canPop)
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: InvTokens.text,
                      tooltip: l.back,
                    )
                  else
                    const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.codriverDeep,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l.cartTitle,
                          style: AppTypography.title2.copyWith(
                            color: InvTokens.text,
                          ),
                        ),
                        Text(
                          '${l.inventory} · ${l.cart} / ${l.orders}',
                          style: AppTypography.footnote.copyWith(
                            color: InvTokens.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: PillTabBar(
                controller: _tabs,
                tabs: [l.cart, l.orders],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _CartTab(repo: _repo, adminUid: adminUid),
                  _OrdersTab(repo: _repo, adminUid: adminUid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconWithDot extends StatelessWidget {
  const _IconWithDot({
    required this.icon,
    required this.dot,
    required this.color,
  });

  final IconData icon;
  final int dot;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: color),
        if (dot > 0)
          Positioned(
            right: -8,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 1,
              ),
              constraints: const BoxConstraints(minWidth: 18),
              decoration: BoxDecoration(
                color: InvTokens.danger,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                dot > 99 ? '99+' : '$dot',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
//   CART TAB
// ──────────────────────────────────────────────────────────────────────

class _CartTab extends StatefulWidget {
  const _CartTab({required this.repo, required this.adminUid});

  final InventoryRepository repo;
  final String adminUid;

  @override
  State<_CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<_CartTab> {
  final TextEditingController _supplier = TextEditingController();
  final TextEditingController _ref = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _supplier.dispose();
    _ref.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit(List<CartLine> lines) async {
    final l = InvL10n.of(context);
    if (lines.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await widget.repo.createReceiptFromCart(
        adminUid: widget.adminUid,
        supplier: _supplier.text,
        reference: _ref.text,
        notes: _notes.text,
        cart: lines,
      );
      if (!mounted) return;
      _supplier.clear();
      _ref.clear();
      _notes.clear();
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.codriverDeep,
          content: Text(
            l.orderCreated,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.genericError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = InvL10n.of(context);
    return StreamBuilder<List<CartLine>>(
      stream: widget.repo.watchCart(adminUid: widget.adminUid),
      builder: (context, snap) {
        final lines = snap.data ?? const <CartLine>[];
        if (lines.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.codriverDeep,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.cartEmpty,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: InvTokens.muted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CoButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed('/inventory');
                    },
                    label: l.browseInventory,
                    icon: Icons.arrow_back_rounded,
                    variant: CoButtonVariant.secondaryOutlined,
                  ),
                ],
              ),
            ),
          );
        }
        final qty =
            lines.fold<int>(0, (acc, x) => acc + x.quantity);
        return LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 920;
            final listSection = Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.cartSummary(lines.length, qty),
                          style: AppTypography.subheadline.copyWith(
                            color: InvTokens.muted,
                          ),
                        ),
                      ),
                      CoButton(
                        onPressed: _submitting
                            ? null
                            : () => _confirmClear(context),
                        label: l.cartClear,
                        icon: Icons.delete_sweep_outlined,
                        variant: CoButtonVariant.destructiveQuiet,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    itemCount: lines.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 14,
                      color: InvTokens.border,
                    ),
                    itemBuilder: (ctx, i) => _CartRow(
                      l: l,
                      line: lines[i],
                      adminUid: widget.adminUid,
                      repo: widget.repo,
                    ),
                  ),
                ),
              ],
            );

            final orderForm = Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(color: InvTokens.border),
                  left: BorderSide(color: InvTokens.border),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08111827),
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _supplier,
                    decoration: invDecoration(l.supplierOptional),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _ref,
                    decoration: invDecoration(l.orderRefOptional),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notes,
                    maxLines: 2,
                    decoration: invDecoration(l.notesForReceiving),
                  ),
                  const SizedBox(height: 14),
                  CoButton(
                    onPressed: _submitting ? null : () => _submit(lines),
                    label: _submitting ? l.submittingOrder : l.submitOrder,
                    icon: Icons.send_outlined,
                    fullWidth: true,
                    busy: _submitting,
                  ),
                ],
              ),
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(flex: 3, child: listSection),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: orderForm,
                  ),
                ],
              );
            }
            return Column(
              children: [
                Expanded(child: listSection),
                orderForm,
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final l = InvL10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.cartClearTitle),
        content: Text(l.cartClearBody),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: l.cancel,
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            label: l.cartClear,
            variant: CoButtonVariant.destructiveQuiet,
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.repo.clearCart(adminUid: widget.adminUid);
    }
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({
    required this.l,
    required this.line,
    required this.adminUid,
    required this.repo,
  });

  final InvL10n l;
  final CartLine line;
  final String adminUid;
  final InventoryRepository repo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.green50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            line.category == InventoryCategory.clothing
                ? Icons.checkroom_outlined
                : line.category == InventoryCategory.workshop
                    ? Icons.build_outlined
                    : Icons.inventory_2_outlined,
            color: AppColors.codriverDeep,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.subheadline.copyWith(
                  color: InvTokens.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                [
                  _catLabel(l, line.category),
                  if (line.size.isNotEmpty) l.sizeLabel(line.size),
                ].join(' · '),
                style: AppTypography.caption1.copyWith(
                  color: InvTokens.muted,
                ),
              ),
            ],
          ),
        ),
        InvStepper(
          value: line.quantity,
          min: 1,
          onChanged: (v) => repo.updateCartQuantity(
            adminUid: adminUid,
            lineId: line.id,
            quantity: v,
          ),
        ),
        IconButton(
          onPressed: () => repo.removeFromCart(
            adminUid: adminUid,
            lineId: line.id,
          ),
          icon: const Icon(
            Icons.close_rounded,
            color: InvTokens.muted,
            size: 18,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
//   ORDERS TAB
// ──────────────────────────────────────────────────────────────────────

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({required this.repo, required this.adminUid});

  final InventoryRepository repo;
  final String adminUid;

  @override
  Widget build(BuildContext context) {
    final l = InvL10n.of(context);
    return StreamBuilder<List<GoodsReceipt>>(
      stream: repo.watchReceipts(adminUid: adminUid),
      builder: (context, snap) {
        final receipts = snap.data ?? const <GoodsReceipt>[];
        if (receipts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.codriverDeep,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Text(
                      l.noOrders,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: InvTokens.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          itemCount: receipts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) => _OrderCard(
            l: l,
            receipt: receipts[i],
            adminUid: adminUid,
            repo: repo,
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.l,
    required this.receipt,
    required this.adminUid,
    required this.repo,
  });

  final InvL10n l;
  final GoodsReceipt receipt;
  final String adminUid;
  final InventoryRepository repo;

  String _statusLabel() {
    switch (receipt.status) {
      case GoodsReceiptStatus.pending:
        return l.statusPending;
      case GoodsReceiptStatus.inReview:
        return l.statusInReview;
      case GoodsReceiptStatus.accepted:
        return l.statusAccepted;
      case GoodsReceiptStatus.rejected:
        return l.statusRejected;
    }
  }

  Color _statusColor() {
    switch (receipt.status) {
      case GoodsReceiptStatus.pending:
        return InvTokens.warning;
      case GoodsReceiptStatus.inReview:
        return InvTokens.info;
      case GoodsReceiptStatus.accepted:
        return AppColors.codriverDeep;
      case GoodsReceiptStatus.rejected:
        return InvTokens.danger;
    }
  }

  Color _statusBg() {
    switch (receipt.status) {
      case GoodsReceiptStatus.pending:
        return InvTokens.warningBg;
      case GoodsReceiptStatus.inReview:
        return InvTokens.infoBg;
      case GoodsReceiptStatus.accepted:
        return AppColors.green50;
      case GoodsReceiptStatus.rejected:
        return InvTokens.dangerBg;
    }
  }

  bool get _canReceive =>
      receipt.status == GoodsReceiptStatus.pending ||
      receipt.status == GoodsReceiptStatus.inReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: InvTokens.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A111827),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.codriverDeep,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      receipt.supplier.isEmpty
                          ? l.orderWithoutSupplier
                          : receipt.supplier,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headline.copyWith(
                        color: InvTokens.text,
                      ),
                    ),
                    Text(
                      l.orderMeta(
                        receipt.reference.isEmpty
                            ? null
                            : receipt.reference,
                        receipt.lines.length,
                        receipt.totalExpected,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.footnote.copyWith(
                        color: InvTokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusBg(),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(),
                  style: AppTypography.caption2.copyWith(
                    color: _statusColor(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: CoButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (ctx) => _ReceiptReviewDialog(
                  repo: repo,
                  adminUid: adminUid,
                  receipt: receipt,
                ),
              ),
              label: l.receiveGoods,
              icon: _canReceive
                  ? Icons.local_shipping_outlined
                  : Icons.visibility_outlined,
              variant: _canReceive
                  ? CoButtonVariant.primary
                  : CoButtonVariant.secondaryOutlined,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
//   RECEIPT REVIEW DIALOG  (per-order goods inspection)
// ──────────────────────────────────────────────────────────────────────

class _ReceiptReviewDialog extends StatefulWidget {
  const _ReceiptReviewDialog({
    required this.repo,
    required this.adminUid,
    required this.receipt,
  });

  final InventoryRepository repo;
  final String adminUid;
  final GoodsReceipt receipt;

  @override
  State<_ReceiptReviewDialog> createState() => _ReceiptReviewDialogState();
}

class _ReceiptReviewDialogState extends State<_ReceiptReviewDialog> {
  late List<GoodsReceiptLine> _lines;
  late final TextEditingController _notes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _lines = List<GoodsReceiptLine>.from(widget.receipt.lines);
    _notes = TextEditingController(text: widget.receipt.notes);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  bool get _alreadyFinalized =>
      widget.receipt.status == GoodsReceiptStatus.accepted ||
      widget.receipt.status == GoodsReceiptStatus.rejected;

  Future<void> _finalize(GoodsReceiptStatus status) async {
    final l = InvL10n.of(context);
    setState(() => _saving = true);
    try {
      final updated = GoodsReceipt(
        id: widget.receipt.id,
        supplier: widget.receipt.supplier,
        reference: widget.receipt.reference,
        status: status,
        lines: _lines,
        notes: _notes.text.trim(),
        createdAt: widget.receipt.createdAt,
        completedAt: widget.receipt.completedAt,
      );
      await widget.repo.finalizeReceipt(
        adminUid: widget.adminUid,
        receipt: updated,
        status: status,
        notes: _notes.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.genericError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = InvL10n.of(context);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.goodsReceipt,
                          style: AppTypography.title2.copyWith(
                            color: InvTokens.text,
                          ),
                        ),
                        Text(
                          widget.receipt.supplier.isEmpty
                              ? l.orderWithoutSupplier
                              : widget.receipt.supplier,
                          style: AppTypography.footnote.copyWith(
                            color: InvTokens.muted,
                          ),
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
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _lines.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 12,
                    color: InvTokens.border,
                  ),
                  itemBuilder: (ctx, i) {
                    final line = _lines[i];
                    return _ReceiptLineRow(
                      l: l,
                      line: line,
                      readOnly: _alreadyFinalized,
                      onChanged: (lLine) =>
                          setState(() => _lines[i] = lLine),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notes,
                maxLines: 2,
                enabled: !_alreadyFinalized,
                decoration: invDecoration(l.checkNote),
              ),
              const SizedBox(height: 14),
              if (!_alreadyFinalized)
                Row(
                  children: [
                    Expanded(
                      child: CoButton(
                        onPressed: _saving
                            ? null
                            : () => _finalize(GoodsReceiptStatus.rejected),
                        label: l.reject,
                        icon: Icons.error_outline,
                        variant: CoButtonVariant.destructiveOutlined,
                        fullWidth: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: CoButton(
                        onPressed: _saving
                            ? null
                            : () => _finalize(GoodsReceiptStatus.accepted),
                        label: _saving ? l.booking : l.acceptAndAddStock,
                        icon: Icons.check_rounded,
                        busy: _saving,
                        fullWidth: true,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: InvTokens.softSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.receipt.status == GoodsReceiptStatus.accepted
                        ? l.alreadyAccepted
                        : l.alreadyRejected,
                    style: AppTypography.footnote.copyWith(
                      color: InvTokens.muted,
                      fontWeight: FontWeight.w600,
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

class _ReceiptLineRow extends StatelessWidget {
  const _ReceiptLineRow({
    required this.l,
    required this.line,
    required this.readOnly,
    required this.onChanged,
  });

  final InvL10n l;
  final GoodsReceiptLine line;
  final bool readOnly;
  final ValueChanged<GoodsReceiptLine> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.subheadline.copyWith(
                  color: InvTokens.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                [
                  if (line.size.isNotEmpty) l.sizeLabel(line.size),
                  l.expectedQty(line.expectedQty, line.unit),
                ].join(' · '),
                style: AppTypography.caption1.copyWith(
                  color: InvTokens.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InvStepper(
          value: line.receivedQty,
          min: 0,
          max: 99999,
          onChanged: readOnly
              ? (_) {}
              : (v) => onChanged(line.copyWith(receivedQty: v)),
        ),
        const SizedBox(width: 6),
        InkResponse(
          onTap:
              readOnly ? null : () => onChanged(line.copyWith(ok: !line.ok)),
          radius: 22,
          child: Icon(
            line.ok ? Icons.check_circle_rounded : Icons.cancel_outlined,
            color: line.ok ? AppColors.codriverGreen : InvTokens.danger,
            size: 22,
          ),
        ),
      ],
    );
  }
}

String _catLabel(InvL10n l, InventoryCategory c) {
  switch (c) {
    case InventoryCategory.clothing:
      return l.catClothing;
    case InventoryCategory.workshop:
      return l.catWorkshop;
    case InventoryCategory.other:
      return l.catOther;
  }
}
