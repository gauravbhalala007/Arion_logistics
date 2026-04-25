# Codriver — Design System & Style Guide

> Apple-inspirierte Designsprache für die Codriver Flutter App
> Version 1.1 · Stand: April 2026 · iOS 26 Liquid Glass

---

## 1. Designphilosophie

Codriver folgt den Prinzipien von **Apples Human Interface Guidelines** und der **iOS 26 Liquid Glass** Designsprache. Klarheit, Tiefe, Deferenz. Inhalte stehen im Vordergrund, das Interface tritt zurück. Jedes Element hat einen Zweck, jeder Pixel ist bewusst gesetzt.

**Kernprinzipien**

- *Clarity* — Lesbarkeit vor Dekoration. Großzügiger Weißraum, klare Typografie.
- *Deference* — Das UI dient dem Inhalt, nicht umgekehrt.
- *Depth via Glass* — Tiefe entsteht durch Liquid-Glass-Layering und subtile Schatten.
- *Pill-shaped Controls* — Alle interaktiven Elemente sind vollständig pillig.
- *Consistency* — Wiederverwendbare Komponenten, einheitliche Spacing-Logik.
- *Motion with purpose* — Animationen erklären, sie schmücken nicht.

---

## 2. Farbsystem

Das Codriver-Farbsystem basiert auf der Logo-CI und ist für **Light & Dark Mode** ausgelegt. Verwende ausschließlich Tokens — niemals Hex-Werte direkt im Code.

### 2.1 Markenfarben (aus dem Logo abgeleitet)

| Token | Hex | RGB | Verwendung |
|---|---|---|---|
| `codriverGreen` | `#00B287` | 0, 178, 135 | Primäre Markenfarbe, CTAs, Akzente |
| `codriverDeep` | `#006047` | 0, 96, 71 | Hover-States, Tiefen-Akzent |
| `codriverGraphite` | `#3D3D3D` | 61, 61, 61 | Primärer Text (Light Mode) |

### 2.2 Erweiterte Palette (Tints & Shades)

```
Green 50   #E6F8F2   Hintergründe, Subtle Fills
Green 100  #B8EBD8
Green 200  #7DDDBE
Green 300  #3DCFA3
Green 400  #00B287   ← Primary
Green 500  #009972
Green 600  #007E5D
Green 700  #006047   ← Deep
Green 800  #00422F
Green 900  #002418
```

### 2.3 Semantische Farben (System-konform)

| Token | Light | Dark | Zweck |
|---|---|---|---|
| `background` | `#FFFFFF` | `#000000` | App-Hintergrund |
| `surface` | `#F2F2F7` | `#1C1C1E` | Cards, Sheets |
| `surfaceElevated` | `#FFFFFF` | `#2C2C2E` | Modals, Popover |
| `separator` | `#C6C6C8` | `#38383A` | Trennlinien |
| `label` | `#000000` | `#FFFFFF` | Primärtext |
| `labelSecondary` | `#3C3C43` (60%) | `#EBEBF5` (60%) | Sekundärtext |
| `labelTertiary` | `#3C3C43` (30%) | `#EBEBF5` (30%) | Hints, Placeholder |
| `success` | `#34C759` | `#30D158` | Erfolg |
| `warning` | `#FF9500` | `#FF9F0A` | Warnung |
| `error` | `#FF3B30` | `#FF453A` | Fehler |

### 2.4 Flutter Implementation

