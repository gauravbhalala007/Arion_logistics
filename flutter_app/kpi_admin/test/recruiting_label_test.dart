import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_admin/Screens/admin_recruiting_panel.dart';
void main() {
  test('Feldnamen werden lesbar', () {
    expect(prettyFieldLabel('dsgvoConsentAT'), 'DSGVO consent AT');
    expect(prettyFieldLabel('health_insurance'), 'Health insurance');
    expect(prettyFieldLabel('ibanSubmitLater'), 'IBAN submit later');
    expect(prettyFieldLabel('referredBy'), 'Referred by');
    expect(prettyFieldLabel('Krankenkasse'), 'Krankenkasse');
    expect(prettyFieldLabel('First name'), 'First name');
  });
}
