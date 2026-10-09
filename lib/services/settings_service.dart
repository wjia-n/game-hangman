import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/chalk_themes.dart';

/// Persisted settings + stats for Hangman. Survives app restarts.
///
/// Stores: audio toggles, player name, theme/chalk-style choices (incl.
/// custom theme colors), game-mode setup (difficulty, timed/relaxed,
/// words per run), Pro unlock state, and lifetime stats.
class SchoolSettings extends ChangeNotifier {
  static const _kMusic = 'hangman_music_on';
  static const _kSfx = 'hangman_sfx_on';
  static const _kVolume = 'hangman_volume';
  static const _kDifficulty = 'hangman_difficulty'; // 0 easy, 1 medium, 2 hard
  static const _kMode = 'hangman_mode'; // 0 relaxed, 1 timed
  static const _kWordsPerRun = 'hangman_words_per_run'; // 3, 6, 9
  static const _kName = 'hangman_player_name'; // legacy plain-string key
  static const _kNames = 'hangman_player_names'; // legacy unordered key
  /// Order-safe player-name storage: a single JSON string. Android's
  /// SharedPreferences stores StringLists as an unordered StringSet, so the
  /// old keys could scramble or mis-deliver the name. Never use a
  /// StringList for ordered data on Android.
  static const _kNameJson = 'hangman_player_names_json';
  static const _kTheme = 'hangman_theme_id';
  static const _kChalkStyle = 'hangman_chalk_style';
  static const _kGames = 'hangman_games_played';
  static const _kWordsSolved = 'hangman_words_solved';
  static const _kBestStreak = 'hangman_best_streak';
  static const _kRunsCleared = 'hangman_runs_cleared';
  static const _kIsPro = 'hangman_is_pro';
  static const _kCustomPrefix = 'hangman_custom_';

  static const defaultName = 'Word Wizard';

  /// Encode the player name as one JSON string (order-preserving).
  static String encodePlayerName(String name) => jsonEncode(name.trim());

  /// Decode the persisted name; falls back to the default on
  /// missing/corrupt data. Accepts a bare JSON string or a 1-element list
  /// (belt-and-suspenders for the old list shape).
  static String decodePlayerName(String? raw) {
    if (raw == null) return defaultName;
    try {
      final d = jsonDecode(raw);
      String? s;
      if (d is String) {
        s = d;
      } else if (d is List && d.isNotEmpty && d.first is String) {
        s = d.first as String;
      }
      final clean = (s ?? '').trim();
      return clean.isEmpty ? defaultName : clean;
    } catch (_) {
      return defaultName;
    }
  }

  bool musicOn = true;
  bool sfxOn = true;
  double volume = 0.8;
  int difficulty = 1; // medium default
  int mode = 0; // relaxed default
  int wordsPerRun = 6;
  String playerName = defaultName;
  String themeId = 'classic';
  int chalkStyle = 0;
  int gamesPlayed = 0;
  int wordsSolved = 0;
  int bestStreak = 0;
  int runsCleared = 0;
  bool isPro = false;

  /// Custom theme colors (ARGB ints). Defaults mirror the Classic Chalkboard.
  Map<String, int> customColors = Map.of(_defaultCustomColors);

  static const Map<String, int> _defaultCustomColors = {
    'boardDark': 0xFF1E3A2B,
    'boardMid': 0xFF2A4F3A,
    'boardDeep': 0xFF101E15,
    'frameDark': 0xFF5C3A21,
    'frameMid': 0xFF7A5230,
    'frameDeep': 0xFF2E1D0E,
    'chalk': 0xFFF5F1E4,
    'chalkAccent': 0xFFE8CE7A,
    'tileFace': 0xFFF8F3E2,
    'tileEdge': 0xFFC9BFA4,
    'ink': 0xFF2E3A2B,
  };

  /// Builds the user-designed custom theme from stored colors.
  ChalkThemeDef get customTheme {
    Color c(String k) => Color(customColors[k] ?? 0xFF000000);
    return ChalkThemeDef(
      id: 'custom',
      name: 'My Creation',
      boardDark: c('boardDark'),
      boardMid: c('boardMid'),
      boardDeep: c('boardDeep'),
      frameDark: c('frameDark'),
      frameMid: c('frameMid'),
      frameDeep: c('frameDeep'),
      chalk: c('chalk'),
      chalkAccent: c('chalkAccent'),
      tileFace: c('tileFace'),
      tileEdge: c('tileEdge'),
      ink: c('ink'),
    );
  }

