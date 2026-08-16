import 'package:flutter/material.dart';

import '../services/incident_reports.dart';

/// Kennzahl-Chip „Unfälle: N" — zeigt die Anzahl der **Fahrzeug**-Vorfälle
/// eines Fahrers (Match über `driverTransporterId`) bzw. eines Fahrzeugs
/// (Match über `plateKey`).
///
/// Die Zahl kommt aus einer Firestore-`count()`-Aggregation; es werden
/// keine Dokumente übertragen. Das Ergebnis wird gecached und nur neu
/// geladen, wenn sich Scope oder Schlüssel ändern.
///
/// Genutzt im Drivers Hub (Fahrer-Detail) und im Fleet Hub
/// (Fahrzeug-Detail), damit beide Hubs dieselbe Zahl zeigen wie das
/// Incident-Center.
class IncidentCountChip extends StatefulWidget {
  /// Vorfälle eines Fahrers (Transporter-ID).
  const IncidentCountChip.driver({
    super.key,
    required this.dspUid,
    required String transporterId,
    this.onTap,
    this.dense = false,
  })  : _matchKey = transporterId,
        _byPlate = false;

  /// Vorfälle eines Fahrzeugs (Kennzeichen in beliebiger Schreibweise).
  const IncidentCountChip.vehicle({
    super.key,
    required this.dspUid,
    required String plate,
    this.onTap,
    this.dense = false,
  })  : _matchKey = plate,
        _byPlate = true;

  final String? dspUid;
  final String _matchKey;
  final bool _byPlate;

  /// Optional: Sprung ins Incident-Center.
  final VoidCallback? onTap;

  /// Kompaktere Variante für dichte Kopfzeilen.
  final bool dense;

  @override
  State<IncidentCountChip> createState() => _IncidentCountChipState();
}

class _IncidentCountChipState extends State<IncidentCountChip> {
  static const Color _idleBg = Color(0xFFF3F4F6);
  static const Color _idleFg = Color(0xFF374151);
  static const Color _idleBorder = Color(0xFFE5E7EB);
  static const Color _warnBg = Color(0xFFFEE2E2);
  static const Color _warnFg = Color(0xFF991B1B);
  static const Color _warnBorder = Color(0xFFFECACA);

  Future<int>? _future;
  String _cacheKey = '';

  @override
  void initState() {
    super.initState();
    _ensureFuture();
  }

  @override
  void didUpdateWidget(covariant IncidentCountChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureFuture();
  }

  void _ensureFuture() {
    final uid = (widget.dspUid ?? '').trim();
    final key = widget._byPlate
        ? plateKeyOf(widget._matchKey)
        : transporterIdOf(widget._matchKey);
    final cacheKey = '$uid|${widget._byPlate}|$key';
    if (cacheKey == _cacheKey && _future != null) return;
    _cacheKey = cacheKey;
    if (uid.isEmpty || key.isEmpty) {
      _future = Future<int>.value(0);
      return;
    }
    _future = widget._byPlate
        ? countVehicleIncidentsForPlate(dspUid: uid, plate: widget._matchKey)
        : countVehicleIncidentsForDriver(
            dspUid: uid,
            transporterId: widget._matchKey,
          );
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final label = de ? 'Unfälle' : 'Accidents';

    return FutureBuilder<int>(
      future: _future,
      builder: (context, snap) {
        // Kein Spinner für eine einzelne Zahl — solange geladen wird,
        // steht ein neutrales „—" im Chip, damit nichts springt.
        final loading = snap.connectionState == ConnectionState.waiting;
        final failed = snap.hasError;
        final count = snap.data ?? 0;
        final warn = !loading && !failed && count > 0;

        // Laden und Fehler zeigen beide „—"; die verschachtelte
        // Fallunterscheidung wäre eine Verzweigung ohne eigenes Ergebnis.
        final value = (loading || failed) ? '—' : '$count';
        final chip = Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.dense ? 10 : 12,
            vertical: widget.dense ? 4 : 8,
          ),
          decoration: BoxDecoration(
            color: warn ? _warnBg : _idleBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: warn ? _warnBorder : _idleBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.car_crash_outlined,
                size: widget.dense ? 13 : 14,
                color: warn ? _warnFg : _idleFg,
              ),
              const SizedBox(width: 8),
              Text(
                '$label: $value',
                style: TextStyle(
                  fontSize: widget.dense ? 11 : 12,
                  fontWeight: FontWeight.w700,
                  color: warn ? _warnFg : _idleFg,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );

        if (widget.onTap == null) return chip;
        return Semantics(
          button: true,
          label: '$label $value',
          child: Tooltip(
            message: de
                ? 'Im Incident-Center öffnen'
                : 'Open in the incident center',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(999),
                // Tap-Ziel auf 44 pt aufziehen, ohne die Pille zu
                // vergrößern. Center mit widthFactor statt `alignment:`,
                // damit der Chip in gestreckten Layouts nicht auf volle
                // Breite aufgeht.
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Center(widthFactor: 1, child: chip),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
