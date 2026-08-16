import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../data/inventory_seed.dart' show kInventorySeedVersion;
import '../utils/image_optimizer.dart';
import '../widgets/co_button.dart';
import '../widgets/pill_tab_bar.dart';

import '../models/inventory_item.dart';
import '../services/inventory_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/inventory_l10n.dart';
import '../widgets/admin_scope.dart';
import '../widgets/inventory_shared.dart';

class AdminInventoryPage extends StatefulWidget {
  const AdminInventoryPage({super.key});

  @override
  State<AdminInventoryPage> createState() => _AdminInventoryPageState();
}

class _AdminInventoryPageState extends State<AdminInventoryPage>
    with SingleTickerProviderStateMixin {
  final InventoryRepository _repo = InventoryRepository();
  late final TabController _tabs;
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  bool _autoSeedAttempted = false;

  String? get _adminUid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    // Auto-seed the standard catalog the very first time the page
    // opens for a given admin. Runs silently after the first frame
    // so the UI never blocks waiting on Firestore.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _autoSeedIfNeeded();
    });
  }

  /// Versioned auto-seed: when the local seed version bumps we upsert
  /// the canonical catalog by SKU, preserving each admin's curated
  /// stock counts. The version sentinel lives on the user doc so a
  /// dispatcher / admin pair sees the upgrade exactly once.
  Future<void> _autoSeedIfNeeded() async {
    if (_autoSeedAttempted) return;
    _autoSeedAttempted = true;
    final adminUid = _adminUid;
    if (adminUid == null) return;
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(adminUid);
      final snap = await userRef.get();
      final stored =
          (snap.data()?['inventorySeedVersion'] as num?)?.toInt() ?? 0;
      if (stored >= kInventorySeedVersion) return;
      await _repo.seedStandardCatalog(adminUid: adminUid);
      await userRef.set(
        <String, dynamic>{
          'inventorySeedVersion': kInventorySeedVersion,
          'inventorySeeded': true,
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      _autoSeedAttempted = false;
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
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
    final isNarrow = MediaQuery.of(context).size.width < 720;

    return Scaffold(
      backgroundColor: InvTokens.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              l: l,
              adminUid: adminUid,
              repo: _repo,
              searchCtrl: _searchCtrl,
              onSearchChanged: (v) => setState(() => _search = v),
              onOpenCart: () =>
                  Navigator.of(context).pushNamed('/cart'),
              onAdd: () => _openItemEditor(
                context,
                adminUid: adminUid,
                presetCategory: _presetCategoryForCurrentTab(),
              ),
              isNarrow: isNarrow,
            ),
            const SizedBox(height: 16),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  child: _PillTabBar(controller: _tabs, l: l),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<InventoryItem>>(
                stream: _repo.watchItems(adminUid: adminUid),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snap.data ?? const <InventoryItem>[];
                  final filtered = _applySearch(all);
                  return TabBarView(
                    controller: _tabs,
                    children: [
                      _ItemsGrid(
                        l: l,
                        items: filtered,
                        adminUid: adminUid,
                        repo: _repo,
                        onEdit: (item) => _openItemEditor(
                          context,
                          adminUid: adminUid,
                          existing: item,
                        ),
                        onAdd: () =>
                            _openItemEditor(context, adminUid: adminUid),
                      ),
                      _ItemsGrid(
                        l: l,
                        items: filtered
                            .where(
                              (i) => i.category == InventoryCategory.clothing,
                            )
                            .toList(),
                        adminUid: adminUid,
                        repo: _repo,
                        onEdit: (item) => _openItemEditor(
                          context,
                          adminUid: adminUid,
                          existing: item,
                        ),
                        onAdd: () => _openItemEditor(
                          context,
                          adminUid: adminUid,
                          presetCategory: InventoryCategory.clothing,
                        ),
                      ),
                      _ItemsGrid(
                        l: l,
                        items: filtered
                            .where(
                              (i) => i.category == InventoryCategory.workshop,
                            )
                            .toList(),
                        adminUid: adminUid,
                        repo: _repo,
                        onEdit: (item) => _openItemEditor(
                          context,
                          adminUid: adminUid,
                          existing: item,
                        ),
                        onAdd: () => _openItemEditor(
                          context,
                          adminUid: adminUid,
                          presetCategory: InventoryCategory.workshop,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  InventoryCategory _presetCategoryForCurrentTab() {
    switch (_tabs.index) {
      case 1:
        return InventoryCategory.clothing;
      case 2:
        return InventoryCategory.workshop;
      case 0:
      default:
        return InventoryCategory.other;
    }
  }

  List<InventoryItem> _applySearch(List<InventoryItem> items) {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((i) {
      return i.name.toLowerCase().contains(q) ||
          i.sku.toLowerCase().contains(q) ||
          i.supplier.toLowerCase().contains(q) ||
          i.category.label.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openItemEditor(
    BuildContext context, {
    required String adminUid,
    InventoryItem? existing,
    InventoryCategory? presetCategory,
  }) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _ItemEditorDialog(
        repo: _repo,
        adminUid: adminUid,
        existing: existing,
        presetCategory: presetCategory ?? InventoryCategory.other,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
//   HEADER  (title + search + new-item button + cart icon top-right)
// ──────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.l,
    required this.adminUid,
    required this.repo,
    required this.searchCtrl,
    required this.onSearchChanged,
    required this.onOpenCart,
    required this.onAdd,
    required this.isNarrow,
  });

  final InvL10n l;
  final String adminUid;
  final InventoryRepository repo;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenCart;
  final VoidCallback onAdd;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: InvTokens.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
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
                  Icons.inventory_2_outlined,
                  color: AppColors.codriverDeep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.inventory,
                      style: AppTypography.title2.copyWith(
                        color: InvTokens.text,
                      ),
                    ),
                    Text(
                      l.inventorySubtitle,
                      style: AppTypography.footnote.copyWith(
                        color: InvTokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // New-item action — full label on desktop, compact 44×44
              // square on narrow screens.
              LayoutBuilder(
                builder: (ctx, _) {
                  final compact = isNarrow ||
                      MediaQuery.of(ctx).size.width < 560;
                  if (compact) {
                    return CoIconButton(
                      onPressed: onAdd,
                      icon: Icons.add_rounded,
                      tooltip: l.newItem,
                      variant: CoIconButtonVariant.primary,
                    );
                  }
                  return CoButton(
                    onPressed: onAdd,
                    label: l.newItem,
                    icon: Icons.add_rounded,
                  );
                },
              ),
              const SizedBox(width: 8),
              StreamBuilder<List<CartLine>>(
                stream: repo.watchCart(adminUid: adminUid),
                builder: (context, snap) {
                  final n = (snap.data ?? const <CartLine>[]).length;
                  return CoIconButton(
                    onPressed: onOpenCart,
                    icon: Icons.shopping_cart_outlined,
                    tooltip: InvL10n.of(context).cart,
                    badge: n,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: TextField(
              controller: searchCtrl,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              style: AppTypography.body.copyWith(color: InvTokens.text),
              decoration: InputDecoration(
                hintText: l.searchPlaceholder,
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.labelHintLight,
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: InvTokens.softSurface,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: InvTokens.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: InvTokens.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.codriverGreen,
                    width: 1.4,
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

/// Wrapper that just forwards to the canonical [PillTabBar] — kept so
/// the existing call-sites in this file don't have to be touched.
class _PillTabBar extends StatelessWidget {
  const _PillTabBar({required this.controller, required this.l});

  final TabController controller;
  final InvL10n l;

  @override
  Widget build(BuildContext context) {
    return PillTabBar(
      controller: controller,
      tabs: [l.tabAll, l.tabClothing, l.tabWorkshop],
    );
  }
}


// ──────────────────────────────────────────────────────────────────────
//   GRID + CARDS
// ──────────────────────────────────────────────────────────────────────

class _ItemsGrid extends StatelessWidget {
  const _ItemsGrid({
    required this.l,
    required this.items,
    required this.adminUid,
    required this.repo,
    required this.onEdit,
    required this.onAdd,
  });

  final InvL10n l;
  final List<InventoryItem> items;
  final String adminUid;
  final InventoryRepository repo;
  final ValueChanged<InventoryItem> onEdit;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(l: l, onAdd: onAdd);
    }
    return LayoutBuilder(
      builder: (context, c) {
        // Responsive column count. Sized so each card never drops
        // below ~210 px wide — that's the sweet spot for a square
        // photo plus a one-line title + supplier strip without
        // cramming. The photo is 1:1 (BoxFit.cover); the info strip
        // below is ~84 px tall.
        int cols;
        if (c.maxWidth >= 1500) {
          cols = 6;
        } else if (c.maxWidth >= 1250) {
          cols = 5;
        } else if (c.maxWidth >= 1000) {
          cols = 4;
        } else if (c.maxWidth >= 380) {
          // Mobile defaults to a 3-column grid; only fall back to
          // 2 columns on extremely narrow widths.
          cols = 3;
        } else {
          cols = 2;
        }
        final cellWidth =
            (c.maxWidth - 40 - (cols - 1) * 12) / cols;
        final aspectRatio = cellWidth / (cellWidth + 84);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (ctx, i) => _ItemCard(
            l: l,
            item: items[i],
            adminUid: adminUid,
            repo: repo,
            onEdit: () => onEdit(items[i]),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.l,
    required this.onAdd,
  });

  final InvL10n l;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: InvTokens.border),
        ),
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
                Icons.inventory_2_outlined,
                color: AppColors.codriverDeep,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l.emptyTitle,
              style: AppTypography.title3.copyWith(color: InvTokens.text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              l.emptyBody,
              style: AppTypography.footnote.copyWith(color: InvTokens.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CoButton(
              onPressed: onAdd,
              label: l.emptyCta,
              icon: Icons.add_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatefulWidget {
  const _ItemCard({
    required this.l,
    required this.item,
    required this.adminUid,
    required this.repo,
    required this.onEdit,
  });

  final InvL10n l;
  final InventoryItem item;
  final String adminUid;
  final InventoryRepository repo;
  final VoidCallback onEdit;

  int get totalStock {
    if (item.stockBySize.isEmpty) return item.stock;
    return item.stockBySize.values.fold<int>(0, (a, b) => a + b);
  }

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> {
  /// Decoded photo bytes are cached here so we don't re-run
  /// base64Decode on every rebuild.
  Uint8List? _photoBytes;
  String _photoSource = '';

  /// True while a file is being dragged over the photo zone — used to
  /// draw a brand-coloured outline so the drop target is obvious.
  bool _dropHovering = false;

  /// True while we're resizing + uploading a freshly dropped image.
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _decodePhoto(widget.item.photoBase64);
  }

  @override
  void didUpdateWidget(covariant _ItemCard old) {
    super.didUpdateWidget(old);
    if (old.item.photoBase64 != widget.item.photoBase64) {
      _decodePhoto(widget.item.photoBase64);
    }
  }

  void _decodePhoto(String raw) {
    if (raw == _photoSource) return;
    _photoSource = raw;
    if (raw.isEmpty) {
      _photoBytes = null;
      return;
    }
    try {
      _photoBytes = base64Decode(raw);
    } catch (_) {
      _photoBytes = null;
    }
  }

  void _openDetail() {
    Navigator.of(context).pushNamed(
      '/inventory/item',
      arguments: widget.item.id,
    );
  }

  Future<void> _handleDrop(DropDoneDetails details) async {
    if (_uploadingPhoto) return;
    final de = Localizations.localeOf(context).languageCode == 'de';
    final files = details.files;
    if (files.isEmpty) return;
    final XFile file = files.first;
    final name = file.name.toLowerCase();
    final ok = name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif') ||
        name.endsWith('.bmp');
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(de
              ? 'Nur Bilddateien (JPG, PNG, WebP) sind erlaubt.'
              : 'Only image files (JPG, PNG, WebP) are allowed.'),
        ),
      );
      return;
    }
    setState(() {
      _uploadingPhoto = true;
      _dropHovering = false;
    });
    try {
      final raw = await file.readAsBytes();
      final optimized = await optimizeProductPhoto(raw);
      if (optimized == null) {
        throw StateError('decode_failed');
      }
      final b64 = base64Encode(optimized.bytes);
      await widget.repo.updatePhoto(
        adminUid: widget.adminUid,
        itemId: widget.item.id,
        photoBase64: b64,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.codriverDeep,
          duration: const Duration(seconds: 2),
          content: Text(
            de
                ? 'Bild aktualisiert · ${(optimized.bytes.length / 1024).toStringAsFixed(0)} KB'
                : 'Image updated · ${(optimized.bytes.length / 1024).toStringAsFixed(0)} KB',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(InvL10n.of(context).genericError)),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final item = widget.item;
    final total = widget.totalStock;
    final isOut = total <= 0;
    final isLow = !isOut &&
        item.lowStockThreshold > 0 &&
        total <= item.lowStockThreshold;
    final stockColor = isOut
        ? InvTokens.danger
        : isLow
            ? InvTokens.warning
            : AppColors.codriverDeep;
    final stockBg = isOut
        ? InvTokens.dangerBg
        : isLow
            ? InvTokens.warningBg
            : AppColors.green50;

    final photoBytes = _photoBytes;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openDetail,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: InvTokens.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A111827),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Square product photo with drag-and-drop hotspot —
              // drop a JPG/PNG anywhere on the image to replace it.
              // Images are auto-resized (max 600 px edge, JPEG q≈82,
              // target ≤ 100 KB) before they're written to Firestore.
              AspectRatio(
                aspectRatio: 1,
                child: DropTarget(
                  onDragEntered: (_) =>
                      setState(() => _dropHovering = true),
                  onDragExited: (_) =>
                      setState(() => _dropHovering = false),
                  onDragDone: _handleDrop,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (photoBytes != null)
                        Image.memory(
                          photoBytes,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                        )
                      else
                        Container(
                          color: AppColors.green50,
                          alignment: Alignment.center,
                          child: Icon(
                            item.category == InventoryCategory.clothing
                                ? Icons.checkroom_outlined
                                : item.category ==
                                        InventoryCategory.workshop
                                    ? Icons.build_outlined
                                    : Icons.inventory_2_outlined,
                            size: 48,
                            color: AppColors.codriverDeep,
                          ),
                        ),
                      // Drag-hover veil
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 140),
                        opacity: _dropHovering ? 1 : 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.codriverGreen
                                .withValues(alpha: 0.18),
                            border: Border.all(
                              color: AppColors.codriverGreen,
                              width: 3,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.file_upload_outlined,
                                  size: 18,
                                  color: AppColors.codriverDeep,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Hier ablegen',
                                  style:
                                      AppTypography.subheadline.copyWith(
                                    color: AppColors.codriverDeep,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Upload progress veil
                      if (_uploadingPhoto)
                        Container(
                          color: Colors.black.withValues(alpha: 0.32),
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: InvChip(
                          label: _localCategoryLabel(l, item.category),
                          bg: Colors.white,
                          fg: InvTokens.text,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: widget.onEdit,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: InvTokens.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name.isEmpty ? '—' : item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subheadline.copyWith(
                        color: InvTokens.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.supplier.isNotEmpty
                                ? item.supplier
                                : (item.sku.isNotEmpty
                                    ? 'SKU ${item.sku}'
                                    : '—'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption1.copyWith(
                              color: InvTokens.muted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: stockBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isOut ? l.empty : '$total',
                            style: AppTypography.caption2.copyWith(
                              color: stockColor,
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _localCategoryLabel(InvL10n l, InventoryCategory c) {
  switch (c) {
    case InventoryCategory.clothing:
      return l.catClothing;
    case InventoryCategory.workshop:
      return l.catWorkshop;
    case InventoryCategory.other:
      return l.catOther;
  }
}

// ──────────────────────────────────────────────────────────────────────
//   ITEM EDITOR DIALOG
// ──────────────────────────────────────────────────────────────────────

class _ItemEditorDialog extends StatefulWidget {
  const _ItemEditorDialog({
    required this.repo,
    required this.adminUid,
    required this.existing,
    required this.presetCategory,
  });

  final InventoryRepository repo;
  final String adminUid;
  final InventoryItem? existing;
  final InventoryCategory presetCategory;

  @override
  State<_ItemEditorDialog> createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<_ItemEditorDialog> {
  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _unit;
  late final TextEditingController _supplier;
  late final TextEditingController _stock;
  late final TextEditingController _low;
  late final TextEditingController _notes;
  late final TextEditingController _sizeInput;
  late InventoryCategory _category;
  late List<String> _sizes;
  String _photoBase64 = '';
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _sku = TextEditingController(text: e?.sku ?? '');
    _unit = TextEditingController(text: e?.unit ?? '');
    _supplier = TextEditingController(text: e?.supplier ?? '');
    _stock = TextEditingController(text: (e?.stock ?? 0).toString());
    _low = TextEditingController(text: (e?.lowStockThreshold ?? 0).toString());
    _notes = TextEditingController(text: e?.notes ?? '');
    _sizeInput = TextEditingController();
    _category = e?.category ?? widget.presetCategory;
    _sizes = List<String>.from(e?.sizeOptions ?? const <String>[]);
    _photoBase64 = e?.photoBase64 ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _unit.dispose();
    _supplier.dispose();
    _stock.dispose();
    _low.dispose();
    _notes.dispose();
    _sizeInput.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final l = InvL10n.of(context);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 900,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _photoBase64 = base64Encode(bytes));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l.imageError);
    }
  }

  Future<void> _save() async {
    final l = InvL10n.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l.nameRequiredError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final unit =
          _unit.text.trim().isEmpty ? l.unitDefault : _unit.text.trim();
      // Preserve any existing per-size stock breakdown; new size
      // options default to 0 so the editor never resets the count
      // accidentally.
      final priorBySize = widget.existing?.stockBySize ?? const <String, int>{};
      final mergedBySize = <String, int>{
        for (final s in _sizes) s: priorBySize[s] ?? 0,
      };
      final priorLow =
          widget.existing?.lowStockBySize ?? const <String, int>{};
      final defaultLow = int.tryParse(_low.text.trim()) ?? 5;
      final mergedLow = <String, int>{
        for (final s in _sizes) s: priorLow[s] ?? defaultLow,
      };
      final draft = InventoryItem(
        id: widget.existing?.id ?? '',
        name: name,
        category: _category,
        sku: _sku.text.trim(),
        unit: unit,
        stock: int.tryParse(_stock.text.trim()) ?? 0,
        lowStockThreshold: defaultLow,
        sizeOptions: _sizes,
        stockBySize: mergedBySize,
        lowStockBySize: mergedLow,
        supplier: _supplier.text.trim(),
        notes: _notes.text.trim(),
        photoBase64: _photoBase64,
        createdAt: null,
        updatedAt: null,
      );
      if (widget.existing == null) {
        await widget.repo.createItem(adminUid: widget.adminUid, item: draft);
      } else {
        await widget.repo.updateItem(adminUid: widget.adminUid, item: draft);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l.saveError;
      });
    }
  }

  Future<void> _delete() async {
    if (widget.existing == null) return;
    final l = InvL10n.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteTitle),
        content: Text(l.deleteBody(widget.existing!.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: InvTokens.danger),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _saving = true);
    try {
      await widget.repo.deleteItem(
        adminUid: widget.adminUid,
        itemId: widget.existing!.id,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l.deleteError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = InvL10n.of(context);
    Uint8List? bytes;
    if (_photoBase64.isNotEmpty) {
      try {
        bytes = base64Decode(_photoBase64);
      } catch (_) {}
    }

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
                    child: Text(
                      widget.existing == null
                          ? l.itemEditorTitleNew
                          : l.itemEditorTitleEdit,
                      style: AppTypography.title2.copyWith(
                        color: InvTokens.text,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: InvTokens.muted,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: AppColors.green50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: InvTokens.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: bytes != null
                                ? Image.memory(bytes, fit: BoxFit.cover)
                                : const Icon(
                                    Icons.image_outlined,
                                    size: 36,
                                    color: AppColors.codriverDeep,
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.photoLabel,
                                  style: AppTypography.subheadline.copyWith(
                                    color: InvTokens.text,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  l.photoHint,
                                  style: AppTypography.footnote.copyWith(
                                    color: InvTokens.muted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CoButton(
                                      onPressed: _pickPhoto,
                                      label: l.upload,
                                      icon: Icons.upload_outlined,
                                      variant:
                                          CoButtonVariant.secondaryOutlined,
                                    ),
                                    if (_photoBase64.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      CoButton(
                                        onPressed: () => setState(
                                          () => _photoBase64 = '',
                                        ),
                                        label: l.remove,
                                        variant:
                                            CoButtonVariant.destructiveQuiet,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      InvLabel(l.category),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: InventoryCategory.values
                            .map(
                              (c) => ChoiceChip(
                                label: Text(_localCategoryLabel(l, c)),
                                selected: c == _category,
                                onSelected: (_) =>
                                    setState(() => _category = c),
                                selectedColor: AppColors.codriverGreen,
                                labelStyle: AppTypography.subheadline.copyWith(
                                  color: c == _category
                                      ? Colors.white
                                      : InvTokens.text,
                                  fontWeight: FontWeight.w800,
                                ),
                                backgroundColor: InvTokens.softSurface,
                                side: BorderSide(
                                  color: c == _category
                                      ? AppColors.codriverGreen
                                      : InvTokens.border,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      InvField(
                        label: l.nameRequired,
                        controller: _name,
                        hint: l.nameHint,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InvField(
                              label: l.skuLabel,
                              controller: _sku,
                              hint: l.optional,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InvField(
                              label: l.unitLabel,
                              controller: _unit,
                              hint: l.unitHint,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InvField(
                              label: l.stockLabel,
                              controller: _stock,
                              hint: '0',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InvField(
                              label: l.lowThresholdLabel,
                              controller: _low,
                              hint: '5',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InvField(
                        label: l.supplierLabel,
                        controller: _supplier,
                        hint: l.optional,
                      ),
                      const SizedBox(height: 12),
                      InvLabel(l.sizesLabel),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _sizeInput,
                              onSubmitted: (v) => _commitSize(v),
                              decoration: invDecoration(l.sizesHint),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CoButton(
                            onPressed: () => _commitSize(_sizeInput.text),
                            label: l.add,
                            icon: Icons.add,
                            variant: CoButtonVariant.secondaryOutlined,
                          ),
                        ],
                      ),
                      if (_sizes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _sizes
                              .map(
                                (s) => InputChip(
                                  label: Text(s),
                                  onDeleted: () =>
                                      setState(() => _sizes.remove(s)),
                                  backgroundColor: InvTokens.softSurface,
                                  side: const BorderSide(
                                    color: InvTokens.border,
                                  ),
                                  labelStyle: AppTypography.caption1.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: InvTokens.text,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      InvField(
                        label: l.notes,
                        controller: _notes,
                        hint: l.optional,
                        maxLines: 3,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: InvTokens.dangerBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _error!,
                            style: AppTypography.footnote.copyWith(
                              color: InvTokens.danger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (widget.existing != null)
                    CoButton(
                      onPressed: _saving ? null : _delete,
                      label: l.delete,
                      icon: Icons.delete_outline,
                      variant: CoButtonVariant.destructiveQuiet,
                    ),
                  const Spacer(),
                  CoButton(
                    onPressed:
                        _saving ? null : () => Navigator.of(context).pop(),
                    label: l.cancel,
                    variant: CoButtonVariant.quiet,
                  ),
                  const SizedBox(width: 6),
                  CoButton(
                    onPressed: _saving ? null : _save,
                    label: widget.existing == null ? l.create : l.save,
                    busy: _saving,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _commitSize(String v) {
    final s = v.trim();
    if (s.isEmpty) return;
    setState(() {
      if (!_sizes.contains(s)) _sizes.add(s);
      _sizeInput.clear();
    });
  }
}
