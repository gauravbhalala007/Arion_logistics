import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final Widget sideMenu;         // your left menu widget (styled)
  final Widget body;             // page content
  final Widget? title;           // shown in AppBar on narrow screens
  final List<Widget>? actions;   // right-side actions in AppBar (e.g., CSV button)
  final double menuWidth;

  const AppShell({
    super.key,
    required this.sideMenu,
    required this.body,
    this.title,
    this.actions,
    this.menuWidth = 280,
  });

  bool _isNarrow(BuildContext c) => MediaQuery.of(c).size.width < 1100;

  @override
  Widget build(BuildContext context) {
    final narrow = _isNarrow(context);

    return Scaffold(
      // AppBar only on narrow; wide screens will see persistent left menu
      appBar: narrow
          ? AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: title ?? const SizedBox(),
              actions: actions,
            )
          : null,

      drawer: narrow
          ? Drawer(
              // You already style the sideMenu; just embed it in a SafeArea
              child: SafeArea(child: sideMenu),
            )
          : null,

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!narrow)
            SizedBox(width: menuWidth, child: sideMenu), // persistent menu
          Expanded(child: body),                          // page content
        ],
      ),
    );
  }
}
