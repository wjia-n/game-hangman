import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/services/settings_service.dart';

/// Player-name persistence: names live in ONE JSON string (never a
/// StringList — Android stores those as an unordered StringSet).
void main() {
  test('encode/decode round-trips the name', () {
    const name = 'Word Wizard';
    final raw = SchoolSettings.encodePlayerName(name);
    expect(SchoolSettings.decodePlayerName(raw), name);
  });

  test('decode tolerates whitespace-only and corrupt data', () {
    expect(SchoolSettings.decodePlayerName(
        SchoolSettings.encodePlayerName('   ')),
        SchoolSettings.defaultName);
    expect(SchoolSettings.decodePlayerName('not-json{{{'),
        SchoolSettings.defaultName);
    expect(SchoolSettings.decodePlayerName(null), SchoolSettings.defaultName);
  });

  test('decode accepts the legacy 1-element list shape', () {
    expect(SchoolSettings.decodePlayerName('["Ruby"]'), 'Ruby');
  });

  test('decode trims surrounding whitespace', () {
    expect(
        SchoolSettings.decodePlayerName(
            SchoolSettings.encodePlayerName('  Ace  ')),
        'Ace');
  });
}
