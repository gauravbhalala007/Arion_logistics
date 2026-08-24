// Shared "clear the search input" affordance for every search bar in the app.
//
// The app has ~25 hand-rolled search fields, each with its own height, radius
// and prefix icon. Rebuilding them all on one widget would be invasive, so
// instead every field keeps its own look and only borrows this suffix button.
//
// Usage inside an existing InputDecoration:
//
//   suffixIcon: buildSearchClearButton(
//     context: context,
//     value: _query,
//     onClear: () {
//       _searchCtrl.clear();
//       setState(() => _query = '');  // must mirror the field's onChanged('')
//     },
//   ),
//   suffixIconConstraints: kSearchClearConstraints,
//
// The button is `null` while the input is empty, so an untouched field looks
// exactly like before.

import 'package:flutter/material.dart';

/// 40x40 tap target — the minimum comfortable touch size — while still fitting
/// inside the app's 40–48px tall search fields.
const BoxConstraints kSearchClearConstraints =
    BoxConstraints(minWidth: 40, minHeight: 40);

/// Same tap width, but height-neutral for the few very dense fields whose
/// natural height is below 40px and must not grow when the X appears.
const BoxConstraints kSearchClearConstraintsCompact =
    BoxConstraints(minWidth: 40, minHeight: 30);

/// Default grey — deliberately quiet so the X never competes with the content.
const Color kSearchClearColor = Color(0xFF9CA3AF);

/// Returns the clear button for a search field, or `null` when [value] is
/// empty (so the decoration is unchanged for an untouched field).
///
/// [onClear] must do *both* things: empty the [TextEditingController] **and**
/// push `''` through the same state/filter path the field's `onChanged` uses,
/// otherwise the list stays filtered while the box looks empty.
///
/// The button is wrapped in [ExcludeFocus] so tapping it cannot steal focus
/// from the text field; pass [focusNode] to additionally re-assert focus.
Widget? buildSearchClearButton({
  required BuildContext context,
  required String value,
  required VoidCallback onClear,
  double iconSize = 18,
  Color color = kSearchClearColor,
  FocusNode? focusNode,
}) {
  if (value.isEmpty) return null;
  final de = Localizations.localeOf(context).languageCode == 'de';
  return ExcludeFocus(
    child: Tooltip(
      message: de ? 'Eingabe löschen' : 'Clear',
      child: IconButton(
        icon: Icon(Icons.close_rounded, size: iconSize),
        color: color,
        splashRadius: 18,
        padding: EdgeInsets.zero,
        constraints: kSearchClearConstraints,
        visualDensity: VisualDensity.compact,
        onPressed: () {
          onClear();
          if (focusNode != null && !focusNode.hasFocus) {
            focusNode.requestFocus();
          }
        },
      ),
    ),
  );
}
