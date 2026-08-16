import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

/// Private, password-gated owner dashboard: how many CoDriver companies use
/// the app and for how long. Reachable only via the unlisted `/insights`
/// route; the data comes from the `getOwnerUsageStats` callable, which is
/// itself locked to owner UIDs + the same passphrase — so this page can
/// never leak data even if the URL is found.
class OwnerInsightsPage extends StatefulWidget {
  const OwnerInsightsPage({super.key});

  @override
  State<OwnerInsightsPage> createState() => _OwnerInsightsPageState();
}

class _OwnerInsightsPageState extends State<OwnerInsightsPage> {
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _stats;

  static const _bg = Color(0xFF0B1220);
  static const _card = Color(0xFF141C2B);
  static const _line = Color(0xFF243146);
  static const _green = Color(0xFF1D7F5A);
  static const _muted = Color(0xFF8B97A8);

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final pass = _passCtrl.text.trim();
    if (pass.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('getOwnerUsageStats');
      final resp = await callable.call<Map<String, dynamic>>({
        'passphrase': pass,
      });
      setState(() {
        _stats = Map<String, dynamic>.from(resp.data);
        _loading = false;
      });
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _loading = false;
        _error = switch (e.code) {
          'unauthenticated' =>
            'Bitte zuerst mit deinem Admin-Konto einloggen, dann /insights öffnen.',
          'permission-denied' =>
            'Falsches Passwort oder kein Zugriff für dieses Konto.',
          _ => 'Fehler: ${e.message ?? e.code}',
        };
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Fehler: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: _stats == null ? _buildGate() : _buildDashboard(),
          ),
        ),
      ),
    );
  }

  // ── Password gate ──
  Widget _buildGate() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: _green, size: 24),
              const SizedBox(width: 10),
              const Text(
                'CoDriver Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            Localizations.localeOf(context).languageCode == 'de'
                ? 'Privat · passwortgeschützt'
                : 'Private · password protected',
            style: const TextStyle(color: _muted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              hintText: Localizations.localeOf(context).languageCode == 'de'
                  ? 'Passwort'
                  : 'Password',
              hintStyle: const TextStyle(color: _muted),
              filled: true,
              fillColor: const Color(0xFF0E1524),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: _muted),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _green),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xFFF87171), fontSize: 13),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _load,
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      Localizations.localeOf(context).languageCode == 'de'
                          ? 'Öffnen'
                          : 'Open',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dashboard ──
  Widget _buildDashboard() {
    final stats = _stats!;
    final totals = Map<String, dynamic>.from(stats['totals'] ?? {});
    final companies = (stats['companies'] as List?) ?? const [];
    final now = DateTime.now();

    int daysSince(int? ms) {
      if (ms == null) return 0;
      return now.difference(DateTime.fromMillisecondsSinceEpoch(ms)).inDays;
    }

    String usingFor(int days) {
      if (days >= 365) {
        final y = (days / 365).floor();
        final m = ((days % 365) / 30).floor();
        return m > 0 ? '$y J $m M' : '$y J';
      }
      if (days >= 30) return '${(days / 30).floor()} Mon';
      return '$days T';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.insights_rounded, color: _green, size: 26),
            const SizedBox(width: 10),
            const Text(
              'CoDriver Insights',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh_rounded, color: _muted),
              tooltip: 'Aktualisieren',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Stand ${_fmtDateTime(now)}',
          style: const TextStyle(color: _muted, fontSize: 12),
        ),
        const SizedBox(height: 20),
        // KPI tiles.
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _kpi('Firmen (DSPs)', '${totals['companies'] ?? 0}',
                Icons.apartment_rounded, _green),
            _kpi('Dispatcher', '${totals['dispatchers'] ?? 0}',
                Icons.headset_mic_rounded, const Color(0xFF0A84FF)),
            _kpi('Fahrer', '${totals['drivers'] ?? 0}',
                Icons.person_rounded, const Color(0xFFE9741A)),
            _kpi('Konten gesamt', '${totals['total'] ?? 0}',
                Icons.groups_rounded, const Color(0xFF8B5CF6)),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'Firmen — seit wann dabei',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _line),
          ),
          child: Column(
            children: [
              _rowHeader(),
              for (var i = 0; i < companies.length; i++)
                _companyRow(
                  Map<String, dynamic>.from(companies[i]),
                  daysSince,
                  usingFor,
                  zebra: i.isOdd,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color color) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: _muted, fontSize: 12.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: const [
          Expanded(flex: 4, child: _HeadCell('Firma')),
          Expanded(flex: 2, child: _HeadCell('Seit')),
          Expanded(flex: 2, child: _HeadCell('Dauer')),
          Expanded(flex: 2, child: _HeadCell('Fahrer')),
          Expanded(flex: 2, child: _HeadCell('Status')),
        ],
      ),
    );
  }

  Widget _companyRow(
    Map<String, dynamic> c,
    int Function(int?) daysSince,
    String Function(int) usingFor, {
    required bool zebra,
  }) {
    final createdMs = (c['createdAtMillis'] as num?)?.toInt();
    final days = daysSince(createdMs);
    final company = (c['company'] as String?)?.trim();
    final email = (c['email'] as String?)?.trim() ?? '';
    final plan = (c['plan'] as String?)?.trim() ?? '';
    final trialEndMs = (c['trialEndsAtMillis'] as num?)?.toInt();
    final driverCount = (c['driverCount'] as num?)?.toInt() ?? 0;

    final title = (company != null && company.isNotEmpty) ? company : email;

    // Status: paid / trial active / trial expired / —
    String status;
    Color statusColor;
    if (plan.isEmpty || plan == 'paid' || plan == 'active') {
      status = plan.isEmpty ? 'Aktiv' : 'Bezahlt';
      statusColor = _green;
    } else if (trialEndMs != null &&
        DateTime.fromMillisecondsSinceEpoch(trialEndMs)
            .isBefore(DateTime.now())) {
      status = 'Trial abgelaufen';
      statusColor = const Color(0xFFF87171);
    } else {
      status = 'Trial';
      statusColor = const Color(0xFFE9741A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: zebra ? const Color(0xFF101826) : Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (company != null && company.isNotEmpty && email.isNotEmpty)
                  Text(
                    email,
                    style: const TextStyle(color: _muted, fontSize: 11.5),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              createdMs == null
                  ? '—'
                  : _fmtDate(DateTime.fromMillisecondsSinceEpoch(createdMs)),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              createdMs == null ? '—' : usingFor(days),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$driverCount',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  static String _fmtDateTime(DateTime d) =>
      '${_fmtDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _HeadCell extends StatelessWidget {
  final String text;
  const _HeadCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8B97A8),
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }
}
