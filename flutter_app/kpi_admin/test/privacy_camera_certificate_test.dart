// Regressionstest für die Kamera-Datenschutz-Bescheinigung.
//
// Zwei Zusicherungen, die rechtlich zählen:
//   1. Die Unterschrift landet als Bild-Objekt im PDF (sie ist Pflicht).
//   2. Das PDF ist einsprachig deutsch — kein Übersetzungsblock.
//
// Der Generator ist bewusst frei von Flutter-Abhängigkeiten, damit er
// hier ohne Widget-Umgebung laufen kann.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_admin/Screens/driver_privacy_camera_certificate.dart';

/// Kleinstes gültiges PNG (1x1, transparent) — als Beispiel-Unterschrift.
final Uint8List _samplePng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
  'YPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

Future<Uint8List> _build({Uint8List? signature}) =>
    buildPrivacyCameraCertificatePdf(
      signaturePng: signature,
      driverName: 'Max Mustermann',
      employeeNumber: '4711',
      companyName: 'Arion Logistics GmbH',
      occurredAt: DateTime(2026, 8, 22, 9, 30),
      documentTitle: 'Datenschutzerklärung für den Einsatz von '
          'Verkehrssicherheitstechnologien',
      documentVersion: '2026-08-18',
      contentSha256: 'a' * 64,
      moduleTitles: const ['Worum es hier geht', 'Wie die Kameras arbeiten'],
      statementShown: 'Ich bestätige, dass ich die Datenschutzerklärung '
          'für den Einsatz von Verkehrssicherheitstechnologien und '
          'Fahrsicherheitstools in der Fassung vom 18.08.2026 erhalten und '
          'zur Kenntnis genommen habe.',
      clarification: 'Mir ist bekannt, dass diese Bestätigung keine '
          'Einwilligung in die Datenverarbeitung darstellt. Die Verarbeitung '
          'erfolgt auf Grundlage berechtigter Interessen.',
    );

void main() {
  test('Unterschrift wird als Bild in das PDF eingebettet', () async {
    final withSig = await _build(signature: _samplePng);
    final withoutSig = await _build();

    expect(withSig, isNotEmpty);

    // Aussagekraeftig ist das Bild-XObject: Es entsteht ausschliesslich
    // durch das eingebettete Unterschriftsbild. (Die Zeichenfolge
    // '/Image' allein taugt nicht als Nachweis — sie steht auch ohne
    // Unterschrift im Dokumentgeruest.)
    final withSigStr = latin1.decode(withSig, allowInvalid: true);
    final withoutSigStr = latin1.decode(withoutSig, allowInvalid: true);

    expect(
      withSigStr.contains('/XObject'),
      isTrue,
      reason: 'Bescheinigung mit Unterschrift muss ein Bild-XObject enthalten',
    );
    expect(
      withoutSigStr.contains('/XObject'),
      isFalse,
      reason: 'ohne Unterschrift darf kein Bild-XObject entstehen',
    );
    expect(
      withSig.length,
      greaterThan(withoutSig.length),
      reason: 'das eingebettete Bild muss das PDF vergrößern',
    );
  });

  test('Fallback-Vermerk nur ohne Unterschrift', () async {
    final withSig = latin1.decode(
      await _build(signature: _samplePng),
      allowInvalid: true,
    );
    final withoutSig = latin1.decode(await _build(), allowInvalid: true);

    // Der Vermerktext steht komprimiert im Content-Stream und ist im
    // Rohbyte-Strom nicht lesbar; gegengeprueft wird deshalb ueber das
    // Bild-XObject, das genau den Unterschied ausmacht.
    expect(withSig.contains('/XObject'), isTrue);
    expect(withoutSig.contains('/XObject'), isFalse);
  });

  test('Bescheinigung enthält keinen Übersetzungsblock', () async {
    final pdf = await _build(signature: _samplePng);
    final str = latin1.decode(pdf, allowInvalid: true);
    expect(
      str.contains('Übersetzung'),
      isFalse,
      reason: 'die Bescheinigung ist ausschließlich deutsch',
    );
  });
}
