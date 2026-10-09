import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'word_bank.dart';

/// Hangman play mode: relaxed (no clock) or timed (per-word countdown).
enum HangMode { relaxed, timed }

/// Phases owned entirely by the engine. The UI only renders.
/// [dealing] = picking/showing the next word (input locked, brief).
/// [guessing] = letters accepted.
/// [letterReveal] = a correct guess is animating in (input locked).
/// [wordSettle] = word solved/failed, result showing (input locked).
/// [runOver] = the run finished.
enum HangPhase { dealing, guessing, letterReveal, wordSettle, runOver }

enum HangEvent {
  gameStart,
  letterGood,
  letterBad,
  invalid,
  wordSolved,
  wordFailed,
  timeUp,
  tickWarn, // <=10s left in timed mode
  runOver,
}

/// Hangman engine: deterministic rules, engine-owned phases and timers,
/// watchdog recovery. The UI never advances game state on its own, so
/// stuck states are impossible by construction.
///
/// Results never pop instantly: correct letters go through [letterReveal],
/// word results go through [wordSettle], and the run ends through [runOver] —
/// the UI animates each of these before anything advances.
class HangmanEngine extends ChangeNotifier {
  final String playerName;
  final HangDifficulty difficulty;
  final HangMode mode;
  final int wordsPerRun;
  final Random _rand;

  late List<HangWord> _run;
  int wordIndex = 0;
  HangPhase phase = HangPhase.dealing;

  final Set<String> guessed = {};
  int wrong = 0;

  /// Wrong-guess budget for the current word — set by difficulty tier
  /// (RULES.md §2): Easy 8, Medium 6, Hard 5.
  int get maxWrong => difficulty.maxWrong;

  bool solved = false;
  bool failed = false;
  bool timedOut = false;
  int secondsLeft = 0;

  /// Bumps on every correct guess so the UI can stagger-animate the newly
  /// revealed letters instead of popping them in.
  int revealToken = 0;
  String lastLetter = '';
  bool lastWasGood = false;

  int solvedCount = 0;
  int streak = 0;
  int bestStreakRun = 0;
  bool paused = false;

  Timer? _timer; // single phase-transition timer
  Timer? _tick; // timed-mode countdown
  Timer? _watchdog; // stuck-state recovery
  bool _disposed = false;

  /// Test hook: force the word at this run index (consumed after use).
  int? forcedWord;

  /// UI hook for sounds / haptics. Set by the screen.
  void Function(HangEvent event)? onEvent;

  HangmanEngine({
    required this.playerName,
    required this.difficulty,
    required this.mode,
    required this.wordsPerRun,
    Random? rand,
  }) : _rand = rand ?? Random() {
    _pickRun();
    _watchdog = Timer.periodic(const Duration(seconds: 3), (_) => _recover());
    onEvent?.call(HangEvent.gameStart);
    _arm(const Duration(milliseconds: 800), _beginWord);
  }

  HangWord get word => _run[wordIndex];
  bool get canGuess => phase == HangPhase.guessing && !paused && !_disposed;
  bool get over => phase == HangPhase.runOver;

  /// Letters shown face-up (guessed or revealed at word end).
  bool letterShown(String l) =>
      guessed.contains(l) || solved || failed;

  void _pickRun() {
    final pool = WordBank.forDifficulty(difficulty);
    final n = wordsPerRun.clamp(1, pool.length);
    final copy = List<HangWord>.of(pool)..shuffle(_rand);
    _run = copy.take(n).toList();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _tick?.cancel();
    _watchdog?.cancel();
    super.dispose();
  }

  void _arm(Duration d, void Function() fn) {
    if (_disposed || paused) return;
    _timer?.cancel();
    _timer = Timer(d, () {
      _timer = null;
      if (!_disposed && !paused) fn();
    });
  }

  /// Pause: freeze phase timer + countdown. Resume re-arms via [_recover].
  void setPaused(bool v) {
    if (paused == v || _disposed) return;
    paused = v;
    if (v) {
      _timer?.cancel();
      _timer = null;
      _tick?.cancel();
      _tick = null;
    } else {
      _recover();
    }
    notifyListeners();
  }

  /// Watchdog: if a phase has no live timer driving it forward, recover.
  /// Respects [paused].
  void _recover() {
    if (_disposed || paused || over || _timer != null) return;
    switch (phase) {
      case HangPhase.dealing:
        _arm(const Duration(milliseconds: 600), _beginWord);
      case HangPhase.guessing:
        if (mode == HangMode.timed && _tick == null) _startTick();
      case HangPhase.letterReveal:
        _afterReveal();
      case HangPhase.wordSettle:
        _nextWord();
      case HangPhase.runOver:
        break;
    }
  }

