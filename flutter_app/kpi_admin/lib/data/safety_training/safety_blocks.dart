// lib/data/safety_training/safety_blocks.dart
//
// Inhaltsmodell der Sicherheitsunterweisung.
//
// Statt eines langen Textes pro Kapitel besteht jede Seite aus typisierten
// Bausteinen (Absatz, Aufzählung, Merksatz, Zahlen-Kacheln, Tabelle,
// Richtig/Falsch, Schrittfolge). Die Seite entscheidet damit über ihre
// Struktur, das UI nur noch über das Aussehen — so bleibt der Aufbau der
// SVG-Vorlage erhalten (mehrere Folien je Thema) und die Übersetzungen
// müssen keine Formatierung mittragen.

import 'package:flutter/foundation.dart';

/// Farbliche Bedeutung eines Merksatzes/Hinweises.
enum CalloutTone {
  /// Neutrale Merkregel (grün).
  key,

  /// Warnung / häufiger Fehler (bernstein).
  warning,

  /// Gefahr / absolutes Verbot (rot).
  danger,

  /// Rechtlicher Hinweis (blaugrau).
  law,
}

@immutable
sealed class SafetyBlock {
  const SafetyBlock();
}

/// Fließtext-Absatz.
@immutable
class ParagraphBlock extends SafetyBlock {
  final String text;
  const ParagraphBlock(this.text);
}

/// Zwischenüberschrift innerhalb einer Seite.
@immutable
class SubheadBlock extends SafetyBlock {
  final String text;
  const SubheadBlock(this.text);
}

/// Aufzählung mit Häkchen-Marker.
@immutable
class BulletsBlock extends SafetyBlock {
  final List<String> items;
  const BulletsBlock(this.items);
}

/// Nummerierte Schrittfolge (z. B. Notfallplan, Löscher bedienen).
@immutable
class StepsBlock extends SafetyBlock {
  final List<String> steps;

  /// Optionale Startnummer (Standard 1).
  final int startAt;
  const StepsBlock(this.steps, {this.startAt = 1});
}

/// Hervorgehobener Merksatz / Warnung.
@immutable
class CalloutBlock extends SafetyBlock {
  final CalloutTone tone;
  final String title;
  final String text;
  const CalloutBlock({
    required this.tone,
    required this.title,
    required this.text,
  });
}

/// Große Zahl mit Beschriftung (z. B. „112 — Notruf").
@immutable
class FactItem {
  final String value;
  final String label;
  const FactItem(this.value, this.label);
}

/// Reihe aus Zahlen-Kacheln.
@immutable
class FactsBlock extends SafetyBlock {
  final List<FactItem> facts;
  const FactsBlock(this.facts);
}

/// Kompakte Tabelle (z. B. Schutzklassen S1–S5).
@immutable
class TableBlock extends SafetyBlock {
  final List<String> headers;
  final List<List<String>> rows;
  const TableBlock({required this.headers, required this.rows});
}

/// Gegenüberstellung richtig/falsch.
@immutable
class DoDontBlock extends SafetyBlock {
  final String doTitle;
  final List<String> dos;
  final String dontTitle;
  final List<String> donts;
  const DoDontBlock({
    required this.doTitle,
    required this.dos,
    required this.dontTitle,
    required this.donts,
  });
}

/// Ein bebilderter Schritt: eigene Illustration + Titel + Bildunterschrift.
@immutable
class IllustratedStep {
  final String asset;
  final String title;

  /// Untertitel unter dem Bild — trägt die eigentliche Aussage und wird
  /// mit übersetzt, damit die Bildfolge in jeder Sprache funktioniert.
  final String caption;
  const IllustratedStep({
    required this.asset,
    required this.title,
    required this.caption,
  });
}

/// Bebilderte Schritt-für-Schritt-Folge — ersetzt ein Erklärvideo:
/// funktioniert ohne Ton, ohne Netz und in jeder Sprache.
@immutable
class IllustratedStepsBlock extends SafetyBlock {
  final List<IllustratedStep> steps;
  const IllustratedStepsBlock(this.steps);
}

/// „Erst denken, dann sehen": Frage sichtbar, Antwort erst nach Tippen.
/// Entspricht `tapToReveal` aus dem Interaktionskatalog.
@immutable
class RevealBlock extends SafetyBlock {
  final String prompt;
  final String answer;
  const RevealBlock({required this.prompt, required this.answer});
}

/// Abhakbare Checkliste (`checklistToggle`) — der Fortschritt dient nur
/// der Selbstkontrolle und wird nicht gespeichert.
@immutable
class ChecklistBlock extends SafetyBlock {
  final String title;
  final List<String> items;
  const ChecklistBlock({required this.title, required this.items});
}

/// Verweis auf eine oder mehrere Betriebsanweisungen (per ID).
/// Wird als antippbare Karte gerendert und öffnet die Anweisung.
@immutable
class InstructionRefBlock extends SafetyBlock {
  final List<String> instructionIds;
  const InstructionRefBlock(this.instructionIds);
}

/// Eine Seite („Folie") innerhalb eines Kapitels.
@immutable
class SafetySlide {
  final String title;

  /// Nur auf der Auftaktseite eines Kapitels gesetzt.
  final String? asset;
  final List<SafetyBlock> blocks;
  const SafetySlide({
    required this.title,
    this.asset,
    required this.blocks,
  });
}

/// Ein Kapitel der Unterweisung mit mehreren Seiten.
@immutable
class SafetyChapterContent {
  final String id;
  final String title;

  /// Kurzer Teaser für die Kapitel-Übersicht.
  final String summary;
  final String asset;
  final List<SafetySlide> slides;
  const SafetyChapterContent({
    required this.id,
    required this.title,
    required this.summary,
    required this.asset,
    required this.slides,
  });
}
