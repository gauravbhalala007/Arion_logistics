// lib/widgets/vacation_pool_lines.dart
//
// Gemeinsame Textbausteine + kompakte Anzeige der Urlaubs-Töpfe.
//
// Admin-Seiten (Drivers Hub, Detailseite, „DA Balance") verwenden das
// hier; die Fahrer-App baut ihre eigenen Kacheln, greift aber auf
// [vacationPoolLabel] zurück, damit die Topf-Namen überall gleich heißen.

import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../utils/vacation_pools.dart';

/// Übersetzter Topf-Name. Fällt auf DE/EN zurück, solange eine Sprache
/// den Schlüssel (noch) nicht kennt.
String vacationPoolLabel(BuildContext context, String poolKey) {
  final t = AppLocalizations.of(context);
  switch (poolKey) {
    case VacationPoolKeys.statutory:
      return t.t('vacation_pool_statutory');
    case VacationPoolKeys.additional:
      return t.t('vacation_pool_additional');
    default:
      return t.t('drivers_hub_field_remaining_vacation_days');
  }
}

/// „Gesetzlich: 14 von 20 · verfällt 31.03.2027"
String vacationPoolSummary(BuildContext context, VacationPoolSlice pool) {
  final t = AppLocalizations.of(context);
  final base = '${vacationPoolLabel(context, pool.key)}: '
      '${formatVacationDays(pool.remaining)} '
      '${t.t('driver_absence_of_word')} '
      '${formatVacationDays(pool.entitlement)}';
  final expiry = pool.expiresOn;
  if (expiry == null) return base;
  return '$base · ${t.tf('vacation_pool_expires_on', {
        'date': formatVacationDate(expiry),
      })}';
}

/// Kompakte Auflistung der offenen Töpfe unter einer Resturlaubs-Zeile.
/// Rendert nichts, solange kein Topf-Modus aktiv ist.
class VacationPoolLines extends StatelessWidget {
  const VacationPoolLines({
    super.key,
    required this.balance,
    this.fontSize = 11.5,
    this.color = const Color(0xFF6B7280),
  });

  final VacationBalance balance;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (!balance.pooled || balance.pools.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final pool in balance.pools)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              vacationPoolSummary(context, pool),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
      ],
    );
  }
}