```dart
// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Marke
  static const codriverGreen     = Color(0xFF00B287);
  static const codriverDeep      = Color(0xFF006047);
  static const codriverGraphite  = Color(0xFF3D3D3D);

  // Tints
  static const green50  = Color(0xFFE6F8F2);
  static const green100 = Color(0xFFB8EBD8);
  static const green200 = Color(0xFF7DDDBE);
  static const green300 = Color(0xFF3DCFA3);
  static const green400 = codriverGreen;
  static const green500 = Color(0xFF009972);
  static const green600 = Color(0xFF007E5D);
  static const green700 = codriverDeep;
  static const green800 = Color(0xFF00422F);
  static const green900 = Color(0xFF002418);

  // Semantisch — Light
  static const backgroundLight       = Color(0xFFFFFFFF);
  static const surfaceLight          = Color(0xFFF2F2F7);
  static const surfaceElevatedLight  = Color(0xFFFFFFFF);
  static const separatorLight        = Color(0xFFC6C6C8);
  static const labelLight            = Color(0xFF000000);
  static const labelSecondaryLight   = Color(0x993C3C43);

  // Semantisch — Dark
  static const backgroundDark        = Color(0xFF000000);
  static const surfaceDark           = Color(0xFF1C1C1E);
  static const surfaceElevatedDark   = Color(0xFF2C2C2E);
  static const separatorDark         = Color(0xFF38383A);
  static const labelDark             = Color(0xFFFFFFFF);
  static const labelSecondaryDark    = Color(0x99EBEBF5);

  // Status
  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFF9500);
  static const error   = Color(0xFFFF3B30);
}
```

---

## 3. Typografie

Codriver verwendet **SF Pro** (System auf iOS) und **Inter** als Fallback für Android — beide haben sehr ähnliche Metriken und behalten den Apple-Look bei.

### 3.1 Type Scale (basierend auf iOS)

| Style | Size / Line Height | Weight | Tracking |
|---|---|---|---|
| Large Title | 34 / 41 | Bold (700) | 0.37 |
| Title 1 | 28 / 34 | Bold (700) | 0.36 |
| Title 2 | 22 / 28 | Bold (700) | 0.35 |
| Title 3 | 20 / 25 | Semibold (600) | 0.38 |
| Headline | 17 / 22 | Semibold (600) | -0.43 |
| Body | 17 / 22 | Regular (400) | -0.43 |
| Callout | 16 / 21 | Regular (400) | -0.32 |
| Subheadline | 15 / 20 | Regular (400) | -0.24 |
| Footnote | 13 / 18 | Regular (400) | -0.08 |
| Caption 1 | 12 / 16 | Regular (400) | 0 |
| Caption 2 | 11 / 13 | Regular (400) | 0.07 |

### 3.2 Flutter Implementation

```dart
// lib/theme/app_typography.dart
import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'SF Pro Display'; // iOS
  static const String fontFamilyFallback = 'Inter';  // Android

  static const TextStyle largeTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 34, height: 41/34,
    fontWeight: FontWeight.w700, letterSpacing: 0.37,
  );

  static const TextStyle title1 = TextStyle(
    fontFamily: fontFamily, fontSize: 28, height: 34/28,
    fontWeight: FontWeight.w700, letterSpacing: 0.36,
  );

  static const TextStyle title2 = TextStyle(
    fontFamily: fontFamily, fontSize: 22, height: 28/22,
    fontWeight: FontWeight.w700, letterSpacing: 0.35,
  );

  static const TextStyle title3 = TextStyle(
    fontFamily: fontFamily, fontSize: 20, height: 25/20,
    fontWeight: FontWeight.w600, letterSpacing: 0.38,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily, fontSize: 17, height: 22/17,
    fontWeight: FontWeight.w600, letterSpacing: -0.43,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily, fontSize: 17, height: 22/17,
    fontWeight: FontWeight.w400, letterSpacing: -0.43,
  );

  static const TextStyle callout = TextStyle(
    fontFamily: fontFamily, fontSize: 16, height: 21/16,
    fontWeight: FontWeight.w400, letterSpacing: -0.32,
  );

  static const TextStyle subheadline = TextStyle(
    fontFamily: fontFamily, fontSize: 15, height: 20/15,
    fontWeight: FontWeight.w400, letterSpacing: -0.24,
  );

  static const TextStyle footnote = TextStyle(
    fontFamily: fontFamily, fontSize: 13, height: 18/13,
    fontWeight: FontWeight.w400, letterSpacing: -0.08,
  );

  static const TextStyle caption1 = TextStyle(
    fontFamily: fontFamily, fontSize: 12, height: 16/12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle caption2 = TextStyle(
    fontFamily: fontFamily, fontSize: 11, height: 13/11,
    fontWeight: FontWeight.w400, letterSpacing: 0.07,
  );
}
```

