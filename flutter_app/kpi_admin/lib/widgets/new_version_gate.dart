// lib/widgets/new_version_gate.dart
//
// Erzwingt nach einem Deployment einen Neustart der Web-App: Beim Start
// wird /version.json (per Predeploy-Hook bei jedem Hosting-Deploy neu
// gestempelt, ausgeliefert mit no-cache) gemerkt; alle 5 Minuten und bei
// jedem Tab-Fokus wird neu geprüft. Weicht die Build-ID ab, erscheint ein
// nicht wegklickbares Popup mit „Jetzt aktualisieren" → harter Reload.
//
// Eingehängt in Admin-, Dispatcher- und Fahrer-Shell — bewusst NICHT in
// den öffentlichen Seiten (Bewerbungsformular, Plan-Links): dort wäre ein
// erzwungener Reload mitten im Ausfüllen feindselig.

import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // Web-App: location.reload + Fokus-Event

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewVersionGate extends StatefulWidget {
  const NewVersionGate({super.key, required this.child});

  final Widget child;

  @override
  State<NewVersionGate> createState() => _NewVersionGateState();
}

class _NewVersionGateState extends State<NewVersionGate> {
  String? _startBuildId;
  Timer? _timer;
  StreamSubscription<html.Event>? _focusSub;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _fetchBuildId().then((id) => _startBuildId = id);
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _check());
    _focusSub = html.window.onFocus.listen((_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusSub?.cancel();
    super.dispose();
  }

  Future<String?> _fetchBuildId() async {
    try {
      // Cache-Buster zusätzlich zum no-cache-Header — doppelt hält besser.
      final uri = Uri.parse(
        '/build_version.json?ts=${DateTime.now().millisecondsSinceEpoch}',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      final id = (data is Map ? data['buildId'] : null)?.toString() ?? '';
      return id.isEmpty ? null : id;
    } catch (_) {
      return null;
    }
  }

  Future<void> _check() async {
    if (_dialogShown) return;
    final current = await _fetchBuildId();
    if (current == null) return;
    // Ältere Deployments ohne version.json: ersten gelieferten Wert als
    // Startwert übernehmen statt sofort ein Popup zu zeigen.
    if (_startBuildId == null) {
      _startBuildId = current;
      return;
    }
    if (current == _startBuildId || !mounted) return;
    _dialogShown = true;
    final de = Localizations.localeOf(context).languageCode == 'de';
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.system_update_alt, color: Color(0xFF0D8A60)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(de ? 'Neue Version verfügbar' : 'Update available'),
              ),
            ],
          ),
          content: Text(
            de
                ? 'CoDriver wurde aktualisiert. Bitte lade die App neu, um '
                      'die neueste Version zu verwenden — ungespeicherte '
                      'Eingaben gehen dabei verloren.'
                : 'CoDriver has been updated. Please reload the app to get '
                      'the latest version — unsaved input will be lost.',
          ),
          actions: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D8A60),
              ),
              onPressed: () => html.window.location.reload(),
              icon: const Icon(Icons.refresh),
              label: Text(de ? 'Jetzt aktualisieren' : 'Reload now'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
