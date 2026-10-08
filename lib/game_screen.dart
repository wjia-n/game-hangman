import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wajiha_game_core/wajiha_game_core.dart';

/// Hangman — solo word guessing with a progressively drawn gallows.
/// 6 words per run; 6 wrong guesses loses the current word.
class HangmanScreen extends StatefulWidget {
  final List<Player> players;
  final GameCallbacks callbacks;

  const HangmanScreen({super.key, required this.players, required this.callbacks});

  @override
  State<HangmanScreen> createState() => _HangmanScreenState();
}

class _Word {
  final String text;
  final String category;
  const _Word(this.text, this.category);
}

class _HangmanScreenState extends State<HangmanScreen> {
  static const _words = <_Word>[
    // Animals
    _Word('ELEPHANT', '🐾 Animal'), _Word('GIRAFFE', '🐾 Animal'),
    _Word('KANGAROO', '🐾 Animal'), _Word('PENGUIN', '🐾 Animal'),
    _Word('DOLPHIN', '🐾 Animal'), _Word('CROCODILE', '🐾 Animal'),
    _Word('BUTTERFLY', '🐾 Animal'), _Word('LEOPARD', '🐾 Animal'),
    _Word('ZEBRA', '🐾 Animal'), _Word('HIPPO', '🐾 Animal'),
    _Word('RHINO', '🐾 Animal'), _Word('PANDA', '🐾 Animal'),
    _Word('KOALA', '🐾 Animal'), _Word('TIGER', '🐾 Animal'),
    _Word('LION', '🐾 Animal'), _Word('WOLF', '🐾 Animal'),
    _Word('FOX', '🐾 Animal'), _Word('BEAR', '🐾 Animal'),
    _Word('MONKEY', '🐾 Animal'), _Word('CAMEL', '🐾 Animal'),
    _Word('OCTOPUS', '🐾 Animal'), _Word('SHARK', '🐾 Animal'),
    _Word('EAGLE', '🐾 Animal'), _Word('OWL', '🐾 Animal'),
    _Word('PARROT', '🐾 Animal'), _Word('SNAKE', '🐾 Animal'),
    // Food
    _Word('PIZZA', '🍕 Food'), _Word('BURGER', '🍕 Food'),
    _Word('PASTA', '🍕 Food'), _Word('CHOCOLATE', '🍕 Food'),
    _Word('PANCAKE', '🍕 Food'), _Word('SANDWICH', '🍕 Food'),
    _Word('SPAGHETTI', '🍕 Food'), _Word('MANGO', '🍕 Food'),
    _Word('BANANA', '🍕 Food'), _Word('APPLE', '🍕 Food'),
    _Word('ORANGE', '🍕 Food'), _Word('GRAPES', '🍕 Food'),
    _Word('STRAWBERRY', '🍕 Food'), _Word('WATERMELON', '🍕 Food'),
    _Word('POPCORN', '🍕 Food'), _Word('CHEESE', '🍕 Food'),
    _Word('COOKIE', '🍕 Food'), _Word('CAKE', '🍕 Food'),
    _Word('MUFFIN', '🍕 Food'), _Word('DONUT', '🍕 Food'),
    _Word('SOUP', '🍕 Food'), _Word('SALAD', '🍕 Food'),
    _Word('TACOS', '🍕 Food'), _Word('SUSHI', '🍕 Food'),
    _Word('CURRY', '🍕 Food'), _Word('BREAD', '🍕 Food'),
    _Word('HONEY', '🍕 Food'),
    // Space
    _Word('ROCKET', '🚀 Space'), _Word('PLANET', '🚀 Space'),
    _Word('GALAXY', '🚀 Space'), _Word('STAR', '🚀 Space'),
    _Word('MOON', '🚀 Space'), _Word('COMET', '🚀 Space'),
    _Word('ASTEROID', '🚀 Space'), _Word('ASTRONAUT', '🚀 Space'),
    _Word('ORBIT', '🚀 Space'), _Word('NEBULA', '🚀 Space'),
    _Word('ECLIPSE', '🚀 Space'), _Word('MARS', '🚀 Space'),
    _Word('VENUS', '🚀 Space'), _Word('JUPITER', '🚀 Space'),
    _Word('SATURN', '🚀 Space'), _Word('MERCURY', '🚀 Space'),
    _Word('URANUS', '🚀 Space'), _Word('NEPTUNE', '🚀 Space'),
    _Word('COSMOS', '🚀 Space'), _Word('METEOR', '🚀 Space'),
    _Word('SATELLITE', '🚀 Space'), _Word('TELESCOPE', '🚀 Space'),
    _Word('ALIEN', '🚀 Space'), _Word('CRATER', '🚀 Space'),
    _Word('GRAVITY', '🚀 Space'), _Word('SOLAR', '🚀 Space'),
  ];