### 3.3 Font Setup in `pubspec.yaml`

```yaml
flutter:
  fonts:
    - family: SF Pro Display
      fonts:
        - asset: assets/fonts/SF-Pro-Display-Regular.otf
          weight: 400
        - asset: assets/fonts/SF-Pro-Display-Semibold.otf
          weight: 600
        - asset: assets/fonts/SF-Pro-Display-Bold.otf
          weight: 700
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

---

## 4. Spacing & Layout

Codriver verwendet ein **4-Punkt-Grid** (Apple-Standard). Alle Abstände sind Vielfache von 4.

### 4.1 Spacing Tokens

| Token | Wert | Typische Verwendung |
|---|---|---|
| `xxs` | 4 | Icon-Text-Abstand |
| `xs`  | 8 | Inner Padding kleiner Elemente |
| `sm`  | 12 | Chip Padding |
| `md`  | 16 | Standard Card Padding, Listen-Items |
| `lg`  | 20 | Section Padding |
| `xl`  | 24 | Bildschirmrand-Padding |
| `xxl` | 32 | Großzügige Sektion-Trennung |
| `xxxl`| 48 | Hero-Bereiche |

```dart
class AppSpacing {
  static const double xxs  = 4;
  static const double xs   = 8;
  static const double sm   = 12;
  static const double md   = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double xxxl = 48;
}
```

### 4.2 Border Radius

Codriver folgt **iOS 26 Liquid Glass**: Buttons und interaktive Controls sind grundsätzlich **vollständig pillig** (`full`). Container und Cards erhalten weiche, organische Rundungen.

| Token | Wert | Verwendung |
|---|---|---|
| `xs`  | 8  | Tags, kleine Chips, Badges |
| `sm`  | 12 | Inputs |
| `md`  | 18 | Cards, Listen-Items |
| `lg`  | 24 | Sheets, Modals |
| `xl`  | 32 | Bottom Sheets, Hero Cards |
| `full`| 999 | **Buttons (default), Pills, Avatars, FABs** |

```dart
class AppRadius {
  static const Radius xs   = Radius.circular(8);
  static const Radius sm   = Radius.circular(12);
  static const Radius md   = Radius.circular(18);
  static const Radius lg   = Radius.circular(24);
  static const Radius xl   = Radius.circular(32);
  static const Radius full = Radius.circular(999);
}
```

---

## 5. Elevation & Schatten

Apple verwendet sehr **subtile** Schatten — niemals harte Drop Shadows. Tiefe entsteht durch Layering und Blur, nicht durch dunkle Schatten.

| Level | Verwendung | Schatten |
|---|---|---|
| 0 | Flach (Background) | keiner |
| 1 | Cards (Resting) | `0 1 2 rgba(0,0,0,0.04)` |
| 2 | Cards (Hover) | `0 4 12 rgba(0,0,0,0.06)` |
| 3 | Sheets, Popover | `0 8 24 rgba(0,0,0,0.08)` |
| 4 | Modals, Glass-Layer | `0 16 48 rgba(0,0,0,0.12)` |

```dart
class AppElevation {
  static const List<BoxShadow> level1 = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 2),
  ];
  static const List<BoxShadow> level2 = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 4), blurRadius: 12),
  ];
  static const List<BoxShadow> level3 = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 8), blurRadius: 24),
  ];
  static const List<BoxShadow> level4 = [
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 16), blurRadius: 48),
  ];
}
```

---

## 5.5 Liquid Glass (iOS 26 Material System)

Das Herzstück der Codriver-Designsprache. **Liquid Glass** ist nicht einfach Transparenz — es ist ein mehrschichtiges Material mit **Blur, Tönung, innerem Highlight und feiner Borderkante**, das den Inhalt darunter dynamisch durchschimmern lässt.

### 5.5.1 Glass-Varianten

| Variante | Verwendung | Blur | Tint Light | Tint Dark |
|---|---|---|---|---|
| `glassUltraThin` | Floating Pills, kleine Chips | 30 | `rgba(255,255,255,0.45)` | `rgba(20,20,22,0.45)` |
| `glassThin` | Tab Bar, Toolbar | 40 | `rgba(255,255,255,0.6)` | `rgba(28,28,30,0.6)` |
| `glassRegular` | Navigation Bar, Cards | 50 | `rgba(255,255,255,0.72)` | `rgba(28,28,30,0.72)` |
| `glassThick` | Sheets, Popover | 60 | `rgba(248,248,250,0.85)` | `rgba(38,38,42,0.85)` |
| `glassChrome` | App-Chrome, immer sichtbar | 80 | `rgba(255,255,255,0.92)` | `rgba(28,28,30,0.92)` |

### 5.5.2 Anatomie eines Glass-Layers

Jede Glass-Fläche besteht aus **vier übereinanderliegenden Schichten**:

1. **Blur Layer** — `BackdropFilter` mit Gauß-Blur (sigma 30–80)
2. **Tint Layer** — halbtransparenter Farbverlauf (vertikal, oben heller)
3. **Inner Highlight** — 1px Border oben innen mit `rgba(255,255,255,0.5)` (wirkt wie Lichtkante)
4. **Border** — 0.5px Border `rgba(255,255,255,0.15)` (Glas-Kante)

### 5.5.3 Flutter Implementation

```dart
// lib/theme/app_glass.dart
import 'dart:ui';
import 'package:flutter/material.dart';