  SharedPreferences? _prefs;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _prefs = sp;
    musicOn = sp.getBool(_kMusic) ?? true;
    sfxOn = sp.getBool(_kSfx) ?? true;
    volume = sp.getDouble(_kVolume) ?? 0.8;
    difficulty = (sp.getInt(_kDifficulty) ?? 1).clamp(0, 2);
    mode = (sp.getInt(_kMode) ?? 0).clamp(0, 1);
    wordsPerRun = sp.getInt(_kWordsPerRun) ?? 6;
    if (![3, 6, 9].contains(wordsPerRun)) wordsPerRun = 6;
    // Player name: prefer the order-safe JSON key, then migrate legacy keys
    // once (one-time migration). Legacy StringList values on Android may
    // already be scrambled — which is exactly the bug this replaces.
    final nameRaw = sp.getString(_kNameJson);
    if (nameRaw != null) {
      playerName = decodePlayerName(nameRaw);
    } else {
      String? migrated;
      final legacyList = sp.getStringList(_kNames);
      if (legacyList != null && legacyList.isNotEmpty) {
        migrated = legacyList.first;
      } else {
        migrated = sp.getString(_kName);
      }
      playerName = decodePlayerName(
          migrated == null ? null : jsonEncode(migrated));
    }
    themeId = sp.getString(_kTheme) ?? 'classic';
    chalkStyle = (sp.getInt(_kChalkStyle) ?? 0).clamp(0, ChalkStyles.names.length - 1);
    gamesPlayed = sp.getInt(_kGames) ?? 0;
    wordsSolved = sp.getInt(_kWordsSolved) ?? 0;
    bestStreak = sp.getInt(_kBestStreak) ?? 0;
    runsCleared = sp.getInt(_kRunsCleared) ?? 0;
    isPro = sp.getBool(_kIsPro) ?? false;
    for (final k in _defaultCustomColors.keys) {
      customColors[k] =
          sp.getInt('$_kCustomPrefix$k') ?? _defaultCustomColors[k]!;
    }
    _enforceFreeLimits(silent: true);
    notifyListeners();
  }

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    await p.setBool(_kMusic, musicOn);
    await p.setBool(_kSfx, sfxOn);
    await p.setDouble(_kVolume, volume);
    await p.setInt(_kDifficulty, difficulty);
    await p.setInt(_kMode, mode);
    await p.setInt(_kWordsPerRun, wordsPerRun);
    await p.setString(_kNameJson, encodePlayerName(playerName));
    await p.remove(_kNames); // drop legacy keys for good
    await p.remove(_kName);
    await p.setString(_kTheme, themeId);
    await p.setInt(_kChalkStyle, chalkStyle);
    await p.setInt(_kGames, gamesPlayed);
    await p.setInt(_kWordsSolved, wordsSolved);
    await p.setInt(_kBestStreak, bestStreak);
    await p.setInt(_kRunsCleared, runsCleared);
    await p.setBool(_kIsPro, isPro);
    for (final e in customColors.entries) {
      await p.setInt('$_kCustomPrefix${e.key}', e.value);
    }
  }

  /// Free-tier limits: clamp pro-only choices back when not Pro.
  /// Called after load and whenever Pro status could have changed.
  void _enforceFreeLimits({bool silent = false}) {
    if (isPro) return;
    var changed = false;
    if (themeId == 'custom' || ChalkThemes.isProTheme(themeId)) {
      themeId = 'classic';
      changed = true;
    }
    if (ChalkStyles.isPro(chalkStyle)) {
      chalkStyle = 0;
      changed = true;
    }
    if (difficulty > 1) {
      difficulty = 1; // Hard is Pro
      changed = true;
    }
    if (wordsPerRun > 6) {
      wordsPerRun = 6; // 9-word runs are Pro
      changed = true;
    }
    if (changed && !silent) {
      notifyListeners();
      _save();
    }
  }

  Future<void> setPro(bool v) async {
    isPro = v;
    if (!v) _enforceFreeLimits();
    notifyListeners();
    await _save();
  }

  Future<void> setCustomColor(String key, int argb) async {
    if (!isPro) return; // custom theme creator is a Pro feature
    if (!_defaultCustomColors.containsKey(key)) return;
    customColors[key] = argb;
    notifyListeners();
    await _save();
  }

  Future<void> resetCustomColors() async {
    customColors = Map.of(_defaultCustomColors);
    notifyListeners();
    await _save();
  }

  Future<void> setMusic(bool v) async {
    musicOn = v;
    notifyListeners();
    await _save();
  }

  Future<void> setSfx(bool v) async {
    sfxOn = v;
    notifyListeners();
    await _save();
  }

  Future<void> setVolume(double v) async {
    volume = v.clamp(0.0, 1.0);
    notifyListeners();
    await _save();
  }

  /// Full mode setup: [difficulty] 0 easy / 1 medium / 2 hard (2 = Pro),
  /// [mode] 0 relaxed / 1 timed, [wordsPerRun] 3 / 6 / 9 (9 = Pro).
  Future<void> setSetup({
    required int difficulty,
    required int mode,
    required int wordsPerRun,
  }) async {
    this.difficulty = difficulty.clamp(0, 2);
    this.mode = mode.clamp(0, 1);
    this.wordsPerRun = [3, 6, 9].contains(wordsPerRun) ? wordsPerRun : 6;
    // Hard difficulty and 9-word runs are Pro features.
    if (!isPro) {
      if (this.difficulty > 1) this.difficulty = 1;
      if (this.wordsPerRun > 6) this.wordsPerRun = 6;
    }
    notifyListeners();
    await _save();
  }

  Future<void> setPlayerName(String name) async {
    final clean = name.trim();
    playerName = clean.isEmpty ? defaultName : clean;
    notifyListeners();
    await _save();
  }

  Future<void> setTheme(String id) async {
    // Pro-only themes (incl. the custom theme creator) require Pro;
    // silently ignore otherwise (UI shows lock).
    if (!isPro && (id == 'custom' || ChalkThemes.isProTheme(id))) return;
    themeId = id;
    notifyListeners();
    await _save();
  }

  Future<void> setChalkStyle(int v) async {
    v = v.clamp(0, ChalkStyles.names.length - 1);
    if (!isPro && ChalkStyles.isPro(v)) return;
    chalkStyle = v;
    notifyListeners();
    await _save();
  }

  /// Record a finished run.
  Future<void> recordRun({
    required int solved,
    required int total,
    required int bestStreak,
  }) async {
    gamesPlayed++;
    wordsSolved += solved;
    if (bestStreak > this.bestStreak) this.bestStreak = bestStreak;
    if (solved == total && total > 0) runsCleared++;
    notifyListeners();
    await _save();
  }
}
