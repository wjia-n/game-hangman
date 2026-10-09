import 'package:flutter/material.dart';
import '../engine/hangman_engine.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../theme/chalk_themes.dart';
import '../theme/schoolhouse.dart';

/// The Hangman table: gallows, word tiles, chalk keyboard.
/// The engine owns ALL state and phases; this screen only renders and
/// forwards taps. Music is app-scoped: the game track starts on entry.
class GameScreen extends StatefulWidget {
  final SchoolAudio audio;
  final SchoolSettings settings;
  final HangmanEngine engine;
  const GameScreen({
    super.key,
    required this.audio,
    required this.settings,
    required this.engine,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  HangmanEngine get _e => widget.engine;
  SchoolSettings get _s => widget.settings;

  ChalkThemeDef get _t => ChalkThemes.byId(
        _s.themeId,
        custom: _s.customTheme,
      );
  Color get _chalk => ChalkStyles.chalk(_s.chalkStyle);
  Color get _chalkAccent => ChalkStyles.chalkAccent(_s.chalkStyle);

  /// letter index -> revealToken at which it was revealed (drives the
  /// staggered flip-in animation; cleared on each new word).
  final Map<int, int> _revealedAt = {};
  int _lastSeenToken = 0;
  int _lastSeenWord = -1;
  int _lastSeenWrong = 0;
  late final AnimationController _partPop;
  bool _runRecorded = false;

  @override
  void initState() {
    super.initState();
    _partPop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _e.onEvent = _onEngineEvent;
    _e.addListener(_onEngineChanged);
    widget.audio.startGameMusic();
  }

  void _onEngineEvent(HangEvent ev) {
    final a = widget.audio;
    switch (ev) {
      case HangEvent.letterGood:
        a.letterGood();
      case HangEvent.letterBad:
        a.letterBad();
      case HangEvent.invalid:
        a.invalid();
      case HangEvent.wordSolved:
        a.win();
      case HangEvent.wordFailed:
        a.lose();
      case HangEvent.timeUp:
        a.lose();
      case HangEvent.tickWarn:
        a.tick();
      case HangEvent.gameStart:
        a.deal();
      case HangEvent.runOver:
        break;
    }
  }

  void _onEngineChanged() {
    if (!mounted) return;
    // New word dealt: reset reveal tracking, play the paper shuffle.
    if (_e.wordIndex != _lastSeenWord) {
      _lastSeenWord = _e.wordIndex;
      _revealedAt.clear();
      _lastSeenToken = _e.revealToken;
      _lastSeenWrong = _e.wrong;
      widget.audio.deal();
    }
    // A new gallows part drew: pop it in with a chalk-sketch bounce.
    if (_e.wrong > _lastSeenWrong) {
      _lastSeenWrong = _e.wrong;
      _partPop.forward(from: 0);
    }
    // Fresh reveals: stamp which letters appeared on this token.
    if (_e.revealToken != _lastSeenToken) {
      _lastSeenToken = _e.revealToken;
      final letters = _e.word.text.split('');
      for (int i = 0; i < letters.length; i++) {
        if (letters[i] == _e.lastLetter) _revealedAt[i] = _e.revealToken;
      }
    }
    if (_e.phase == HangPhase.runOver && !_runRecorded) {
      _runRecorded = true;
      _s.recordRun(
        solved: _e.solvedCount,
        total: _e.wordIndex + 1,
        bestStreak: _e.bestStreakRun,
      );
    }
    setState(() {});
  }

  /// Restart the run and reset all UI-side per-word tracking, so the
  /// dealing beat starts from a clean slate (fresh deal sound, no stale
  /// reveal stamps or gallows parts).
  void _cleanRestart() {
    _revealedAt.clear();
    _lastSeenWord = -1;
    _lastSeenToken = 0;
    _lastSeenWrong = 0;
    _runRecorded = false;
    _e.restart();
  }

  @override
  void dispose() {
    _e.removeListener(_onEngineChanged);
    _e.onEvent = null;
    _partPop.dispose();
    _e.dispose();
    super.dispose();
  }

  void _pause() {
    widget.audio.click();
    _e.setPaused(true);
    final t = _t;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.boardMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: t.chalkAccent, width: 2),
        ),
        title: Text('Paused', style: School.display(24, theme: t)),
        content: Text('Take a breath. The word will wait.',
            style: School.body(15, theme: t)),
        actions: [
          TextButton(
            onPressed: () {
              widget.audio.click();
              _e.setPaused(false);
              Navigator.of(ctx).pop();
            },
            child: Text('Resume', style: School.label(14, theme: t)),
          ),
          TextButton(
            onPressed: () {
              widget.audio.click();
              Navigator.of(ctx).pop();
              _cleanRestart();
            },
            child: Text('Restart', style: School.label(14, theme: t)),
          ),
          TextButton(
            onPressed: () {
              widget.audio.click();
              _e.setPaused(false);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text('Menu', style: School.label(14, theme: t)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    return ChalkBackdrop(
      theme: t,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _topBar(t),
                  _categoryRow(t),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _GallowsArea(
                        theme: t,
                        chalk: _chalk,
                        chalkAccent: _chalkAccent,
                        wrong: _e.wrong,
                        maxWrong: _e.maxWrong,
                        pop: _partPop,
                      ),
                    ),
                  ),
                  _wordTiles(t),
                  const SizedBox(height: 6),
                  _statusLine(t),
                  const SizedBox(height: 8),
                  _keyboard(t),
                  const SizedBox(height: 10),
                ],
              ),
              if (_e.phase == HangPhase.runOver) _runOverPanel(t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(ChalkThemeDef t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Row(
        children: [
          _roundButton(
            t,
            Icons.pause,
            _e.over ? null : _pause,
          ),
          const SizedBox(width: 10),
          Text(
            'Word ${_e.wordIndex + 1}/${_e.wordsPerRun}',
            style: School.label(14, theme: t),
          ),
          const Spacer(),
          if (_e.mode == HangMode.timed) _timerChip(t),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: t.boardDeep.withValues(alpha: 0.6),
              border:
                  Border.all(color: t.chalkAccent.withValues(alpha: 0.5)),
            ),
            child: Text('★ ${_e.solvedCount}',
                style: School.label(14, theme: t)),
          ),
        ],
      ),
    );
  }

