#!/usr/bin/env python3
"""Strukturvergleich der Datenschutz-Schulungs-Übersetzungen gegen die
deutsche Master-Fassung.

Vergleicht je Sprache:
  content: Abfolge der Block-Typen, id:-Werte, CalloutTone-Werte
  quiz:    Abfolge der moduleId- und correctIndex-Werte, Optionszahl
"""
import re
import sys

BASE = 'lib/data/safety_training'
LANGS = ['en', 'sq', 'hu', 'ro', 'hr', 'tr', 'ru', 'bg', 'ar']

BLOCK_TOKENS = re.compile(
    r'SafetyChapterContent\(|SafetySlide\(|ParagraphBlock\(|BulletsBlock\(|'
    r'CalloutBlock\(|DoDontBlock\(|TableBlock\(|RevealBlock\(|'
    r'StepsBlock\(|FactsBlock\(|'
    r"ChecklistBlock\(|id: '[^']*'|tone: CalloutTone\.\w+")


def content_sig(path):
    src = open(path).read()
    return BLOCK_TOKENS.findall(src)


def quiz_sig(path):
    src = open(path).read()
    module_ids = re.findall(r"moduleId: '([^']*)'", src)
    correct = re.findall(r'correctIndex: (\d+)', src)
    questions = src.count('DrivingQuestion(')
    return module_ids, correct, questions


de_content = content_sig(f'{BASE}/privacy_content_de.dart')
de_quiz = quiz_sig(f'{BASE}/privacy_quiz_de.dart')

ok = True
for lang in LANGS:
    try:
        c = content_sig(f'{BASE}/privacy_content_{lang}.dart')
        q = quiz_sig(f'{BASE}/privacy_quiz_{lang}.dart')
    except FileNotFoundError as e:
        print(f'{lang}: FEHLT — {e.filename}')
        ok = False
        continue
    problems = []
    if c != de_content:
        problems.append(f'content-Struktur weicht ab '
                        f'({len(c)} vs {len(de_content)} Tokens)')
        for i, (a, b) in enumerate(zip(de_content, c)):
            if a != b:
                problems.append(f'  erster Unterschied bei Token {i}: '
                                f'de={a!r} vs {b!r}')
                break
    if q[0] != de_quiz[0]:
        problems.append(f'quiz moduleIds weichen ab: {q[0]} vs {de_quiz[0]}')
    if q[1] != de_quiz[1]:
        problems.append(f'quiz correctIndex weicht ab: {q[1]} vs {de_quiz[1]}')
    if q[2] != de_quiz[2]:
        problems.append(f'quiz Fragenzahl: {q[2]} vs {de_quiz[2]}')
    if problems:
        ok = False
        print(f'{lang}: PROBLEME')
        for p in problems:
            print(f'  {p}')
    else:
        print(f'{lang}: OK ({q[2]} Fragen, Struktur identisch)')

sys.exit(0 if ok else 1)
