// lib/Screens/admin_privacy_camera_section.dart
//
// Admin-Abschnitt der DA Academy für „Kameras im Fahrzeug – Datenschutz".
//
// Zeigt je Fahrer den Nachweis der Kenntnisnahme: bestätigt / nicht
// bestätigt / offen, mit Datum, Fassung, Prüfsumme, gelesener Sprache
// und Lesedauer — und bei Verweigerung den Vermerk nach Spec §7.
//
// KEIN QUIZ: Der Kurs hat keine Testfragen mehr, entsprechend gibt es
// keine Quiz-Spalte. Belegt wird die Kenntnisnahme über die
// durchlaufenen Module, das Scroll-Gate im Volltext und die Lesedauer.
//
// KEINE WIDERSPRUCHS-VERWALTUNG: Der In-App-Widerspruch wurde auf
// Kundenwunsch entfernt, deshalb gibt es hier keinen Widersprüche-Reiter
// mehr. Die gesetzliche Information über das Widerspruchsrecht bleibt in
// den Volltext-Dokumenten und im Rechte-Modul erhalten; die Ausübung
// läuft über die dort genannte Kontaktadresse.
//
// WARUM EIGENER ABSCHNITT statt eines Eintrags in `kAcademyTrainings`:
// Die generische Schulungskarte rechnet mit `passedAt` bzw. einer
// `acknowledged`-Map und kennt nur „erledigt / fehlt noch". Dieses Modul
// kennt weder Bestehen noch Ablauf, dafür den Ausgang „nicht bestätigt",
// der ausdrücklich KEIN Fehlerfall ist und deshalb nicht unter „Fehlt
// noch" laufen darf. Die Bestandsschulungen bleiben unverändert.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/privacy_camera/privacy_camera_content.dart';
import '../data/privacy_camera/privacy_camera_repository.dart';
import '../data/privacy_camera/privacy_camera_texts.dart';
import '../widgets/academy_visibility_toggle.dart';

const Color _kText = Color(0xFF111827);
const Color _kSub = Color(0xFF4B5563);
const Color _kMuted = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);
const Color _kAccent = Color(0xFF2A5FB0);

String _fmt(DateTime at) => DateFormat('dd.MM.yyyy').format(at);

/// Status eines Fahrers in der Nachweisliste.
enum _AckStatus { acknowledged, declined, outdated, open }

class _AckRow {
  final String transporterId;
  final String name;
  final String employeeNumber;
  final _AckStatus status;
  final PrivacyCameraAck? ack;

  const _AckRow({
    required this.transporterId,
    required this.name,
    required this.employeeNumber,
    required this.status,
    this.ack,
  });

  bool matches(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) ||
        transporterId.toLowerCase().contains(q) ||
        employeeNumber.toLowerCase().contains(q);
  }
}

class _SectionData {
  final List<_AckRow> ackRows;
  final PrivacyCourseBundle bundle;

  const _SectionData({required this.ackRows, required this.bundle});

  int count(_AckStatus s) => ackRows.where((r) => r.status == s).length;
}

class AdminPrivacyCameraSection extends StatefulWidget {
  const AdminPrivacyCameraSection({
    super.key,
    required this.dspUid,
    required this.drivers,
    required this.de,
    required this.narrow,
    required this.visible,
    required this.onVisibilityChanged,
  });

  final String dspUid;

  /// Aktive Fahrer aus der Elternseite (`__id` = Transporter-ID).
  final List<Map<String, dynamic>> drivers;
  final bool de;
  final bool narrow;

  /// Admin-Schalter „Für Fahrer sichtbar". Wirkt ZUSÄTZLICH zur
  /// systemweiten Sperre [kPrivacyCameraDriverEnabled]: Die Kachel
  /// erscheint nur, wenn beides an ist.
  final bool visible;
  final ValueChanged<bool> onVisibilityChanged;

  @override
  State<AdminPrivacyCameraSection> createState() =>
      _AdminPrivacyCameraSectionState();
}

class _AdminPrivacyCameraSectionState extends State<AdminPrivacyCameraSection> {
  /// Bewusst kein `late final`: Wechselt der Admin-Scope (Disponent mit
  /// mehreren Konten), muss die Abfrage dem neuen dspUid folgen.
  PrivacyCameraAdminRepository get _repo =>
      PrivacyCameraAdminRepository(dspUid: widget.dspUid);

  Future<_SectionData>? _future;
  String _query = '';