enum GlassVariant { ultraThin, thin, regular, thick, chrome }

class GlassContainer extends StatelessWidget {
  final Widget child;
  final GlassVariant variant;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isDark;

  const GlassContainer({
    super.key,
    required this.child,
    this.variant = GlassVariant.regular,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding = const EdgeInsets.all(16),
    this.isDark = false,
  });

  double get _sigma => switch (variant) {
    GlassVariant.ultraThin => 30,
    GlassVariant.thin      => 40,
    GlassVariant.regular   => 50,
    GlassVariant.thick     => 60,
    GlassVariant.chrome    => 80,
  };

  Color get _tint {
    if (isDark) {
      return switch (variant) {
        GlassVariant.ultraThin => const Color(0x73141416),
        GlassVariant.thin      => const Color(0x991C1C1E),
        GlassVariant.regular   => const Color(0xB81C1C1E),
        GlassVariant.thick     => const Color(0xD9262628),
        GlassVariant.chrome    => const Color(0xEB1C1C1E),
      };
    }
    return switch (variant) {
      GlassVariant.ultraThin => const Color(0x73FFFFFF),
      GlassVariant.thin      => const Color(0x99FFFFFF),
      GlassVariant.regular   => const Color(0xB8FFFFFF),
      GlassVariant.thick     => const Color(0xD9F8F8FA),
      GlassVariant.chrome    => const Color(0xEBFFFFFF),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _tint.withOpacity((_tint.opacity + 0.05).clamp(0, 1)),
                _tint,
              ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.5),
              width: 0.5,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
```

### 5.5.4 Wann Glass — wann nicht?

| Glass verwenden | Solid verwenden |
|---|---|
| Tab Bar, Nav Bar | Reine Content-Cards |
| Floating Buttons (FAB), Pills | Listen-Items |
| Modals, Sheets | App-Hintergrund |
| Toolbars, HUDs | Inputs, Form-Felder |
| Toasts, Banner | Buttons mit voller Markenfarbe |

---

## 6. Komponenten

### 6.1 Buttons

Vier Varianten — **alle vollständig pillig** (`StadiumBorder()`), Höhe 50pt. Im iOS 26 Stil sind Buttons immer rund — niemals eckig.

| Variante | Hintergrund | Text | Verwendung |
|---|---|---|---|
| **Primary** | `codriverGreen` (Solid) | weiß | Hauptaktion, max. 1 pro Screen |
| **Glass** | Liquid Glass (regular) + Tint | `codriverDeep` | Sekundärer CTA, schwebende Buttons |
| **Tertiary** | transparent | `codriverGreen` | Inline-Aktion, "Mehr" |
| **Destructive** | `error` | weiß | Löschen, Abbrechen |

```dart
// Primary Pill Button
SizedBox(
  height: 50,
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.codriverGreen,
      foregroundColor: Colors.white,
      shape: const StadiumBorder(),
      textStyle: AppTypography.headline,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      shadowColor: AppColors.codriverGreen.withOpacity(0.4),
    ),
    onPressed: () {},
    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
    label: const Text('Fahrt starten'),
  ),
)