  Widget _timerChip(ChalkThemeDef t) {
    final urgent = _e.secondsLeft <= 10;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: urgent
            ? const Color(0xFF7A2020).withValues(alpha: 0.85)
            : t.boardDeep.withValues(alpha: 0.6),
        border: Border.all(
          color: urgent ? const Color(0xFFE08A8A) : t.chalkAccent,
          width: urgent ? 2 : 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer,
              size: 15, color: urgent ? const Color(0xFFFFB0B0) : t.chalk),
          const SizedBox(width: 5),
          Text(
            '${_e.secondsLeft}s',
            style: School.label(14,
                theme: t,
                color: urgent ? const Color(0xFFFFB0B0) : null),
          ),
        ],
      ),
    );
  }

  Widget _roundButton(
      ChalkThemeDef t, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
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
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon,
            color: onTap == null
                ? t.chalk.withValues(alpha: 0.35)
                : t.chalk,
            size: 20),
      ),
    );
  }

  Widget _categoryRow(ChalkThemeDef t) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: t.boardDeep.withValues(alpha: 0.6),
          border:
              Border.all(color: t.chalkAccent.withValues(alpha: 0.5)),
        ),
        child: Text(_e.word.category, style: School.label(13, theme: t)),
      ),
    );
  }

  Widget _wordTiles(ChalkThemeDef t) {
    final letters = _e.word.text.split('');
    if (_e.phase == HangPhase.dealing) {
      return SizedBox(
        height: 64,
        child: Center(
          child: Text('Dealing a word…',
              style: School.body(16,
                  theme: t,
                  color: t.chalk.withValues(alpha: 0.6))),
        ),
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 7,
      runSpacing: 7,
      children: [
        for (int i = 0; i < letters.length; i++)
          _LetterTile(
            key: ValueKey('tile-$i-${_revealedAt[i] ?? -1}'),
            theme: t,
            letter: letters[i],
            shown: _e.letterShown(letters[i]),
            justRevealed: _revealedAt[i] == _e.revealToken &&
                _e.revealToken > 0,
            solved: _e.solved,
            failed: _e.failed,
          ),
      ],
    );
  }

  Widget _statusLine(ChalkThemeDef t) {
    String text;
    Color color = t.chalk.withValues(alpha: 0.75);
    if (_e.solved) {
      text = 'Nailed it! +1 star';
      color = _chalkAccent;
    } else if (_e.failed) {
      text = _e.timedOut
          ? 'Time ran out! It was "${_e.word.text}"'
          : 'The word was "${_e.word.text}"';
      color = const Color(0xFFE08A8A);
    } else if (_e.phase == HangPhase.dealing) {
      text = '…';
    } else {
      text = 'Wrong guesses: ${_e.wrong}/${_e.maxWrong}';
      if (_e.wrong >= _e.maxWrong - 2) color = const Color(0xFFE0A83C);
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Text(
        text,
        key: ValueKey(text),
        style: School.body(14, theme: t, color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _keyboard(ChalkThemeDef t) {
    const rows = ['ABCDEFGHIJ', 'KLMNOPQRS', 'TUVWXYZ'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: rows
            .map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: row
                        .split('')
                        .map((l) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.5),
                                child: _Key(
                                  theme: t,
                                  letter: l,
                                  chalk: _chalk,
                                  chalkAccent: _chalkAccent,
                                  state: _keyState(l),
                                  enabled: _e.canGuess,
                                  onTap: () => _e.guessLetter(l),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ))
            .toList(),
      ),
    );
  }

  _KeyState _keyState(String l) {
    if (!_e.guessed.contains(l)) return _KeyState.fresh;
    return _e.word.text.contains(l) ? _KeyState.good : _KeyState.bad;
  }

  Widget _runOverPanel(ChalkThemeDef t) {
    final total = _e.wordIndex + 1;
    final s = _e.solvedCount;
    final cleared = s == total;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.elasticOut,
      builder: (_, scale, _) => Opacity(
        opacity: ((scale - 0.7) / 0.3).clamp(0.0, 1.0),
        child: Center(
          child: Transform.scale(
            scale: scale,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 34),
              padding: const EdgeInsets.symmetric(
                  horizontal: 26, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [t.boardMid, t.boardDeep],
                ),
                border: Border.all(color: t.chalkAccent, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    offset: const Offset(0, 12),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cleared ? 'Perfect Run!' : 'Run Complete',
                      style: School.display(30, theme: t),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    '${_e.playerName} solved $s/$total words',
                    style: School.body(17, theme: t),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text('Best streak: ${_e.bestStreakRun}',
                      style: School.body(14,
                          theme: t,
                          color: t.chalk.withValues(alpha: 0.7))),
                  const SizedBox(height: 6),
                  Text(
                    cleared
                        ? 'Flawless! The chalkboard bows to you.'
                        : s >= (total / 2).ceil()
                            ? 'Sharp guessing! One more run?'
                            : 'Good warm-up — the chalk is still fresh.',
                    style: School.body(14,
                        theme: t,
                        color: t.chalk.withValues(alpha: 0.75)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ChalkButton(
                    label: 'Play Again',
                    theme: t,
                    width: 210,
                    onTap: () {
                      widget.audio.click();
                      _cleanRestart();
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      widget.audio.click();
                      Navigator.of(context).pop();
                    },
                    child: Text('Back to menu',
                        style: School.label(14, theme: t)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _KeyState { fresh, good, bad }

/// A single chalk keyboard key with press feedback and state coloring.
class _Key extends StatefulWidget {
  final ChalkThemeDef theme;
  final String letter;
  final Color chalk;
  final Color chalkAccent;
  final _KeyState state;
  final bool enabled;
  final VoidCallback onTap;
  const _Key({
    required this.theme,
    required this.letter,
    required this.chalk,
    required this.chalkAccent,
    required this.state,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_Key> createState() => _KeyStateful();
}

class _KeyStateful extends State<_Key> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final fresh = widget.state == _KeyState.fresh;
    final good = widget.state == _KeyState.good;
    return GestureDetector(
      onTapDown:
          fresh && widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: fresh && widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 46,
        transform: Matrix4.translationValues(0, _pressed ? 2.5 : 0, 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fresh
              ? t.boardDeep.withValues(alpha: 0.7)
              : good
                  ? widget.chalkAccent.withValues(alpha: 0.35)
                  : t.boardDeep.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: fresh
                ? widget.chalk.withValues(alpha: 0.5)
                : good
                    ? widget.chalkAccent
                    : t.chalk.withValues(alpha: 0.2),
            width: fresh ? 1.5 : 2,
          ),
          boxShadow: fresh
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    offset: Offset(0, _pressed ? 1 : 3),
                    blurRadius: _pressed ? 2 : 5,
                  ),
                ]
              : [],
        ),
        child: Text(
          widget.letter,
          style: School.label(17,
              theme: t,
              color: fresh
                  ? widget.chalk
                  : good
                      ? widget.chalkAccent
                      : t.chalk.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}

/// A word letter tile. Newly revealed letters flip in with a chalk-sketch
/// bounce instead of popping; the reveal stagger comes from the engine's
/// revealToken ordering.
class _LetterTile extends StatelessWidget {
  final ChalkThemeDef theme;
  final String letter;
  final bool shown;
  final bool justRevealed;
  final bool solved;
  final bool failed;
  const _LetterTile({
    super.key,
    required this.theme,
    required this.letter,
    required this.shown,
    required this.justRevealed,
    required this.solved,
    required this.failed,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final tile = Container(
      width: 34,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            t.tileFace,
            Color.lerp(t.tileFace, t.tileEdge, 0.45)!,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: shown
                ? (solved
                    ? const Color(0xFF7FB069)
                    : failed
                        ? const Color(0xFFD64545)
                        : t.chalkAccent)
                : t.tileEdge,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, 3),
            blurRadius: 5,
          ),
        ],
      ),
      child: Text(
        shown ? letter : '',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: t.ink,
          fontFamily: 'serif',
        ),
      ),
    );
    if (!justRevealed) return tile;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.elasticOut,
      builder: (_, v, _) => Transform.scale(
        scale: 0.4 + 0.6 * v,
        child: Transform(
          transform: Matrix4.identity()..rotateY((1 - v) * 1.2),
          alignment: Alignment.center,
          child: tile,
        ),
      ),
    );
  }
}

/// The gallows: wooden frame always visible; chalk figure parts draw in
/// one by one. The newest part pops with a sketch-bounce animation.
/// Parts 1-6 are the classic figure; parts 7-8 (chalk cap, scarf) only
/// appear on the Easy tier's 8-miss budget.
class _GallowsArea extends StatelessWidget {
  final ChalkThemeDef theme;
  final Color chalk;
  final Color chalkAccent;
  final int wrong;
  final int maxWrong;
  final AnimationController pop;
  const _GallowsArea({
    required this.theme,
    required this.chalk,
    required this.chalkAccent,
    required this.wrong,
    required this.maxWrong,
    required this.pop,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pop,
      builder: (_, _) => CustomPaint(
        painter: _GallowsPainter(
          theme: theme,
          chalk: chalk,
          chalkAccent: chalkAccent,
          wrong: wrong,
          maxWrong: maxWrong,
          popValue: pop.value,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GallowsPainter extends CustomPainter {
  final ChalkThemeDef theme;
  final Color chalk;
  final Color chalkAccent;
  final int wrong;
  final int maxWrong;
  final double popValue;

  const _GallowsPainter({
    required this.theme,
    required this.chalk,
    required this.chalkAccent,
    required this.wrong,
    required this.maxWrong,
    required this.popValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final wood = Paint()
      ..color = theme.frameMid
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final woodDark = Paint()
      ..color = theme.frameDeep
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final baseY = size.height - 6;
    final poleX = w * 0.3;
    final topY = 10.0;
    final beamX = w * 0.68;

    // Wooden scaffold: shadow pass then highlight pass for depth.
    for (final p in [woodDark, wood]) {
      final dy = p == wood ? -2.0 : 0.0;
      canvas.drawLine(
          Offset(poleX - 52, baseY), Offset(poleX + 52, baseY + dy), p);
      canvas.drawLine(Offset(poleX, baseY), Offset(poleX + dy, topY), p);
      canvas.drawLine(Offset(poleX, topY + dy), Offset(beamX, topY + dy), p);
      canvas.drawLine(
          Offset(poleX + 26, topY + dy), Offset(poleX, topY + 32 + dy), p);
    }
    // Rope.
    canvas.drawLine(
        Offset(beamX, topY), Offset(beamX, topY + 26), woodDark);

    final figure = Paint()
      ..color = chalk
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // The newest part draws with a pop scale; older parts are steady.
    double partScale(int part) {
      if (part < wrong) return 1.0;
      if (part == wrong) {
        final v = popValue.clamp(0.0, 1.0);
        return 0.3 + 0.7 * Curves.elasticOut.transform(v);
      }
      return 0.0;
    }

    void drawPart(int part, void Function(Canvas, double) fn) {
      final s = partScale(part);
      if (s <= 0) return;
      canvas.save();
      fn(canvas, s);
      canvas.restore();
    }

    final headC = Offset(beamX, topY + 52);
    const headR = 24.0;

    drawPart(1, (c, s) {
      c.save();
      c.translate(headC.dx, headC.dy);
      c.scale(s);
      c.translate(-headC.dx, -headC.dy);
      c.drawCircle(headC, headR, figure);
      // Face: dot eyes while guessing, X eyes when the drawing completes.
      final face = Paint()
        ..color = chalkAccent
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      if (wrong >= maxWrong) {
        for (final dx in [-8.0, 8.0]) {
          c.drawLine(headC + Offset(dx - 4, -8), headC + Offset(dx + 4, 0), face);
          c.drawLine(headC + Offset(dx + 4, -8), headC + Offset(dx - 4, 0), face);
        }
      } else {
        final fill = Paint()
          ..color = chalkAccent
          ..style = PaintingStyle.fill;
        c.drawCircle(headC + const Offset(-8, -4), 2.8, fill);
        c.drawCircle(headC + const Offset(8, -4), 2.8, fill);
      }
      c.restore();
    });

    final neckY = headC.dy + headR;
    drawPart(2, (c, s) {
      c.drawLine(Offset(beamX, neckY),
          Offset(beamX, neckY + (58 * s)), figure);
    });
    final shoulderY = neckY + 20;
    final hipY = neckY + 58;
    drawPart(3, (c, s) {
      c.drawLine(Offset(beamX, shoulderY),
          Offset(beamX - 32 * s, shoulderY + 28 * s), figure);
    });
    drawPart(4, (c, s) {
      c.drawLine(Offset(beamX, shoulderY),
          Offset(beamX + 32 * s, shoulderY + 28 * s), figure);
    });
    drawPart(5, (c, s) {
      c.drawLine(Offset(beamX, hipY),
          Offset(beamX - 26 * s, hipY + 40 * s), figure);
    });
    drawPart(6, (c, s) {
      c.drawLine(Offset(beamX, hipY),
          Offset(beamX + 26 * s, hipY + 40 * s), figure);
    });
    // Easy-tier bonus parts: a chalk cap and a scarf for misses 7-8.
    final brimY = headC.dy - headR - 5;
    drawPart(7, (c, s) {
      c.drawLine(Offset(headC.dx - 26 * s, brimY),
          Offset(headC.dx + 26 * s, brimY), figure);
      c.drawArc(
          Rect.fromCircle(
              center: Offset(headC.dx, brimY - 2), radius: 16 * s),
          3.14159,
          3.14159,
          false,
          figure);
    });
    final scarfY = neckY + 7;
    drawPart(8, (c, s) {
      c.drawLine(Offset(headC.dx - 20 * s, scarfY),
          Offset(headC.dx + 20 * s, scarfY), figure);
      c.drawLine(Offset(headC.dx + 12 * s, scarfY),
          Offset(headC.dx + 19 * s, scarfY + 26 * s), figure);
    });
  }

  @override
  bool shouldRepaint(covariant _GallowsPainter old) =>
      old.wrong != wrong ||
      old.maxWrong != maxWrong ||
      old.popValue != popValue ||
      old.theme != theme ||
      old.chalk != chalk;
}