  String get _lang => widget.de ? 'de' : 'en';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant AdminPrivacyCameraSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dspUid != widget.dspUid ||
        oldWidget.drivers.length != widget.drivers.length) {
      _reload();
    }
  }

  void _reload() => setState(() => _future = _load());

  Future<_SectionData> _load() async {
    // Die Admin-Ansicht vergleicht gegen die DEUTSCHE Fassung — sie ist
    // die verbindliche, unabhängig davon, in welcher Sprache der Fahrer
    // den Kurs gelesen hat.
    final bundle = await PrivacyCourseBundle.load(kPrivacyBindingLanguage);
    final acks = await _repo.loadAcks();
    final doc = bundle.bindingDocument;

    final ackRows = <_AckRow>[];
    for (final driver in widget.drivers) {
      final tid = '${driver['__id'] ?? ''}'.trim();
      if (tid.isEmpty) continue;
      final name = '${driver['driverName'] ?? driver['name'] ?? ''}'.trim();
      final employeeNumber = '${driver['employeeNumber'] ?? ''}'.trim();
      final ack = acks[tid.toUpperCase()];

      late final _AckStatus status;
      if (ack == null) {
        status = _AckStatus.open;
      } else if (!ack.matchesDocument(doc)) {
        // Nachweis existiert, betrifft aber eine ältere Fassung.
        status = _AckStatus.outdated;
      } else if (ack.isAcknowledged) {
        status = _AckStatus.acknowledged;
      } else {
        status = _AckStatus.declined;
      }

      ackRows.add(
        _AckRow(
          transporterId: tid,
          name: name.isEmpty ? tid : name,
          employeeNumber: employeeNumber,
          status: status,
          ack: ack,
        ),
      );
    }
    ackRows.sort((a, b) {
      final byStatus = a.status.index.compareTo(b.status.index);
      if (byStatus != 0) return byStatus;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return _SectionData(ackRows: ackRows, bundle: bundle);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      padding: EdgeInsets.all(widget.narrow ? 14 : 18),
      child: FutureBuilder<_SectionData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.hasError || snap.data == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    widget.de
                        ? 'Die Datenschutz-Nachweise konnten nicht geladen werden.'
                        : 'The data-protection records could not be loaded.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _kSub, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(privacyCameraText(_lang, 'admin_refresh')),
                  ),
                ],
              ),
            );
          }
          return _content(snap.data!);
        },
      ),
    );
  }

  Widget _content(_SectionData data) {
    final rows = data.ackRows.where((r) => r.matches(_query)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(data),
        AcademyVisibilityToggle(
          de: widget.de,
          narrow: widget.narrow,
          visible: widget.visible,
          onChanged: widget.onVisibilityChanged,
          systemLocked: !kPrivacyCameraDriverEnabled,
        ),
        // Solange das Modul für Fahrer gesperrt ist, sagt die Ansicht das
        // offen — sonst wirkt eine Liste voller „Offen" wie ein Rückstand.
        if (!kPrivacyCameraDriverEnabled) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD9A0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 17,
                  color: Color(0xFF9A5B00),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    widget.de
                        ? 'Dieses Modul ist für Fahrer noch nicht '
                              'freigeschaltet. In der DA Academy erscheint es '
                              'als „Kommt bald"; es entstehen daher noch keine '
                              'neuen Nachweise.'
                        : 'This module has not been released to drivers yet. '
                              'It shows as "Coming soon" in the DA Academy, so '
                              'no new records are being created.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: Color(0xFF9A5B00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _stat(
              privacyCameraText(_lang, 'admin_count_ack'),
              data.count(_AckStatus.acknowledged),
              const Color(0xFF16704F),
              const Color(0xFFE4F5EC),
            ),
            // „Nicht bestätigt" kann nur noch aus Bestandsdaten stammen —
            // der Fahrer-Flow erzeugt diesen Ausgang nicht mehr. Deshalb
            // nur einblenden, wenn es solche Datensätze überhaupt gibt.
            if (data.count(_AckStatus.declined) > 0)
              _stat(
                privacyCameraText(_lang, 'admin_count_declined'),
                data.count(_AckStatus.declined),
                _kSub,
                const Color(0xFFF1F3F5),
              ),
            _stat(
              privacyCameraText(_lang, 'admin_count_open'),
              data.count(_AckStatus.open) + data.count(_AckStatus.outdated),
              const Color(0xFF9A5B00),
              const Color(0xFFFFF3E0),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Verweigerung ist kein Fehlerfall — steht bewusst als Hinweis
        // über der Liste, damit sie nicht als Rückstand gelesen wird.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kBorder),
          ),
          child: Text(
            privacyCameraText(_lang, 'admin_hint_no_gate'),
            style: const TextStyle(fontSize: 12, height: 1.45, color: _kMuted),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (v) => setState(() => _query = v.trim()),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.search_rounded, size: 19),
            hintText: privacyCameraText(_lang, 'admin_search'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              privacyCameraText(_lang, 'admin_empty_drivers'),
              style: const TextStyle(color: _kMuted, fontSize: 13.5),
            ),
          )
        else
          for (final row in rows) _ackTile(row, data),
      ],
    );
  }

  Widget _header(_SectionData data) {
    final doc = data.bundle.bindingDocument;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.photo_camera_outlined,
            size: 21,
            color: _kAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                privacyCameraText(_lang, 'admin_title'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                privacyCameraText(_lang, 'admin_subtitle'),
                style: const TextStyle(fontSize: 13, height: 1.4, color: _kSub),
              ),
              const SizedBox(height: 6),
              Text(
                privacyCameraText(
                  _lang,
                  'admin_detail_version',
                  vars: {
                    'version': doc.ref.version,
                    'hash': doc.contentSha256.substring(0, 12),
                  },
                ),
                style: const TextStyle(fontSize: 11.5, color: _kMuted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _reload,
          icon: const Icon(Icons.refresh_rounded, size: 20),
          color: _kMuted,
          tooltip: privacyCameraText(_lang, 'admin_refresh'),
        ),
      ],
    );
  }

  Widget _stat(String label, int value, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: fg,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ],
    ),
  );

  Widget _ackTile(_AckRow row, _SectionData data) {
    final ack = row.ack;
    late final String statusLabel;
    late final Color fg;
    late final Color bg;
    switch (row.status) {
      case _AckStatus.acknowledged:
        statusLabel = privacyCameraText(_lang, 'admin_status_ack');
        fg = const Color(0xFF16704F);
        bg = const Color(0xFFE4F5EC);
        break;
      case _AckStatus.declined:
        statusLabel = privacyCameraText(_lang, 'admin_status_declined');
        fg = _kSub;
        bg = const Color(0xFFF1F3F5);
        break;
      case _AckStatus.outdated:
        statusLabel = privacyCameraText(_lang, 'admin_status_outdated');
        fg = const Color(0xFF9A5B00);
        bg = const Color(0xFFFFF3E0);
        break;
      case _AckStatus.open:
        statusLabel = privacyCameraText(_lang, 'admin_status_open');
        fg = _kMuted;
        bg = const Color(0xFFF1F3F5);
        break;
    }

    final details = <String>[];
    if (ack != null) {
      details.add(
        privacyCameraText(
          _lang,
          'admin_detail_version',
          vars: {
            'version': ack.documentVersion,
            'hash': ack.documentContentSha256.length >= 12
                ? ack.documentContentSha256.substring(0, 12)
                : ack.documentContentSha256,
          },
        ),
      );
      if (ack.statementLocale.isNotEmpty) {
        details.add(
          privacyCameraText(
            _lang,
            'admin_detail_language',
            vars: {'lang': ack.statementLocale.toUpperCase()},
          ),
        );
      }
      details.add(
        privacyCameraText(
          _lang,
          'admin_detail_read',
          vars: {'seconds': '${ack.documentReadSeconds}'},
        ),
      );
      if (ack.documentScrolledToEnd) {
        details.add(privacyCameraText(_lang, 'admin_detail_scrolled'));
      }
      details.add(
        (ack.signaturePngBase64 ?? '').isNotEmpty
            ? privacyCameraText(_lang, 'admin_detail_signature')
            : privacyCameraText(_lang, 'admin_detail_no_signature'),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: _kText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      row.employeeNumber.isEmpty
                          ? row.transporterId
                          : '${row.transporterId} · ${row.employeeNumber}',
                      style: const TextStyle(fontSize: 12, color: _kMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ack == null
                      ? statusLabel
                      : '$statusLabel · ${_fmt(ack.occurredAt)}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              details.join(' · '),
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.45,
                color: _kMuted,
              ),
            ),
          ],
          // Vermerk bei Verweigerung — verbindlicher Wortlaut aus Spec §7.
          if (ack != null && !ack.isAcknowledged) ...[
            const SizedBox(height: 9),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    privacyCameraText(_lang, 'admin_decline_note'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _kMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.bundle.bindingAck.declineNoteFor(
                      _fmt(ack.occurredAt),
                    ),
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: _kSub,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