  void _beginWord() {
    if (_disposed || over) return;
    if (forcedWord != null) {
      final pool = WordBank.forDifficulty(difficulty);
      final i = forcedWord!.clamp(0, pool.length - 1);
      _run[wordIndex] = pool[i];
      forcedWord = null;
    }
    guessed.clear();
    wrong = 0;
    solved = false;
    failed = false;
    timedOut = false;
    lastLetter = '';
    revealToken = 0;
    if (mode == HangMode.timed) {
      secondsLeft = difficulty.timeLimitSecs;
      _startTick();
    }
    phase = HangPhase.guessing;
    notifyListeners();
  }

  void _startTick() {
    if (_disposed || paused) return;
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed || paused || phase != HangPhase.guessing) return;
      secondsLeft--;
      if (secondsLeft <= 0) {
        secondsLeft = 0;
        timedOut = true;
        onEvent?.call(HangEvent.timeUp);
        _failWord();
      } else {
        if (secondsLeft <= 10) onEvent?.call(HangEvent.tickWarn);
        notifyListeners();
      }
    });
  }

  void _stopTick() {
    _tick?.cancel();
    _tick = null;
  }

  /// Player taps a letter. Guarded: guessing phase only, fresh letters only.
  void guessLetter(String raw) {
    final l = raw.toUpperCase();
    if (!canGuess || l.length != 1 || !_isLetter(l) || guessed.contains(l)) {
      onEvent?.call(HangEvent.invalid);
      return;
    }
    guessed.add(l);
    lastLetter = l;
    if (word.text.contains(l)) {
      lastWasGood = true;
      revealToken++; // UI stagger-animates the new letters
      phase = HangPhase.letterReveal;
      onEvent?.call(HangEvent.letterGood);
      notifyListeners();
      _arm(const Duration(milliseconds: 700), _afterReveal);
    } else {
      lastWasGood = false;
      wrong++;
      onEvent?.call(HangEvent.letterBad);
      notifyListeners();
      if (wrong >= maxWrong) _failWord();
    }
  }

  static bool _isLetter(String s) {
    final c = s.codeUnitAt(0);
    return c >= 65 && c <= 90;
  }

  void _afterReveal() {
    if (_disposed || over || phase != HangPhase.letterReveal) return;
    if (_wordComplete()) {
      _solveWord();
    } else {
      phase = HangPhase.guessing;
      notifyListeners();
    }
  }

  bool _wordComplete() =>
      word.text.split('').every(guessed.contains);

  void _solveWord() {
    solved = true;
    solvedCount++;
    streak++;
    if (streak > bestStreakRun) bestStreakRun = streak;
    _stopTick();
    phase = HangPhase.wordSettle;
    onEvent?.call(HangEvent.wordSolved);
    notifyListeners();
    // Let the victory moment land before the next word deals.
    _arm(const Duration(milliseconds: 1600), _nextWord);
  }

  void _failWord() {
    if (over || phase == HangPhase.wordSettle) return;
    failed = true;
    streak = 0;
    _stopTick();
    phase = HangPhase.wordSettle;
    onEvent?.call(HangEvent.wordFailed);
    notifyListeners();
    // Reveal the answer briefly before dealing the next word.
    _arm(const Duration(milliseconds: 2000), _nextWord);
  }

  void _nextWord() {
    if (_disposed || over) return;
    if (wordIndex + 1 >= _run.length) {
      _finishRun();
      return;
    }
    wordIndex++;
    phase = HangPhase.dealing;
    notifyListeners();
    _arm(const Duration(milliseconds: 700), _beginWord);
  }

  void _finishRun() {
    phase = HangPhase.runOver;
    _stopTick();
    notifyListeners();
    onEvent?.call(HangEvent.runOver);
  }

  void restart() {
    _timer?.cancel();
    _stopTick();
    paused = false;
    wordIndex = 0;
    solvedCount = 0;
    streak = 0;
    bestStreakRun = 0;
    // Reset per-word state too, so the UI never shows the old word's
    // gallows/tiles during the dealing beat.
    guessed.clear();
    wrong = 0;
    solved = false;
    failed = false;
    timedOut = false;
    lastLetter = '';
    lastWasGood = false;
    revealToken = 0;
    phase = HangPhase.dealing;
    notifyListeners();
    onEvent?.call(HangEvent.gameStart);
    _arm(const Duration(milliseconds: 800), _beginWord);
  }
}