// Glass Pill Button
GlassContainer(
  variant: GlassVariant.regular,
  borderRadius: const BorderRadius.all(Radius.circular(999)),
  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
  child: Text(
    'Später',
    style: AppTypography.headline.copyWith(color: AppColors.codriverDeep),
  ),
)
```

### 6.2 Cards

```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: AppColors.surfaceElevatedLight,
    borderRadius: BorderRadius.all(AppRadius.md),
    boxShadow: AppElevation.level1,
  ),
  child: ...,
)
```

### 6.3 Text Fields (Cupertino-Style)

```dart
CupertinoTextField(
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.md, vertical: AppSpacing.sm,
  ),
  decoration: BoxDecoration(
    color: AppColors.surfaceLight,
    borderRadius: BorderRadius.all(AppRadius.sm),
  ),
  style: AppTypography.body,
  placeholderStyle: AppTypography.body.copyWith(
    color: AppColors.labelSecondaryLight,
  ),
)
```

### 6.4 Navigation Bar (Liquid Glass Chrome)

iOS 26 Style — schwebt über dem Inhalt mit echtem Glass-Material.

```dart
GlassContainer(
  variant: GlassVariant.chrome,
  borderRadius: BorderRadius.zero,
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.md, vertical: AppSpacing.sm,
  ),
  child: Row(...),
)
```

### 6.5 Floating Tab Bar (iOS 26 Style)

Die Tab Bar schwebt jetzt als Glass-Pill über dem Content — nicht mehr randbündig.

```dart
Positioned(
  bottom: 24, left: 24, right: 24,
  child: GlassContainer(
    variant: GlassVariant.thick,
    borderRadius: const BorderRadius.all(Radius.circular(999)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: tabs.map((t) => _TabItem(t)).toList(),
    ),
  ),
)
```

---

## 7. Iconografie

**Wichtig: Niemals Emojis als Icons verwenden.** Emojis sind plattform-, font- und versionsabhängig und brechen die visuelle Einheitlichkeit. Codriver verwendet ausschließlich vektorbasierte Icon-Sets.

### 7.1 Icon-Quellen (in Reihenfolge der Präferenz)

1. **Material Symbols Rounded** (Default) — als SVG via `flutter_svg`, oder als Font via `material_symbols_icons` Package. Strichstärke 1.5–2px, gerundete Enden. Passt visuell perfekt zum SF-Pro-Look.
2. **SF Symbols** (iOS-spezifische Builds) — über `cupertino_icons` oder `flutter_sf_symbols`. Optional, nur wenn ein konkreter iOS-System-Look benötigt wird.
3. **Custom SVG-Set** für Codriver-spezifische Icons (Fleet-Icons, Marken-Symbole) — abgelegt unter `assets/icons/` und via `flutter_svg` eingebunden.

### 7.2 Setup

```yaml
# pubspec.yaml
dependencies:
  material_symbols_icons: ^4.2719.3
  flutter_svg: ^2.0.10+1
```

### 7.3 Verwendung in Flutter

```dart
import 'package:material_symbols_icons/symbols.dart';

// Standard Material Symbol — gerundet, gefüllt nach Bedarf
const Icon(
  Symbols.home_rounded,
  size: 24,
  color: AppColors.codriverGreen,
  weight: 400,
  fill: 0, // 0 = outlined, 1 = filled
)

