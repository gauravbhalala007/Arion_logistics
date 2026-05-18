// lib/Screens/admin_styleguide_page.dart
//
// CoDriver styleguide — built from scratch. Block 1: every button
// variant the app uses (or should use). Each tile shows a live
// instance, its background, its foreground / text color and a
// one-line recommendation on when to reach for it.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/co_button.dart';

class AdminStyleguidePage extends StatefulWidget {
  const AdminStyleguidePage({super.key});

  // ─── design tokens kept local to keep the page self-contained ──
  static const Color _kPageBg = Color(0xFFF6F7F5);
  static const Color _kCardBg = Color(0xFFFFFFFF);
  static const Color _kBorder = Color(0xFFE5E7EB);
  static const Color _kText = Color(0xFF111827);
  static const Color _kMuted = Color(0xFF6B7280);
  static const Color _kDanger = Color(0xFFB91C1C);

  @override
  State<AdminStyleguidePage> createState() => _AdminStyleguidePageState();
}

class _AdminStyleguidePageState extends State<AdminStyleguidePage> {
  final ScrollController _scroll = ScrollController();
  final _farbenKey = GlobalKey();
  final _typoKey = GlobalKey();
  final _buttonsKey = GlobalKey();
  final _tabsKey = GlobalKey();
  final _inputsKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _jumpTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminStyleguidePage._kPageBg,
      body: SafeArea(
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
          children: [
            const _PageHeader(),
            const SizedBox(height: 20),
            _SectionNav(
              entries: [
                ('Farben', _farbenKey),
                ('Typografie', _typoKey),
                ('Buttons', _buttonsKey),
                ('TabBars', _tabsKey),
                ('Inputs', _inputsKey),
              ],
              onJump: _jumpTo,
            ),
            const SizedBox(height: 36),
            // ─── INPUTS (request: ganz oben) ───────────────────
            Padding(
              key: _inputsKey,
              padding: EdgeInsets.zero,
              child: const _SectionHeader(
                title: 'Inputs',
                subtitle:
                    'Eingabefelder mit transparentem Rahmen — '
                    'kein Resting-Border, Inset-Akzent bei Focus.',
              ),
            ),
            const SizedBox(height: 16),
            const _InputsBlock(),
            const SizedBox(height: 40),
            // ─── BUTTONS ───────────────────────────────────────
            Padding(
              key: _buttonsKey,
              padding: EdgeInsets.zero,
              child: const _SectionHeader(
                title: 'Buttons',
                subtitle:
                    'Regel: Buttons sind immer vollständig pill-shaped '
                    '(`StadiumBorder`). Touch-Target ≥ 44 px. Schrift w600, '
                    'Tap-Feedback via Ripple, bei Bedarf Spring-Scale '
                    '(0.97 → 1.0 in 80 ms).',
              ),
            ),
            const SizedBox(height: 16),
            const _ButtonsBlock(),
            const SizedBox(height: 40),
            // ─── TABBARS ───────────────────────────────────────
            Padding(
              key: _tabsKey,
              padding: EdgeInsets.zero,
              child: const _SectionHeader(
                title: 'TabBars',
                subtitle:
                    'Standard ist Pill · Glas (cotimer-Stil). '
                    'Andere Varianten nur in dokumentierten Ausnahmen.',
              ),
            ),
            const SizedBox(height: 16),
            const _TabBarsBlock(),
            const SizedBox(height: 40),
            // ─── FARBEN ────────────────────────────────────────
            Padding(
              key: _farbenKey,
              padding: EdgeInsets.zero,
              child: const _SectionHeader(
                title: 'Farben',
                subtitle:
                    'Brand-Palette und semantische Tokens. '
                    'Klick auf einen Hex-Wert kopiert ihn.',
              ),
            ),
            const SizedBox(height: 16),
            const _ColorsBlock(),
            const SizedBox(height: 40),
            // ─── TYPOGRAFIE ────────────────────────────────────
            Padding(
              key: _typoKey,
              padding: EdgeInsets.zero,
              child: const _SectionHeader(
                title: 'Typografie',
                subtitle:
                    'Inter-basierte Skala — Größe, Gewicht und '
                    'Line-Height pro Rolle.',
              ),
            ),
            const SizedBox(height: 16),
            const _TypographyBlock(),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  SECTION NAVIGATOR — pill chips at the top, horizontal scroll
// ──────────────────────────────────────────────────────────────────

class _SectionNav extends StatelessWidget {
  const _SectionNav({required this.entries, required this.onJump});

  final List<(String, GlobalKey)> entries;
  final ValueChanged<GlobalKey> onJump;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminStyleguidePage._kCardBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AdminStyleguidePage._kBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08111827),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              if (i != 0) const SizedBox(width: 6),
              _NavPill(
                label: entries[i].$1,
                onTap: () => onJump(entries[i].$2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF6F7F5),
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: AppTypography.subheadline.copyWith(
              color: AdminStyleguidePage._kText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  HEADER
// ──────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminStyleguidePage._kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminStyleguidePage._kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CoDriver Styleguide',
            style: AppTypography.title1.copyWith(
              color: AdminStyleguidePage._kText,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Lebendige Komponenten-Galerie. Jede Schaltfläche, jeder '
            'Tab, jede Eingabe wird hier dokumentiert mit Beispiel, '
            'Hintergrund und Schriftfarbe.',
            style: AppTypography.body.copyWith(
              color: AdminStyleguidePage._kMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppTypography.title2.copyWith(
                color: AdminStyleguidePage._kText,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 14),
                child: Divider(
                  height: 1,
                  color: AdminStyleguidePage._kBorder,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTypography.footnote.copyWith(
            color: AdminStyleguidePage._kMuted,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  BUTTONS BLOCK
// ──────────────────────────────────────────────────────────────────

class _ButtonsBlock extends StatelessWidget {
  const _ButtonsBlock();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        int cols;
        if (c.maxWidth >= 1200) {
          cols = 3;
        } else if (c.maxWidth >= 720) {
          cols = 2;
        } else {
          cols = 1;
        }
        return GridView.count(
          crossAxisCount: cols,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.55,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            // ─── PRIMARY ────────────────────────────────────────
            _ButtonSpec(
              name: 'Primary · Filled',
              role: 'Haupt-CTA pro Screen — Speichern, Bestellen, Anlegen.',
              bgHex: '#00B287',
              fgHex: '#FFFFFF',
              preview: _PreviewPrimaryFilled(),
            ),
            _ButtonSpec(
              name: 'Primary · Filled + Icon',
              role: 'Haupt-CTA mit visuellem Anker — Plus, Senden, Bestätigen.',
              bgHex: '#00B287',
              fgHex: '#FFFFFF',
              preview: _PreviewPrimaryFilledIcon(),
            ),
            _ButtonSpec(
              name: 'Primary · Square Icon (44×44)',
              role: 'Header-Action wenn nur ein `+` passt — Mobile.',
              bgHex: '#00B287',
              fgHex: '#FFFFFF',
              preview: _PreviewSquarePrimary(),
            ),

            // ─── SECONDARY ──────────────────────────────────────
            _ButtonSpec(
              name: 'Secondary · Outlined',
              role: 'Alternative neben Primary — gleichrangig, weniger Gewicht.',
              bgHex: '#FFFFFF',
              fgHex: '#111827',
              preview: _PreviewSecondaryOutlined(),
            ),
            _ButtonSpec(
              name: 'Secondary · Outlined + Icon',
              role: 'Sekundär mit Aktion-Symbol — Hochladen, Exportieren.',
              bgHex: '#FFFFFF',
              fgHex: '#111827',
              preview: _PreviewSecondaryOutlinedIcon(),
            ),
            _ButtonSpec(
              name: 'Secondary · Square Icon (44×44)',
              role: 'Quiet Header-Tool — Warenkorb, Import, Filter.',
              bgHex: '#FFFFFF',
              fgHex: '#111827',
              preview: _PreviewSquareSecondary(),
            ),

            // ─── QUIET / TERTIARY ───────────────────────────────
            _ButtonSpec(
              name: 'Quiet · Text',
              role: 'Untergeordnete Aktion — Abbrechen, Mehr anzeigen.',
              bgHex: 'transparent',
              fgHex: '#006047',
              preview: _PreviewQuietText(),
            ),
            _ButtonSpec(
              name: 'Quiet · Text + Icon',
              role: 'Tertiäre Aktion mit Hinweis — Zurück, Filter.',
              bgHex: 'transparent',
              fgHex: '#006047',
              preview: _PreviewQuietTextIcon(),
            ),

            // ─── DESTRUCTIVE ────────────────────────────────────
            _ButtonSpec(
              name: 'Destructive · Filled',
              role: 'Unwiderrufliche Aktion — Löschen-Bestätigung.',
              bgHex: '#B91C1C',
              fgHex: '#FFFFFF',
              preview: _PreviewDestructiveFilled(),
            ),
            _ButtonSpec(
              name: 'Destructive · Outlined',
              role: 'Vorschaltige Destruktiv-Wahl — Beanstanden, Verwerfen.',
              bgHex: '#FFFFFF',
              fgHex: '#B91C1C',
              preview: _PreviewDestructiveOutlined(),
            ),
            _ButtonSpec(
              name: 'Destructive · Quiet Text',
              role: 'Inline-Destruktiv im Editor — Löschen-Link.',
              bgHex: 'transparent',
              fgHex: '#B91C1C',
              preview: _PreviewDestructiveText(),
            ),

            // ─── ICON-ONLY ──────────────────────────────────────
            _ButtonSpec(
              name: 'Icon · Plain (48×48)',
              role: 'AppBar-Action, Back-Pfeil, Schließen.',
              bgHex: 'transparent',
              fgHex: '#111827',
              preview: _PreviewIconPlain(),
            ),
            _ButtonSpec(
              name: 'Icon · Circle Light (32×32)',
              role: 'Mini-Action auf Karte — Edit-Stift auf Photo.',
              bgHex: '#FFFFFF',
              fgHex: '#111827',
              preview: _PreviewIconCircleLight(),
            ),

            // ─── DISABLED STATE ─────────────────────────────────
            _ButtonSpec(
              name: 'Primary · Disabled',
              role: 'Ausgegrauter Zustand, z.B. Submit ohne Eingabe.',
              bgHex: '#E5E7EB',
              fgHex: '#9AA3AF',
              preview: _PreviewPrimaryDisabled(),
            ),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  SPEC TILE  — preview + name + colour swatches + role
// ──────────────────────────────────────────────────────────────────

class _ButtonSpec extends StatelessWidget {
  const _ButtonSpec({
    required this.name,
    required this.role,
    required this.bgHex,
    required this.fgHex,
    required this.preview,
  });

  final String name;
  final String role;
  final String bgHex;
  final String fgHex;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminStyleguidePage._kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminStyleguidePage._kBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08111827),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live preview surface
          Expanded(
            child: Container(
              color: const Color(0xFFF9FAFB),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: preview,
            ),
          ),
          const Divider(
            height: 1,
            color: AdminStyleguidePage._kBorder,
          ),
          // Meta strip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTypography.subheadline.copyWith(
                    color: AdminStyleguidePage._kText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption1.copyWith(
                    color: AdminStyleguidePage._kMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _ColorSwatch(label: 'BG', hex: bgHex),
                    _ColorSwatch(label: 'FG', hex: fgHex),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.label, required this.hex});

  final String label;
  final String hex;

  Color? _parse(String h) {
    if (h.toLowerCase() == 'transparent') return Colors.transparent;
    final clean = h.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    if (clean.length == 8) {
      return Color(int.parse(clean, radix: 16));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final color = _parse(hex);
    final isTransparent = hex.toLowerCase() == 'transparent';
    return Tooltip(
      message: 'Kopiere $hex',
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: hex));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text('$hex kopiert'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AdminStyleguidePage._kBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isTransparent ? Colors.white : color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AdminStyleguidePage._kBorder,
                    width: 0.5,
                  ),
                ),
                child: isTransparent
                    ? const Center(
                        child: Text(
                          '∅',
                          style: TextStyle(
                            fontSize: 10,
                            color: AdminStyleguidePage._kMuted,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.caption2.copyWith(
                  color: AdminStyleguidePage._kMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                hex,
                style: AppTypography.caption2.copyWith(
                  color: AdminStyleguidePage._kText,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  BUTTON PREVIEWS
// ──────────────────────────────────────────────────────────────────

class _PreviewPrimaryFilled extends StatelessWidget {
  const _PreviewPrimaryFilled();
  @override
  Widget build(BuildContext context) =>
      CoButton(onPressed: () {}, label: 'Bestellen');
}

class _PreviewPrimaryFilledIcon extends StatelessWidget {
  const _PreviewPrimaryFilledIcon();
  @override
  Widget build(BuildContext context) => CoButton(
        onPressed: () {},
        label: 'Neuer Artikel',
        icon: Icons.add_rounded,
      );
}

class _PreviewSquarePrimary extends StatelessWidget {
  const _PreviewSquarePrimary();
  @override
  Widget build(BuildContext context) => CoIconButton(
        onPressed: () {},
        icon: Icons.add_rounded,
        variant: CoIconButtonVariant.primary,
      );
}

class _PreviewSecondaryOutlined extends StatelessWidget {
  const _PreviewSecondaryOutlined();
  @override
  Widget build(BuildContext context) => CoButton(
        onPressed: () {},
        label: 'Abbrechen',
        variant: CoButtonVariant.secondaryOutlined,
      );
}

class _PreviewSecondaryOutlinedIcon extends StatelessWidget {
  const _PreviewSecondaryOutlinedIcon();
  @override
  Widget build(BuildContext context) => CoButton(
        onPressed: () {},
        label: 'Hochladen',
        icon: Icons.upload_outlined,
        variant: CoButtonVariant.secondaryOutlined,
      );
}

class _PreviewSquareSecondary extends StatelessWidget {
  const _PreviewSquareSecondary();
  @override
  Widget build(BuildContext context) => CoIconButton(
        onPressed: () {},
        icon: Icons.shopping_cart_outlined,
      );
}

class _PreviewQuietText extends StatelessWidget {
  const _PreviewQuietText();
  @override
  Widget build(BuildContext context) => CoButton(
        onPressed: () {},
        label: 'Mehr anzeigen',
        variant: CoButtonVariant.quiet,
      );
}

class _PreviewQuietTextIcon extends StatelessWidget {
  const _PreviewQuietTextIcon();
  @override
  Widget build(BuildContext context) => CoButton(
        onPressed: () {},
        label: 'Zurück',
        icon: Icons.arrow_back_rounded,
        variant: CoButtonVariant.quiet,
      );
}

class _PreviewDestructiveFilled extends StatelessWidget {
  const _PreviewDestructiveFilled();
  @override
  Widget build(BuildContext context) => CoButton(
        onPressed: () {},
        label: 'Löschen',
        variant: CoButtonVariant.destructive,
      );
}

class _PreviewDestructiveOutlined extends StatelessWidget {
  const _PreviewDestructiveOutlined();
  @override
  Widget build(BuildContext context) => CoButton(
        onPressed: () {},
        label: 'Beanstanden',
        variant: CoButtonVariant.destructiveOutlined,
      );
}

class _PreviewDestructiveText extends StatelessWidget {
  const _PreviewDestructiveText();
  @override
  Widget build(BuildContext context) => CoButton(
        onPressed: () {},
        label: 'Artikel löschen',
        icon: Icons.delete_outline,
        variant: CoButtonVariant.destructiveQuiet,
      );
}

class _PreviewIconPlain extends StatelessWidget {
  const _PreviewIconPlain();
  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: () {},
        icon: const Icon(Icons.arrow_back_rounded),
        color: AdminStyleguidePage._kText,
        tooltip: 'Zurück',
      );
}

class _PreviewIconCircleLight extends StatelessWidget {
  const _PreviewIconCircleLight();
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(color: AdminStyleguidePage._kBorder),
        ),
        child: InkWell(
          onTap: () {},
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              Icons.edit_outlined,
              size: 16,
              color: AdminStyleguidePage._kText,
            ),
          ),
        ),
      );
}

class _PreviewPrimaryDisabled extends StatelessWidget {
  const _PreviewPrimaryDisabled();
  @override
  Widget build(BuildContext context) =>
      const CoButton(onPressed: null, label: 'Bestellen');
}

// ──────────────────────────────────────────────────────────────────
//  COLORS BLOCK
// ──────────────────────────────────────────────────────────────────

class _ColorsBlock extends StatelessWidget {
  const _ColorsBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        _PaletteRow(
          title: 'Brand',
          subtitle: 'Primäre Markenfarbe in drei Tönen.',
          tiles: [
            _PaletteTile(
              name: 'codriverGreen',
              hex: '#00B287',
              role: 'Primary CTA',
              dark: false,
            ),
            _PaletteTile(
              name: 'codriverDeep',
              hex: '#006047',
              role: 'Active Brand · Quiet Text',
              dark: true,
            ),
            _PaletteTile(
              name: 'green50',
              hex: '#E6F8F2',
              role: 'Brand Tint Surface',
              dark: false,
            ),
          ],
        ),
        SizedBox(height: 12),
        _PaletteRow(
          title: 'Text & Surface',
          subtitle: 'Hierarchie aus Near-Black bis Hairline-Border.',
          tiles: [
            _PaletteTile(
              name: 'textPrimary',
              hex: '#111827',
              role: 'Haupttext',
              dark: true,
            ),
            _PaletteTile(
              name: 'textMuted',
              hex: '#6B7280',
              role: 'Sekundärtext',
              dark: true,
            ),
            _PaletteTile(
              name: 'textDisabled',
              hex: '#9AA3AF',
              role: 'Disabled · Placeholder',
              dark: false,
            ),
            _PaletteTile(
              name: 'pageBg',
              hex: '#F3F6F7',
              role: 'Seitenhintergrund',
              dark: false,
            ),
            _PaletteTile(
              name: 'softSurface',
              hex: '#F9FAFB',
              role: 'Inputs · Sub-Surfaces',
              dark: false,
            ),
            _PaletteTile(
              name: 'border',
              hex: '#E5E7EB',
              role: 'Hairline-Trennlinien',
              dark: false,
            ),
          ],
        ),
        SizedBox(height: 12),
        _PaletteRow(
          title: 'Status',
          subtitle: 'Funktionale Farben — immer mit Icon oder Text als Verstärkung.',
          tiles: [
            _PaletteTile(
              name: 'success',
              hex: '#00B287',
              role: 'In Bestand · OK',
              dark: false,
            ),
            _PaletteTile(
              name: 'warning',
              hex: '#D97706',
              role: 'Niedriger Bestand · Pending',
              dark: false,
            ),
            _PaletteTile(
              name: 'warningBg',
              hex: '#FEF3C7',
              role: 'Warning-Surface',
              dark: false,
            ),
            _PaletteTile(
              name: 'danger',
              hex: '#B91C1C',
              role: 'Destruktiv · Out of Stock',
              dark: true,
            ),
            _PaletteTile(
              name: 'dangerBg',
              hex: '#FEE2E2',
              role: 'Danger-Surface',
              dark: false,
            ),
            _PaletteTile(
              name: 'info',
              hex: '#1D4ED8',
              role: 'In Review · Mentee-Border',
              dark: true,
            ),
            _PaletteTile(
              name: 'infoBg',
              hex: '#DBEAFE',
              role: 'Info-Surface',
              dark: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({
    required this.title,
    required this.subtitle,
    required this.tiles,
  });

  final String title;
  final String subtitle;
  final List<_PaletteTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminStyleguidePage._kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminStyleguidePage._kBorder),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headline.copyWith(
              color: AdminStyleguidePage._kText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption1.copyWith(
              color: AdminStyleguidePage._kMuted,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(spacing: 12, runSpacing: 12, children: tiles),
        ],
      ),
    );
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({
    required this.name,
    required this.hex,
    required this.role,
    required this.dark,
  });

  final String name;
  final String hex;
  final String role;
  final bool dark;

  Color _parse() {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parse();
    final fg = dark ? Colors.white : AdminStyleguidePage._kText;
    return SizedBox(
      width: 200,
      child: Tooltip(
        message: 'Kopiere $hex',
        child: InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: hex));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 2),
                content: Text('$hex kopiert'),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AdminStyleguidePage._kBorder,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            height: 92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: AppTypography.subheadline.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      role,
                      style: AppTypography.caption2.copyWith(
                        color: fg.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hex,
                      style: AppTypography.caption2.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  TYPOGRAPHY BLOCK
// ──────────────────────────────────────────────────────────────────

class _TypographyBlock extends StatelessWidget {
  const _TypographyBlock();

  @override
  Widget build(BuildContext context) {
    final rows = <_TypeRow>[
      _TypeRow(
          name: 'largeTitle',
          style: AppTypography.largeTitle,
          meta: '34 · w700 · −0.7'),
      _TypeRow(
          name: 'title1',
          style: AppTypography.title1,
          meta: '28 · w700 · −0.5'),
      _TypeRow(
          name: 'title2',
          style: AppTypography.title2,
          meta: '22 · w700 · −0.3'),
      _TypeRow(
          name: 'title3',
          style: AppTypography.title3,
          meta: '20 · w700 · −0.2'),
      _TypeRow(
          name: 'headline',
          style: AppTypography.headline,
          meta: '17 · w600 · −0.15'),
      _TypeRow(
          name: 'body',
          style: AppTypography.body,
          meta: '15 · w400 · −0.1'),
      _TypeRow(
          name: 'callout',
          style: AppTypography.callout,
          meta: '14 · w400'),
      _TypeRow(
          name: 'subheadline',
          style: AppTypography.subheadline,
          meta: '14 · w500'),
      _TypeRow(
          name: 'footnote',
          style: AppTypography.footnote,
          meta: '13 · w400'),
      _TypeRow(
          name: 'caption1',
          style: AppTypography.caption1,
          meta: '12 · w500 · +0.05'),
      _TypeRow(
          name: 'caption2',
          style: AppTypography.caption2,
          meta: '11 · w600 · +0.15'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AdminStyleguidePage._kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminStyleguidePage._kBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i != 0)
              const Divider(height: 1, color: AdminStyleguidePage._kBorder),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: rows[i],
            ),
          ],
        ],
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({
    required this.name,
    required this.style,
    required this.meta,
  });

  final String name;
  final TextStyle style;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: AppTypography.caption1.copyWith(
                  color: AdminStyleguidePage._kText,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                meta,
                style: AppTypography.caption2.copyWith(
                  color: AdminStyleguidePage._kMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            'The quick brown fox jumps · 1,234.56',
            style: style.copyWith(color: AdminStyleguidePage._kText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  TABBARS BLOCK
// ──────────────────────────────────────────────────────────────────

class _TabBarsBlock extends StatelessWidget {
  const _TabBarsBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        _TabBarSpec(
          name: 'Pill · Neutral · Standard',
          role: 'Der gesetzte Standard. Trough hellgrau (`#EEF1F4`), '
              'aktive weiße Pill mit Hairline-Border + sanftem Schatten. '
              'Aktiver Text Near-Black, inaktiv mittelgrau — kein Grün, '
              'keine GPU-teure Blur.',
          bgHex: '#EEF1F4',
          fgHex: '#111827',
          preview: _PreviewPillNeutral(),
        ),
        SizedBox(height: 12),
        _TabBarSpec(
          name: 'Pill · Glas · Legacy',
          role: 'BackdropFilter-Variante (cotimer-Original). Nicht mehr '
              'verwenden — der Glas-Effekt ist auf Flutter Web teuer und '
              'wird global durch das Neutral-Pendant ersetzt.',
          bgHex: '#FFFFFF · 72%',
          fgHex: '#000000',
          preview: _PreviewPillGlass(),
        ),
        SizedBox(height: 12),
        _TabBarSpec(
          name: 'Underline · Brand · Legacy',
          role: 'Klassischer Indicator-Stil. Nur noch für Bestandscode, '
              'neu nicht mehr verwenden — Pill · Neutral ist überall die '
              'Lösung.',
          bgHex: '#F3F6F7',
          fgHex: '#00B287',
          preview: _PreviewUnderlineBrand(),
        ),
      ],
    );
  }
}

class _TabBarSpec extends StatelessWidget {
  const _TabBarSpec({
    required this.name,
    required this.role,
    required this.bgHex,
    required this.fgHex,
    required this.preview,
  });

  final String name;
  final String role;
  final String bgHex;
  final String fgHex;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminStyleguidePage._kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminStyleguidePage._kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFFF9FAFB),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Center(child: preview),
          ),
          const Divider(
            height: 1,
            color: AdminStyleguidePage._kBorder,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTypography.subheadline.copyWith(
                    color: AdminStyleguidePage._kText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: AppTypography.caption1.copyWith(
                    color: AdminStyleguidePage._kMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _ColorSwatch(label: 'BG', hex: bgHex),
                    _ColorSwatch(label: 'FG aktiv', hex: fgHex),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPillNeutral extends StatefulWidget {
  const _PreviewPillNeutral();
  @override
  State<_PreviewPillNeutral> createState() => _PreviewPillNeutralState();
}

class _PreviewPillNeutralState extends State<_PreviewPillNeutral>
    with SingleTickerProviderStateMixin {
  late final TabController _t = TabController(length: 3, vsync: this);
  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF1F4),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE0E4EA), width: 0.6),
        ),
        child: TabBar(
          controller: _t,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE0E4EA),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AdminStyleguidePage._kText,
          unselectedLabelColor: const Color(0xFF9AA3AF),
          labelStyle:
              AppTypography.footnote.copyWith(fontWeight: FontWeight.w800),
          unselectedLabelStyle:
              AppTypography.footnote.copyWith(fontWeight: FontWeight.w600),
          labelPadding: EdgeInsets.zero,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: const [
            Tab(height: 38, text: 'Alles'),
            Tab(height: 38, text: 'Kleidung'),
            Tab(height: 38, text: 'Werkstatt'),
          ],
        ),
      ),
    );
  }
}

class _PreviewPillGlass extends StatefulWidget {
  const _PreviewPillGlass();
  @override
  State<_PreviewPillGlass> createState() => _PreviewPillGlassState();
}

class _PreviewPillGlassState extends State<_PreviewPillGlass>
    with SingleTickerProviderStateMixin {
  late final TabController _t = TabController(length: 4, vsync: this);
  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 0.6,
              ),
            ),
            child: TabBar(
              controller: _t,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: const Color(0xFF6B7280),
              labelStyle: AppTypography.footnote
                  .copyWith(fontWeight: FontWeight.w800),
              unselectedLabelStyle: AppTypography.footnote
                  .copyWith(fontWeight: FontWeight.w700),
              labelPadding: EdgeInsets.zero,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: const [
                Tab(height: 38, text: 'Live'),
                Tab(height: 38, text: 'Zeitkonto'),
                Tab(height: 38, text: 'Korrekturen'),
                Tab(height: 38, text: 'Compliance'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewUnderlineBrand extends StatefulWidget {
  const _PreviewUnderlineBrand();
  @override
  State<_PreviewUnderlineBrand> createState() =>
      _PreviewUnderlineBrandState();
}

class _PreviewUnderlineBrandState extends State<_PreviewUnderlineBrand>
    with SingleTickerProviderStateMixin {
  late final TabController _t = TabController(length: 3, vsync: this);
  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Material(
        color: const Color(0xFFF3F6F7),
        child: TabBar(
          controller: _t,
          indicatorColor: AppColors.codriverGreen,
          indicatorWeight: 3,
          labelColor: AppColors.codriverGraphite,
          unselectedLabelColor: const Color(0x993C3C43),
          labelStyle: AppTypography.subheadline
              .copyWith(fontWeight: FontWeight.w800),
          unselectedLabelStyle: AppTypography.subheadline,
          tabs: const [
            Tab(text: 'Urlaub'),
            Tab(text: 'Zeitkonto'),
            Tab(text: 'Krankmeldungen'),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  INPUTS BLOCK
// ──────────────────────────────────────────────────────────────────

/// Apple-styled inputs: no resting border (transparent), inset focus
/// ring in brand-green. The field still has a soft fill so it reads
/// as an interactive surface without competing with the page chrome.
InputDecoration _styleguideInputDecoration({
  required String hint,
  String? label,
  Widget? prefixIcon,
  Widget? suffix,
  bool error = false,
  bool enabled = true,
}) {
  const transparent = BorderSide(color: Colors.transparent);
  return InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: AppTypography.body.copyWith(
      color: AppColors.labelHintLight,
    ),
    labelStyle: AppTypography.footnote.copyWith(
      color: AdminStyleguidePage._kMuted,
      fontWeight: FontWeight.w600,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    prefixIcon: prefixIcon,
    suffixIcon: suffix,
    filled: true,
    fillColor: enabled
        ? const Color(0xFFF9FAFB)
        : const Color(0xFFF3F4F6),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 14,
    ),
    // Transparent rest-border drawn *inside* the field so focus does
    // not change the field's external dimensions.
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: transparent,
      gapPadding: 0,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: error
          ? const BorderSide(color: AdminStyleguidePage._kDanger, width: 1.2)
          : transparent,
    ),
    disabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: transparent,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(
        color: error
            ? AdminStyleguidePage._kDanger
            : AppColors.codriverGreen,
        width: 1.6,
      ),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(
        color: AdminStyleguidePage._kDanger,
        width: 1.2,
      ),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(
        color: AdminStyleguidePage._kDanger,
        width: 1.6,
      ),
    ),
    errorStyle: AppTypography.caption2.copyWith(
      color: AdminStyleguidePage._kDanger,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _InputsBlock extends StatelessWidget {
  const _InputsBlock();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        int cols;
        if (c.maxWidth >= 1200) {
          cols = 3;
        } else if (c.maxWidth >= 720) {
          cols = 2;
        } else {
          cols = 1;
        }
        return GridView.count(
          crossAxisCount: cols,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.55,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _InputSpec(
              name: 'Text · Default',
              role: 'Standard-Eingabe — Name, Notiz, kurze Werte.',
              bgHex: '#F9FAFB',
              fgHex: '#111827',
              preview: _PreviewInputDefault(),
            ),
            _InputSpec(
              name: 'Text · Mit Label',
              role: 'Eingabe mit dauerhaft sichtbarem Label oben.',
              bgHex: '#F9FAFB',
              fgHex: '#111827',
              preview: _PreviewInputLabeled(),
            ),
            _InputSpec(
              name: 'Search',
              role: 'Suchfeld mit Lupen-Präfix — Pill-Shape.',
              bgHex: '#F9FAFB',
              fgHex: '#111827',
              preview: _PreviewInputSearch(),
            ),
            _InputSpec(
              name: 'Number · Compact',
              role: 'Schmales Zahlenfeld — Mindestmenge, Mengen-Stepper.',
              bgHex: '#F9FAFB',
              fgHex: '#111827',
              preview: _PreviewInputNumber(),
            ),
            _InputSpec(
              name: 'Multiline',
              role: 'Mehrzeilige Beschreibung — wächst mit dem Inhalt.',
              bgHex: '#F9FAFB',
              fgHex: '#111827',
              preview: _PreviewInputMultiline(),
            ),
            _InputSpec(
              name: 'Disabled',
              role: 'Read-only-Zustand für gesperrte Felder.',
              bgHex: '#F3F4F6',
              fgHex: '#9AA3AF',
              preview: _PreviewInputDisabled(),
            ),
            _InputSpec(
              name: 'Error',
              role: 'Inline-Validierung mit roter Inset-Border + Hinweis.',
              bgHex: '#F9FAFB',
              fgHex: '#B91C1C',
              preview: _PreviewInputError(),
            ),
          ],
        );
      },
    );
  }
}

class _InputSpec extends StatelessWidget {
  const _InputSpec({
    required this.name,
    required this.role,
    required this.bgHex,
    required this.fgHex,
    required this.preview,
  });

  final String name;
  final String role;
  final String bgHex;
  final String fgHex;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminStyleguidePage._kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminStyleguidePage._kBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08111827),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFF9FAFB),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              child: preview,
            ),
          ),
          const Divider(
            height: 1,
            color: AdminStyleguidePage._kBorder,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTypography.subheadline.copyWith(
                    color: AdminStyleguidePage._kText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption1.copyWith(
                    color: AdminStyleguidePage._kMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _ColorSwatch(label: 'BG', hex: bgHex),
                    _ColorSwatch(label: 'FG', hex: fgHex),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewInputDefault extends StatelessWidget {
  const _PreviewInputDefault();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 280,
        child: TextField(
          decoration: _styleguideInputDecoration(hint: 'z.B. Sicherheitsweste'),
        ),
      );
}

class _PreviewInputLabeled extends StatelessWidget {
  const _PreviewInputLabeled();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 280,
        child: TextField(
          decoration: _styleguideInputDecoration(
            hint: 'Beeswift',
            label: 'Lieferant',
          ),
        ),
      );
}

class _PreviewInputSearch extends StatelessWidget {
  const _PreviewInputSearch();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 280,
        child: TextField(
          decoration: _styleguideInputDecoration(
            hint: 'Suche nach Artikel…',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.search,
                size: 18,
                color: AdminStyleguidePage._kMuted,
              ),
            ),
          ).copyWith(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(999)),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(999)),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              borderSide: BorderSide(
                color: AppColors.codriverGreen,
                width: 1.6,
              ),
            ),
          ),
        ),
      );
}

class _PreviewInputNumber extends StatelessWidget {
  const _PreviewInputNumber();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 120,
        child: TextField(
          textAlign: TextAlign.center,
          controller: TextEditingController(text: '5'),
          keyboardType: TextInputType.number,
          style: AppTypography.subheadline.copyWith(
            color: AdminStyleguidePage._kText,
            fontWeight: FontWeight.w700,
          ),
          decoration: _styleguideInputDecoration(
            hint: '0',
            label: 'Min.',
          ),
        ),
      );
}

class _PreviewInputMultiline extends StatelessWidget {
  const _PreviewInputMultiline();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 280,
        child: TextField(
          maxLines: 3,
          decoration: _styleguideInputDecoration(
            hint: 'Beschreibung des Artikels…',
          ),
        ),
      );
}

class _PreviewInputDisabled extends StatelessWidget {
  const _PreviewInputDisabled();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 280,
        child: TextField(
          enabled: false,
          controller: TextEditingController(text: 'DSP-AMP01'),
          decoration: _styleguideInputDecoration(
            hint: '',
            label: 'SKU',
            enabled: false,
          ),
        ),
      );
}

class _PreviewInputError extends StatelessWidget {
  const _PreviewInputError();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 280,
        child: TextField(
          controller: TextEditingController(text: ''),
          decoration: _styleguideInputDecoration(
            hint: 'Pflichtfeld',
            label: 'Name',
            error: true,
          ).copyWith(
            errorText: 'Name darf nicht leer sein.',
          ),
        ),
      );
}
