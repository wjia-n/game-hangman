import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import '../engine/hangman_engine.dart';
import '../engine/word_bank.dart';
import '../services/audio_service.dart';
import '../services/iap_service.dart';
import '../services/settings_service.dart';
import '../theme/chalk_themes.dart';
import '../theme/schoolhouse.dart';
import 'custom_theme_screen.dart';
import 'game_screen.dart';
import 'pro_screen.dart';
import 'settings_screen.dart';

/// Main menu: play setup, name, themes, chalk styles, share/rate, PRO.
/// Music is app-scoped: menu music (re)starts on entry; the game screen
/// switches to the game track and we restore menu music on return.
class MenuScreen extends StatefulWidget {
  final SchoolAudio audio;
  final SchoolSettings settings;
  const MenuScreen({super.key, required this.audio, required this.settings});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late final StoreService _store;

  SchoolSettings get _s => widget.settings;
  ChalkThemeDef get _t => ChalkThemes.byId(
        _s.themeId,
        custom: _s.customTheme,
      );

  @override
  void initState() {
    super.initState();
    _store = StoreService();
    _store.init();
    _store.proPurchased.addListener(_onPro);
    widget.audio.startMenuMusic();
  }

  void _onPro() {
    if (_store.proPurchased.value && mounted) {
      _s.setPro(true);
      _store.proPurchased.value = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _store.proPurchased.removeListener(_onPro);
    _store.dispose();
    super.dispose();
  }

  /// Real in-app review flow: the Play in-app review sheet when available,
  /// otherwise fall back to opening the store listing. No fake dialogs.
  Future<void> _requestReview() async {
    final review = InAppReview.instance;
    try {
      if (await review.isAvailable()) {
        await review.requestReview();
      } else {
        await review.openStoreListing(appStoreId: null);
      }
    } catch (_) {
      // Review UI unavailable on this device/build: stay silent, no fake UI.
    }
  }

  void _play() {
    widget.audio.gameStart();
    final engine = HangmanEngine(
      playerName: _s.playerName,
      difficulty: HangDifficulty.values[_s.difficulty],
      mode: _s.mode == 1 ? HangMode.timed : HangMode.relaxed,
      wordsPerRun: _s.wordsPerRun,
    );
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (_) => GameScreen(
        audio: widget.audio,
        settings: _s,
        engine: engine,
      ),
    ))
        .then((_) {
      // Back on the menu: restore the menu track.
      if (mounted) widget.audio.startMenuMusic();
    });
  }

  void _renamePlayer() {
    widget.audio.click();
    final ctrl = TextEditingController(text: _s.playerName);
    final t = _t;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.boardMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: t.chalkAccent, width: 2),
        ),
        title: Text('Your name', style: School.display(20, theme: t)),
        content: TextField(
          controller: ctrl,
          maxLength: 16,
          autofocus: true,
          // Save on EVERY keystroke (never only on keyboard-done): the
          // name lives in one order-safe JSON string, so this is cheap.
          onChanged: (v) => _s.setPlayerName(v),
          style: School.body(18, theme: t),
          decoration: InputDecoration(
            hintText: 'Word Wizard',
            hintStyle: School.body(16,
                theme: t, color: t.chalk.withValues(alpha: 0.4)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: t.chalkAccent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: t.chalkAccent, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: School.label(14, theme: t)),
          ),
          TextButton(
            onPressed: () {
              widget.audio.click();
              _s.setPlayerName(ctrl.text);
              Navigator.of(ctx).pop();
            },
            child: Text('Save', style: School.label(14, theme: t)),
          ),
        ],
      ),
    );
  }

  void _openPro() {
    widget.audio.click();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProScreen(
        audio: widget.audio,
        settings: _s,
        store: _store,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    return ChalkBackdrop(
      theme: t,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _s,
            builder: (_, _) => SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                children: [
                  // Logo + title.
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: t.chalkAccent, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          offset: const Offset(0, 8),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/hangman_logo.png',
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 12),
                  Text('Hangman', style: School.display(44, theme: t)),
                  const SizedBox(height: 2),
                  Text('THE SCHOOLHOUSE EDITION',
                      style: School.label(12, theme: t)),
                  const SizedBox(height: 14),
                  // Renameable player.
                  GestureDetector(
                    onTap: _renamePlayer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: t.boardDeep.withValues(alpha: 0.6),
                        border: Border.all(
                            color: t.chalkAccent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit,
                              size: 16,
                              color: t.chalk.withValues(alpha: 0.7)),
                          const SizedBox(width: 8),
                          Text(_s.playerName,
                              style: School.body(17, theme: t)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Difficulty.
                  _SectionLabel('Difficulty', t),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Expanded(
                          child: _ModeChip(
                            theme: t,
                            label: HangDifficulty.values[i].label,
                            sub: HangDifficulty.values[i].blurb,
                            selected: _s.difficulty == i,
                            locked: i == 2 && !_s.isPro,
                            onTap: () {
                              if (i == 2 && !_s.isPro) {
                                widget.audio.invalid();
                                _openPro();
                                return;
                              }
                              widget.audio.click();
                              _s.setSetup(
                                difficulty: i,
                                mode: _s.mode,
                                wordsPerRun: _s.wordsPerRun,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Relaxed / Timed.
                  _SectionLabel('Pace', t),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _ModeChip(
                          theme: t,
                          label: 'Relaxed',
                          sub: 'No clock',
                          selected: _s.mode == 0,
                          onTap: () {
                            widget.audio.click();
                            _s.setSetup(
                              difficulty: _s.difficulty,
                              mode: 0,
                              wordsPerRun: _s.wordsPerRun,
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: _ModeChip(
                          theme: t,
                          label: 'Timed',
                          sub:
                              '${HangDifficulty.values[_s.difficulty].timeLimitSecs}s / word',
                          selected: _s.mode == 1,
                          onTap: () {
                            widget.audio.click();
                            _s.setSetup(
                              difficulty: _s.difficulty,
                              mode: 1,
                              wordsPerRun: _s.wordsPerRun,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Words per run.
                  _SectionLabel('Words per run', t),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final n in [3, 6, 9])
                        Expanded(
                          child: _ModeChip(
                            theme: t,
                            label: '$n',
                            sub: n == 9 ? 'Pro' : null,
                            selected: _s.wordsPerRun == n,
                            locked: n == 9 && !_s.isPro,
                            onTap: () {
                              if (n == 9 && !_s.isPro) {
                                widget.audio.invalid();
                                _openPro();
                                return;
                              }
                              widget.audio.click();
                              _s.setSetup(
                                difficulty: _s.difficulty,
                                mode: _s.mode,
                                wordsPerRun: n,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Themes.
                  _SectionLabel('Chalkboard theme', t),
                  const SizedBox(height: 8),
                  _ThemeGrid(
                    theme: t,
                    settings: _s,
                    audio: widget.audio,
                    onPro: _openPro,
                  ),
                  const SizedBox(height: 16),
                  // Chalk styles.
                  _SectionLabel('Chalk style', t),
                  const SizedBox(height: 8),
                  _ChalkRow(
                    theme: t,
                    settings: _s,
                    audio: widget.audio,
                    onPro: _openPro,
                  ),
                  const SizedBox(height: 24),
                  ChalkButton(
                    label: 'Play',
                    theme: t,
                    onTap: _play,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MenuIcon(
                        theme: t,
                        icon: Icons.settings,
                        label: 'Setup',
                        onTap: () {
                          widget.audio.click();
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SettingsScreen(
                              audio: widget.audio,
                              settings: _s,
                            ),
                          ));
                        },
                      ),
                      const SizedBox(width: 22),
                      _MenuIcon(
                        theme: t,
                        icon: _s.isPro ? Icons.star : Icons.lock_open,
                        label: _s.isPro ? 'PRO ✓' : 'PRO',
                        onTap: _openPro,
                      ),
                      const SizedBox(width: 22),
                      _MenuIcon(
                        theme: t,
                        icon: Icons.share,
                        label: 'Share',
                        onTap: () async {
                          widget.audio.click();
                          // ignore: deprecated_member_use
                          await Share.share(
                              'Play Hangman with me! https://play.google.com/store/apps/details?id=com.gameswajiha.hangman');
                        },
                      ),
                      const SizedBox(width: 22),
                      _MenuIcon(
                        theme: t,
                        icon: Icons.star_rate,
                        label: 'Rate',
                        onTap: () async {
                          widget.audio.click();
                          await _requestReview();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final ChalkThemeDef theme;
  const _SectionLabel(this.text, this.theme);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: School.label(14, theme: theme));
}

class _ModeChip extends StatelessWidget {
  final ChalkThemeDef theme;
  final String label;
  final String? sub;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;
  const _ModeChip({
    required this.theme,
    required this.label,
    this.sub,
    required this.selected,
    this.locked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? t.chalkAccent.withValues(alpha: 0.3)
                : t.boardDeep.withValues(alpha: 0.55),
            border: Border.all(
              color: selected
                  ? t.chalkAccent
                  : t.chalkAccent.withValues(alpha: 0.35),
              width: selected ? 2.5 : 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (locked)
                    Icon(Icons.lock,
                        size: 13, color: t.chalk.withValues(alpha: 0.6)),
                  if (locked) const SizedBox(width: 4),
                  Text(label,
                      style: School.label(15, theme: t),
                      textAlign: TextAlign.center),
                ],
              ),
              if (sub != null) ...[
                const SizedBox(height: 2),
                Text(sub!,
                    style: School.body(10,
                        theme: t,
                        color: t.chalk.withValues(alpha: 0.65)),
                    textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeGrid extends StatelessWidget {
  final ChalkThemeDef theme;
  final SchoolSettings settings;
  final SchoolAudio audio;
  final VoidCallback onPro;
  const _ThemeGrid({
    required this.theme,
    required this.settings,
    required this.audio,
    required this.onPro,
  });

  @override
  Widget build(BuildContext context) {
    final themes = ChalkThemes.all;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.82,
      ),
      itemCount: themes.length + 1, // + custom creator tile
      itemBuilder: (_, i) {
        if (i == themes.length) {
          // Custom theme creator tile.
          final locked = !settings.isPro;
          return _Swatch(
            theme: theme,
            name: 'Custom',
            board: settings.customTheme.boardMid,
            frame: settings.customTheme.frameMid,
            chalk: settings.customTheme.chalk,
            selected: settings.themeId == 'custom',
            locked: locked,
            onTap: () {
              if (locked) {
                audio.invalid();
                onPro();
                return;
              }
              audio.click();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CustomThemeScreen(
                  audio: audio,
                  settings: settings,
                ),
              ));
            },
          );
        }
        final th = themes[i];
        final locked = ChalkThemes.isProTheme(th.id) && !settings.isPro;
        return _Swatch(
          theme: theme,
          name: th.name,
          board: th.boardMid,
          frame: th.frameMid,
          chalk: th.chalk,
          selected: settings.themeId == th.id,
          locked: locked,
          onTap: () {
            if (locked) {
              audio.invalid();
              onPro();
              return;
            }
            audio.click();
            settings.setTheme(th.id);
          },
        );
      },
    );
  }
}

class _Swatch extends StatelessWidget {
  final ChalkThemeDef theme;
  final String name;
  final Color board;
  final Color frame;
  final Color chalk;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;
  const _Swatch({
    required this.theme,
    required this.name,
    required this.board,
    required this.frame,
    required this.chalk,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 62,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: board,
              border: Border.all(
                color: selected ? t.chalkAccent : frame,
                width: selected ? 3 : 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(0, 3),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 26,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: chalk.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                if (locked)
                  Center(
                    child: Icon(Icons.lock,
                        size: 18, color: t.chalk.withValues(alpha: 0.8)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            name,
            style: School.body(9,
                theme: t, color: t.chalk.withValues(alpha: 0.75)),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ChalkRow extends StatelessWidget {
  final ChalkThemeDef theme;
  final SchoolSettings settings;
  final SchoolAudio audio;
  final VoidCallback onPro;
  const _ChalkRow({
    required this.theme,
    required this.settings,
    required this.audio,
    required this.onPro,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (int i = 0; i < ChalkStyles.names.length; i++)
          GestureDetector(
            onTap: () {
              if (ChalkStyles.isPro(i) && !settings.isPro) {
                audio.invalid();
                onPro();
                return;
              }
              audio.click();
              settings.setChalkStyle(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ChalkStyles.chalk(i),
                    ChalkStyles.chalkAccent(i),
                  ],
                ),
                border: Border.all(
                  color: settings.chalkStyle == i
                      ? t.chalk
                      : Colors.black.withValues(alpha: 0.4),
                  width: settings.chalkStyle == i ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ChalkStyles.isPro(i) && !settings.isPro
                  ? Icon(Icons.lock,
                      size: 16,
                      color: Colors.black.withValues(alpha: 0.55))
                  : null,
            ),
          ),
      ],
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final ChalkThemeDef theme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuIcon({
    required this.theme,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [t.frameMid, t.frameDark],
              ),
              border: Border.all(color: t.chalkAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: t.chalk, size: 24),
          ),
          const SizedBox(height: 5),
          Text(label, style: School.label(11, theme: t)),
        ],
      ),
    );
  }
}
