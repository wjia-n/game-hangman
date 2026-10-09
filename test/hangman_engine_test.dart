import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/engine/hangman_engine.dart';
import 'package:hangman/engine/word_bank.dart';

/// RULES.md §13 test cases for the Hangman engine.
///
/// The engine owns its phases and timers; tests drive the public API and
/// wait out the (short) phase durations. `forcedWord` makes words
/// deterministic: the engine swaps in a known pool word at deal time.
HangmanEngine makeEngine({
  HangDifficulty difficulty = HangDifficulty.easy,
  HangMode mode = HangMode.relaxed,
  int wordsPerRun = 3,
}) {
  return HangmanEngine(
    playerName: 'Tester',
    difficulty: difficulty,
    mode: mode,
    wordsPerRun: wordsPerRun,
  );
}

/// Force the current word to a known pool word and wait for the deal.
Future<void> dealWord(HangmanEngine e, int poolIndex) async {
  e.forcedWord = poolIndex;
  await Future.delayed(const Duration(milliseconds: 950));
}

int poolIndexOf(HangDifficulty d, String text) {
  final pool = WordBank.forDifficulty(d);
  return pool.indexWhere((w) => w.text == text);
}

void main() {
  test('1. Correct guess reveals letters, phase stays open', () async {
    final e = makeEngine();
    addTearDown(e.dispose);
    await dealWord(e, poolIndexOf(HangDifficulty.easy, 'LION'));
    expect(e.phase, HangPhase.guessing);
    e.guessLetter('L');
    expect(e.guessed, contains('L'));
    expect(e.wrong, 0);
    await Future.delayed(const Duration(milliseconds: 900));
    expect(e.phase, HangPhase.guessing); // word not complete
    expect(e.solvedCount, 0);
  });

  test('2. Wrong guess draws a part', () async {
    final e = makeEngine();
    addTearDown(e.dispose);
    await dealWord(e, poolIndexOf(HangDifficulty.easy, 'LION'));
    e.guessLetter('Z');
    expect(e.wrong, 1);
    expect(e.phase, HangPhase.guessing);
  });

  test('3. Re-tapping a guessed letter is ignored', () async {
    final e = makeEngine();
    addTearDown(e.dispose);
    await dealWord(e, poolIndexOf(HangDifficulty.easy, 'LION'));
    e.guessLetter('Z');
    final wrongBefore = e.wrong;
    e.guessLetter('Z'); // invalid: no state change
    expect(e.wrong, wrongBefore);
    expect(e.phase, HangPhase.guessing);
  });

  test('4. The final allowed wrong guess fails the word, next word deals',
      () async {
    final e = makeEngine(); // Easy: 8 misses
    addTearDown(e.dispose);
    await dealWord(e, poolIndexOf(HangDifficulty.easy, 'LION'));
    for (final l in ['Z', 'X', 'Q', 'J', 'K', 'V', 'W', 'Y']) {
      e.guessLetter(l);
      await Future.delayed(const Duration(milliseconds: 60));
    }
    expect(e.wrong, 8);
    expect(e.failed, isTrue);
    expect(e.phase, HangPhase.wordSettle);
    await Future.delayed(const Duration(milliseconds: 3200));
    expect(e.wordIndex, 1); // next word dealt
    expect(e.phase, HangPhase.guessing);
  });

  test('4b. Miss budget follows the difficulty tier', () {
    expect(HangDifficulty.easy.maxWrong, 8);
    expect(HangDifficulty.medium.maxWrong, 6);
    expect(HangDifficulty.hard.maxWrong, 5);
    final e = makeEngine(difficulty: HangDifficulty.medium);
    addTearDown(e.dispose);
    expect(e.maxWrong, 6);
  });

  test('5. Solving the word scores and advances', () async {
    final e = makeEngine();
    addTearDown(e.dispose);
    await dealWord(e, poolIndexOf(HangDifficulty.easy, 'LION'));
    for (final l in ['L', 'I', 'O', 'N']) {
      e.guessLetter(l);
      await Future.delayed(const Duration(milliseconds: 900));
    }
    expect(e.solved, isTrue);
    expect(e.solvedCount, 1);
    expect(e.streak, 1);
    await Future.delayed(const Duration(milliseconds: 2600));
    expect(e.wordIndex, 1);
  });

  test('6. Streak resets on failure', () async {
    // Hard tier: 5 misses, so 5 wrong guesses fail the word.
    final e = makeEngine(
        difficulty: HangDifficulty.hard, wordsPerRun: 2);
    addTearDown(e.dispose);
    await dealWord(e, poolIndexOf(HangDifficulty.hard, 'CROCODILE'));
    for (final l in ['C', 'R', 'O', 'D', 'I', 'L', 'E']) {
      e.guessLetter(l);
      await Future.delayed(const Duration(milliseconds: 900));
    }
    expect(e.streak, 1);
    // Force the NEXT word before it deals (settle 1600ms + dealing 700ms).
    e.forcedWord = poolIndexOf(HangDifficulty.hard, 'BUTTERFLY');
    await Future.delayed(const Duration(milliseconds: 2600));
    expect(e.phase, HangPhase.guessing);
    expect(e.word.text, 'BUTTERFLY');
    for (final l in ['Z', 'X', 'Q', 'J', 'K']) {
      e.guessLetter(l);
      await Future.delayed(const Duration(milliseconds: 60));
    }
    expect(e.failed, isTrue);
    expect(e.streak, 0); // failure resets the streak
    expect(e.bestStreakRun, 1);
  });

  test('7. Timed mode: clock expiry fails the word', () async {
    final e = makeEngine(mode: HangMode.timed, wordsPerRun: 1);
    addTearDown(e.dispose);
    await dealWord(e, poolIndexOf(HangDifficulty.easy, 'LION'));
    expect(e.secondsLeft, greaterThan(0));
    // Fast-forward the clock to the edge.
    e.secondsLeft = 1;
    await Future.delayed(const Duration(milliseconds: 1400));
    expect(e.failed, isTrue);
    expect(e.timedOut, isTrue);
  });

  test('8. Run over after the last word', () async {
    final e = makeEngine(wordsPerRun: 1);
    addTearDown(e.dispose);
    await dealWord(e, poolIndexOf(HangDifficulty.easy, 'LION'));
    for (final l in ['L', 'I', 'O', 'N']) {
      e.guessLetter(l);
      await Future.delayed(const Duration(milliseconds: 900));
    }
    await Future.delayed(const Duration(milliseconds: 2600));
    expect(e.phase, HangPhase.runOver);
    expect(e.over, isTrue);
  });

  test('9. Restart resets the run', () async {
    final e = makeEngine(wordsPerRun: 1);
    addTearDown(e.dispose);
    await dealWord(e, poolIndexOf(HangDifficulty.easy, 'LION'));
    e.guessLetter('Z');
    e.restart();
    expect(e.wordIndex, 0);
    expect(e.solvedCount, 0);
    expect(e.streak, 0);
    expect(e.wrong, 0);
    await Future.delayed(const Duration(milliseconds: 950));
    expect(e.phase, HangPhase.guessing);
  });

  test('10. Pause freezes, resume continues', () async {
    final e = makeEngine();
    addTearDown(e.dispose);
    await dealWord(e, poolIndexOf(HangDifficulty.easy, 'LION'));
    e.guessLetter('L');
    e.setPaused(true);
    expect(e.canGuess, isFalse);
    e.guessLetter('I'); // locked while paused: ignored
    expect(e.guessed.contains('I'), isFalse);
    e.setPaused(false);
    await Future.delayed(const Duration(milliseconds: 900));
    expect(e.phase, HangPhase.guessing);
    e.guessLetter('I');
    expect(e.guessed, contains('I'));
  });

  test('11. Difficulty pools respect their length bands', () {
    for (final d in HangDifficulty.values) {
      final (lo, hi) = d.lengthBand;
      for (final w in WordBank.forDifficulty(d)) {
        expect(w.text.length, inInclusiveRange(lo, hi),
            reason: '${w.text} not in ${d.label} band');
      }
    }
  });
}
