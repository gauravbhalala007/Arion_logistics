// Smoke-Test: erzeugt alle Work-Contract-PDFs einmal komplett und legt
// sie zur Sichtprüfung im Temp-Verzeichnis ab.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_admin/services/work_contracts/work_contract_model.dart';
import 'package:kpi_admin/services/work_contracts/work_contract_pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('alle PDFs bauen ohne Exception', () async {
    final sig = File(
        '/Users/albertdobra/Apps/CoDRIVER/docs/contracts/unterschrift_gf.png');
    final d = WorkContractData(
      type: WcType.visa,
      pay: WcPay.monthly,
      fixedTerm: true,
      employeeName: 'Max Mustermann',
      employeeStreet: 'Musterstr. 1',
      employeeZipCity: '91325 Adelsdorf',
      birthDate: DateTime(1998, 7, 11),
      nationality: 'Albanien',
      residenceSince: DateTime(1998, 7, 11),
      gender: 'm',
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2027, 10, 1),
      trainingWeek: '39/2026',
      hourlyWage: 16.20,
      monthlySalary: wcMonthlySalary(16.20, 40),
      hoursPerWeek: 40,
      vacationDays: 20,
      signCity: 'Adelsdorf',
      signDate: DateTime(2026, 8, 30),
    );
    final a = await wcLoadAssets(
        signaturePng: sig.existsSync() ? sig.readAsBytesSync() : null);
    final out = Directory.systemTemp.createTempSync('wc_pdfs_').path;
    File('$out/test_vertrag.pdf')
        .writeAsBytesSync(await wcBuildContractPdf(d, a));
    File('$out/test_zeitkonto.pdf')
        .writeAsBytesSync(await wcBuildZeitkontoPdf(d, a));
    File('$out/test_kamera.pdf')
        .writeAsBytesSync(await wcBuildCameraPrivacyPdf(d, a));
    File('$out/test_ezb.pdf').writeAsBytesSync(await wcBuildEzbPdf(d, a));
  });
}
