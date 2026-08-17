// lib/utils/cyrillic_translit.dart
//
// Lateinische Umschrift für kyrillische Eingaben (z.B. bulgarische
// Bewerbungen): Das Recruiting-Team muss Namen/Adressen lesen können,
// auch wenn der Bewerber in Kyrillisch geantwortet hat.
//
// Basis ist das amtliche bulgarische Transliterationssystem (2009),
// ergänzt um die russischen/ukrainischen Zeichen, die im Bulgarischen
// nicht vorkommen (э, ы, ё, і, ї, є …), damit gemischte Eingaben nicht
// als Fragezeichen enden.

const Map<String, String> _map = {
  'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ж': 'zh',
  'з': 'z', 'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm', 'н': 'n',
  'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u', 'ф': 'f',
  'х': 'h', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh', 'щ': 'sht', 'ъ': 'a',
  'ь': 'y', 'ю': 'yu', 'я': 'ya',
  // Nicht-bulgarische kyrillische Zeichen (ru/uk/sr):
  'э': 'e', 'ы': 'y', 'ё': 'yo', 'і': 'i', 'ї': 'yi', 'є': 'ye',
  'ґ': 'g', 'ђ': 'dj', 'ј': 'j', 'љ': 'lj', 'њ': 'nj', 'ћ': 'c',
  'џ': 'dz',
};

final RegExp _cyrillic = RegExp(r'[Ѐ-ӿ]');

/// Enthält der Text kyrillische Zeichen?
bool hasCyrillic(String text) => _cyrillic.hasMatch(text);

/// Lateinische Umschrift; nicht-kyrillische Zeichen bleiben unverändert.
/// Großschreibung bleibt erhalten („Иван" → „Ivan").
String transliterateCyrillic(String text) {
  final out = StringBuffer();
  for (final rune in text.runes) {
    final ch = String.fromCharCode(rune);
    final lower = ch.toLowerCase();
    final mapped = _map[lower];
    if (mapped == null) {
      out.write(ch);
      continue;
    }
    if (ch != lower) {
      // Großbuchstabe: erstes Zeichen der Umschrift groß halten.
      out.write(
        mapped.length == 1
            ? mapped.toUpperCase()
            : mapped[0].toUpperCase() + mapped.substring(1),
      );
    } else {
      out.write(mapped);
    }
  }
  return out.toString();
}
