// lib/widgets/new_version_gate.dart
//
// Meldet nach einem Deployment eine neue Version der Web-App: Beim Start
// wird /version.json (per Predeploy-Hook bei jedem Hosting-Deploy neu
// gestempelt, ausgeliefert mit no-cache) gemerkt; alle 5 Minuten und bei
// jedem Tab-Fokus wird neu geprüft. Weicht die Build-ID ab, erscheint —
// bewusst KEIN blockierendes Popup mehr (Kundenwunsch) — eine dezente
// Pille oben mittig; erst ein Klick darauf laedt neu.
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
  bool _updateAvailable = false;

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
    if (_updateAvailable) return;
    final current = await _fetchBuildId();
    if (current == null) return;
    // Ältere Deployments ohne version.json: ersten gelieferten Wert als
    // Startwert übernehmen statt sofort eine Meldung zu zeigen.
    if (_startBuildId == null) {
      _startBuildId = current;
      return;
    }
    if (current == _startBuildId || !mounted) return;
    setState(() => _updateAvailable = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_updateAvailable) return widget.child;
    final de = Localizations.localeOf(context).languageCode == 'de';

    // Dezente Pille oben mittig statt blockierendem Popup: die Arbeit
    // laeuft ungestoert weiter, aktualisiert wird erst beim Klick.
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                // Erst bestaetigen: der Reload wirft ungespeicherte
                // Eingaben weg — wer gerade mitten im Bearbeiten ist,
                // speichert erst und tippt dann erneut.
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        de ? 'Jetzt aktualisieren?' : 'Refresh now?',
                      ),
                      content: Text(
                        de
                            ? 'Ungespeicherte Eingaben gehen beim Neuladen '
                                'verloren. Wenn du gerade etwas bearbeitest, '
                                'speichere zuerst und tippe dann erneut auf '
                                'die Pille.'
                            : 'Unsaved input is lost on reload. If you are '
                                'editing something, save first and then tap '
                                'the pill again.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(
                            de ? 'Später' : 'Later',
                          ),
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0D8A60),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(
                            de ? 'Jetzt neu laden' : 'Reload now',
                          ),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) html.window.location.reload();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D8A60),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        de
                            ? 'Neue Version — zum Aktualisieren tippen'
                            : 'New version — tap to refresh',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
