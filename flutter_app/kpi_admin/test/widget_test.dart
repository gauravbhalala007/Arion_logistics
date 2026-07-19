// Smoke tests for the Codriver design system theme.
//
// The full app requires Firebase initialization, so these tests exercise
// the theme layer, which must stay consistent with CODRIVER_STYLEGUIDE.md.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kpi_admin/theme/app_colors.dart';
import 'package:kpi_admin/theme/app_theme.dart';

void main() {
  test('brand colors match the style guide', () {
    expect(AppColors.codriverGreen, const Color(0xFF00B287));
    expect(AppColors.green400, AppColors.codriverGreen);
  });

  testWidgets('light theme uses the Codriver primary color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: Text('Codriver')),
      ),
    );

    final BuildContext context = tester.element(find.text('Codriver'));
    expect(Theme.of(context).colorScheme.primary, AppColors.codriverGreen);
    expect(Theme.of(context).useMaterial3, isTrue);
  });
}