  static const _totalWords = 6;
  static const _maxWrong = 6;

  late List<_Word> _run;
  int _wordIndex = 0;
  final Set<String> _guessed = {};
  int _wrong = 0;
  bool _wordDone = false;
  bool _over = false;

  Player get _me => widget.players.first;
  _Word get _word => _run[_wordIndex];

  @override
  void initState() {
    super.initState();
    _run = List<_Word>.of(_words)..shuffle(Random());
    _run = _run.take(_totalWords).toList();
  }

  void _guess(String letter) {
    if (_wordDone || _over || _guessed.contains(letter)) return;
    setState(() => _guessed.add(letter));
    if (_word.text.contains(letter)) {
      Sfx.move();
      if (_word.text.split('').every(_guessed.contains)) {
        _solved();
      }
    } else {
      Sfx.click();
      setState(() => _wrong++);
      if (_wrong >= _maxWrong) {
        _failed();
      }
    }
  }

  void _solved() {
    setState(() => _wordDone = true);
    _me.score += 1;
    widget.callbacks.refreshHud();
    Sfx.win();
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      _nextWord();
    });
  }

  void _failed() {
    setState(() => _wordDone = true);
    Sfx.lose();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      _nextWord();
    });
  }

  void _nextWord() {
    if (_wordIndex + 1 >= _totalWords) {
      _finishRun();
      return;
    }
    setState(() {
      _wordIndex++;
      _guessed.clear();
      _wrong = 0;
      _wordDone = false;
    });
  }

  void _finishRun() {
    if (_over) return;
    _over = true;
    final s = _me.score;
    final cheer = s >= 5
        ? 'Word wizard! The dictionary fears you. 🧙'
        : s >= 3
            ? 'Sharp brain! A couple more and you\'re legendary. 💪'
            : 'Good warm-up! Every genius starts somewhere. 🌱';
    widget.callbacks.finish(
      headline: 'You solved $s/$_totalWords words!',
      subline: cheer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ThemeController.of(context).theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: t.radius,
                  border: Border.all(color: t.primary.withValues(alpha: 0.35), width: 1.5),
                ),
                child: Text(_word.category,
                    style: TextStyle(color: t.text, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              Text('Word ${_wordIndex + 1}/$_totalWords',
                  style: TextStyle(color: t.muted, fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 210,
            child: CustomPaint(
              painter: _HangmanPainter(
                wrong: _wrong,
                lineColor: t.text,
                accentColor: _wordDone && _wrong < _maxWrong ? t.accent : t.primary,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          _wordSlots(t),
          const SizedBox(height: 10),
          Text(
            _wordDone
                ? (_wrong >= _maxWrong ? 'The word was "${_word.text}" 😅' : 'Nailed it! 🎉')
                : 'Wrong guesses: $_wrong/$_maxWrong',
            style: TextStyle(
              color: _wrong >= 4 && !_wordDone ? t.secondary : t.muted,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          _keyboard(t),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _wordSlots(GameTheme t) {
    final letters = _word.text.split('');
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: letters.map((l) {
        final revealed = _guessed.contains(l) || _wordDone;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: revealed ? 0.6 : 1.0, end: 1.0),
          duration: const Duration(milliseconds: 180),
          builder: (_, s, _) => Transform.scale(
            scale: s,
            child: Container(
              width: 34,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  bottom: BorderSide(
                    color: revealed ? t.accent : t.primary.withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                revealed ? l : '',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: t.text),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _keyboard(GameTheme t) {
    const rows = ['ABCDEFGHIJ', 'KLMNOPQRS', 'TUVWXYZ'];
    return Column(
      children: rows
          .map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: row.split('').map((l) {
                    final guessed = _guessed.contains(l);
                    final correct = guessed && _word.text.contains(l);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: GestureDetector(
                          onTap: guessed ? null : () => _guess(l),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !guessed
                                  ? t.primary.withValues(alpha: 0.9)
                                  : correct
                                      ? t.accent.withValues(alpha: 0.35)
                                      : t.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: !guessed
                                    ? Colors.transparent
                                    : correct
                                        ? t.accent
                                        : t.muted.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              l,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: !guessed
                                    ? Colors.white
                                    : correct
                                        ? t.accent
                                        : t.muted.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ))
          .toList(),
    );
  }
}

/// Draws the gallows plus body parts for each wrong guess:
/// 1 head, 2 body, 3 left arm, 4 right arm, 5 left leg, 6 right leg.
class _HangmanPainter extends CustomPainter {
  final int wrong;
  final Color lineColor;
  final Color accentColor;

  const _HangmanPainter({required this.wrong, required this.lineColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final baseY = size.height - 8;
    final poleX = w * 0.28;
    final topY = 14.0;
    final beamX = w * 0.66;

    // Scaffold
    canvas.drawLine(Offset(poleX - 55, baseY), Offset(poleX + 55, baseY), paint);
    canvas.drawLine(Offset(poleX, baseY), Offset(poleX, topY), paint);
    canvas.drawLine(Offset(poleX, topY), Offset(beamX, topY), paint);
    canvas.drawLine(Offset(poleX, topY + 34), Offset(poleX + 30, topY), paint); // brace
    canvas.drawLine(Offset(beamX, topY), Offset(beamX, topY + 30), paint); // rope

    final bodyPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final headC = Offset(beamX, topY + 58);
    const headR = 26.0;
    if (wrong >= 1) canvas.drawCircle(headC, headR, bodyPaint);
    if (wrong >= 2) {
      canvas.drawLine(Offset(beamX, headC.dy + headR), Offset(beamX, headC.dy + headR + 62), bodyPaint);
    }
    final shoulderY = headC.dy + headR + 22;
    final hipY = headC.dy + headR + 62;
    if (wrong >= 3) canvas.drawLine(Offset(beamX, shoulderY), Offset(beamX - 34, shoulderY + 30), bodyPaint);
    if (wrong >= 4) canvas.drawLine(Offset(beamX, shoulderY), Offset(beamX + 34, shoulderY + 30), bodyPaint);
    if (wrong >= 5) canvas.drawLine(Offset(beamX, hipY), Offset(beamX - 28, hipY + 42), bodyPaint);
    if (wrong >= 6) canvas.drawLine(Offset(beamX, hipY), Offset(beamX + 28, hipY + 42), bodyPaint);

    // Face: happy eyes while alive, X eyes when the drawing completes.
    if (wrong >= 1) {
      final face = Paint()
        ..color = accentColor
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      if (wrong >= 6) {
        for (final dx in [-9.0, 9.0]) {
          canvas.drawLine(headC + Offset(dx - 5, -8), headC + Offset(dx + 5, 2), face);
          canvas.drawLine(headC + Offset(dx + 5, -8), headC + Offset(dx - 5, 2), face);
        }
      } else {
        canvas.drawCircle(headC + const Offset(-9, -5), 3, face..style = PaintingStyle.fill);
        canvas.drawCircle(headC + const Offset(9, -5), 3, face);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HangmanPainter old) =>
      old.wrong != wrong || old.lineColor != lineColor || old.accentColor != accentColor;
}