// Aktiver Tab — gefüllt
const Icon(Symbols.home_rounded, fill: 1, weight: 500)
```

### 7.4 Standard-Icon-Set für Codriver

| Verwendung | Material Symbol |
|---|---|
| Home | `home_rounded` |
| Karte | `map_rounded` |
| Statistik | `bar_chart_rounded` |
| Profil | `person_rounded` |
| Einstellungen | `settings_rounded` |
| Benachrichtigung | `notifications_rounded` |
| Favorit | `star_rounded` |
| Fahrt starten | `play_arrow_rounded` |
| Pause | `pause_rounded` |
| Lade-Station | `bolt_rounded` |
| Pause/Kaffee | `local_cafe_rounded` |
| Suchen | `search_rounded` |
| Schließen | `close_rounded` |
| Zurück | `arrow_back_ios_new_rounded` |
| Weiter | `arrow_forward_rounded` |
| Mehr | `more_horiz_rounded` |

### 7.5 Icon-Größen & Farben

- **Standard-Größen**: 16, 20, 24, 28, 32 — passend zum 4er-Grid
- **Strichstärke**: 1.5px (Default), 2px (Bold-States)
- **Farbe**: erbt vom Text-Color, niemals fest verdrahten
- **Mindest-Touch-Target** für Icon-Buttons: 44 × 44 pt

---

## 8. Motion & Animation

| Typ | Dauer | Curve | Verwendung |
|---|---|---|---|
| Micro | 150ms | `easeInOut` | Hover, Toggle |
| Standard | 250ms | `easeOutCubic` | Sheet öffnen, Tab Switch |
| Emphasized | 400ms | `easeOutQuint` | Page Transitions |
| Spring | — | `Curves.easeOutBack` | Playful Feedback |

```dart
class AppMotion {
  static const Duration micro       = Duration(milliseconds: 150);
  static const Duration standard    = Duration(milliseconds: 250);
  static const Duration emphasized  = Duration(milliseconds: 400);

  static const Curve easeOutCubic   = Curves.easeOutCubic;
  static const Curve easeOutQuint   = Cubic(0.22, 1, 0.36, 1);
}
```

---

## 9. Theme-Bundle

```dart
// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.codriverGreen,
      onPrimary: Colors.white,
      secondary: AppColors.codriverDeep,
      surface: AppColors.surfaceElevatedLight,
      onSurface: AppColors.labelLight,
      error: AppColors.error,
    ),
    fontFamily: AppTypography.fontFamily,
    splashFactory: NoSplash.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.codriverGreen,
      onPrimary: Colors.black,
      secondary: AppColors.green200,
      surface: AppColors.surfaceElevatedDark,
      onSurface: AppColors.labelDark,
      error: AppColors.error,
    ),
    fontFamily: AppTypography.fontFamily,
  );
}
```

---

## 10. Accessibility

- **Kontrastverhältnis**: mindestens 4.5:1 (Text), 3:1 (UI-Elemente)
- **Mindest-Touch-Target**: 44 × 44 pt (Apple HIG)
- **Dynamic Type**: Texte skalieren mit `MediaQuery.textScaleFactor`
- **Reduce Motion**: bei `MediaQuery.disableAnimations` Übergänge dämpfen
- **Semantic Labels**: jedes interaktive Widget bekommt `Semantics`

---

## 11. Logo-Verwendung

- **Mindestgröße**: 32 × 32 pt (App Icon: 1024 × 1024 px)
- **Schutzraum**: ½ der Logohöhe rundherum frei
- **Hintergründe**: bevorzugt weiß oder `green50`. Auf dunklem Hintergrund: weiße Variante
- **Verbotene Modifikationen**: keine Verzerrung, keine Farbänderung, keine Schatten

---

## 12. Nächste Schritte

- [ ] Schriftarten in `assets/fonts/` einbinden
- [ ] `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_glass.dart` anlegen
- [ ] `material_symbols_icons` Package installieren
- [ ] Storybook-ähnliche Demo-Page mit allen Komponenten erstellen
- [ ] Dark Mode visuell QA-en
- [ ] Logo als `assets/brand/codriver_logo.svg` einbinden (`flutter_svg`)
- [ ] App Icon Set generieren (z.B. via `flutter_launcher_icons`)

---

*Dieser Style Guide ist ein lebendes Dokument — wir iterieren gemeinsam.*
