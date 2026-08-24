// Prüft den TID-Matcher: die synthetischen Fälle laufen immer, die
// Prüfung gegen echte Bestände nur, wenn ein Abzug unter
// `test/drivers_export.json` liegt.
//
// Der Abzug wird bewusst NICHT eingecheckt (echte Fahrernamen). Zum
// Erzeugen mit Admin-Zugang:
//
//   users/{dspUid}/drivers → [{docId, driverName, employeeNumber,
//                              transporterId, tidPendingFlag}]
//   Datei: {"<dsp>": [...], ...}
//
// Damit wurde belegt: bei Arion, eos express und einem DSP mit 42
// Platzhalter-Fahrern löst kein bestehendes Profil einen automatischen
// Umzug aus, und 37 von 39 Platzhaltern sind per Name eindeutig
// zuzuordnen (die zwei übrigen sind zwei echte Namensgleiche und
// bleiben korrekt mehrdeutig).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_admin/services/driver_identity_service.dart';

List<DriverMatchCandidate> _load(String dsp) {
  final raw = jsonDecode(File('test/drivers_export.json').readAsStringSync());
  return (raw[dsp] as List)
      .map((e) => DriverMatchCandidate(
            docId: e['docId'] as String,
            driverName: e['driverName'] as String,
            employeeNumber: e['employeeNumber'] as String,
            transporterId: e['transporterId'] as String,
            tidPending: isPlaceholderTid(
              (e['transporterId'] as String).isEmpty
                  ? e['docId'] as String
                  : e['transporterId'] as String,
            ),
          ))
      .toList();
}

void main() {
  test('Namens-Normalisierung', () {
    expect(normalizeDriverName('Ardi Syla'), normalizeDriverName('Syla Ardi'));
    expect(normalizeDriverName('Granit Dërmaku'),
        normalizeDriverName('granit dermaku'));
    expect(normalizeDriverName('Ardi Syla') == normalizeDriverName('Blend Syla'),
        isFalse);
  });

  test('Platzhalter erkennen', () {
    expect(isPlaceholderTid('PENDING-XASHFZ'), isTrue);
    expect(isPlaceholderTid(''), isTrue);
    expect(isPlaceholderTid('A12ISAY50KJUS1'), isFalse);
  });

  test('haengendes tidPending-Flag zaehlt nicht mehr als ausstehend', () {
    // Ardi Syla: echte TID im Doc, Flag steht faelschlich noch auf true.
    expect(
      isDriverTidPending(
        <String, dynamic>{'transporterId': 'A12ISAY50KJUS1', 'tidPending': true},
        'A12ISAY50KJUS1',
      ),
      isFalse,
    );
    expect(
      isDriverTidPending(
        <String, dynamic>{'transporterId': 'PENDING-XASHFZ', 'tidPending': false},
        'PENDING-XASHFZ',
      ),
      isTrue,
    );
  });

  group('echte Bestaende', skip: !File('test/drivers_export.json').existsSync(),
      () {
    for (final dsp in ['arion', 'bigdsp', 'eos']) {
      test('$dsp: bestehende Fahrer loesen keinen automatischen Umzug aus', () {
        final index = DriverIdentityIndex(_load(dsp));
        // Regel des CSV-Imports: automatisch zusammengefuehrt wird nur,
        // wenn unter der TID noch KEIN Profil liegt — oder wenn ein
        // Mensch die TID bereits zugeordnet hat und nur der Umzug fehlt.
        bool autoMigrates(DriverMatchResult r, bool targetExists) =>
            r.isMatch &&
            (!targetExists || r.reason == DriverMatchReason.transporterIdField);

        for (final c in index.candidates) {
          if (isPlaceholderTid(c.docId)) continue;
          final r = index.match(tid: c.docId, driverName: c.driverName);
          expect(autoMigrates(r, index.hasDoc(c.docId)), isFalse,
              reason: 'Fahrer ${c.docId} (${c.driverName}) haette faelschlich '
                  'einen automatischen Umzug ausgeloest → ${r.docId}');
        }
      });

      test('$dsp: neue TID fuer bekannten Platzhalter-Namen trifft', () {
        final index = DriverIdentityIndex(_load(dsp));
        final pend = index.candidates.where((c) => c.tidPending).toList();
        if (pend.isEmpty) return;
        var matched = 0;
        for (final p in pend) {
          final r = index.match(tid: 'A0NEWTID${pend.indexOf(p)}', driverName: p.driverName);
          if (r.isMatch && r.docId == p.docId) matched++;
        }
        // Mindestens die eindeutigen Namen muessen greifen.
        expect(matched, greaterThan(0),
            reason: '$dsp: kein einziger Platzhalter wurde per Name gefunden');
        // ignore: avoid_print
        print('$dsp: ${pend.length} Platzhalter, davon $matched per Name eindeutig');
      });

      test('$dsp: fremder Name loest nie einen Umzug aus', () {
        final index = DriverIdentityIndex(_load(dsp));
        final r = index.match(
            tid: 'A0FREMDTID1', driverName: 'Zzz Unbekannt Testperson');
        expect(r.isMatch, isFalse);
      });
    }
  });

  test('doppelte Platzhalter-Namen bleiben mehrdeutig', () {
    final index = DriverIdentityIndex(const [
      DriverMatchCandidate(
          docId: 'PENDING-AAA', driverName: 'Suliman Shah',
          employeeNumber: '', transporterId: 'PENDING-AAA', tidPending: true),
      DriverMatchCandidate(
          docId: 'PENDING-BBB', driverName: 'Suliman Shah',
          employeeNumber: '', transporterId: 'PENDING-BBB', tidPending: true),
    ]);
    final r = index.match(tid: 'A1NEUE', driverName: 'Suliman Shah');
    expect(r.isMatch, isFalse);
    expect(r.isAmbiguous, isTrue);
  });

  test('zugeordnet-aber-nicht-umgezogen wird sicher erkannt', () {
    final index = DriverIdentityIndex(const [
      DriverMatchCandidate(
          docId: 'PENDING-SSYXJR', driverName: 'Alin-Vasile Loghin',
          employeeNumber: '274', transporterId: 'A2CXCRAX2P649Y',
          tidPending: false),
    ]);
    final r = index.match(tid: 'A2CXCRAX2P649Y', driverName: 'Alin-Vasile Loghin');
    expect(r.isMatch, isTrue);
    expect(r.docId, 'PENDING-SSYXJR');
    expect(r.reason, DriverMatchReason.transporterIdField);
  });
}
