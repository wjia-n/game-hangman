import 'package:flutter/material.dart';
import 'chalk_themes.dart';

/// The schoolhouse design system for Hangman.
/// Real chalkboards, wooden frames, chalk dust — no neon, no cyberpunk,
/// no generic Material look.
///
/// All widgets accept an optional [ChalkThemeDef]; they default to the
/// Classic Chalkboard theme so existing call sites keep working.
class School {
  static const displayFont = 'serif';

  static TextStyle display(double size, {Color? color, ChalkThemeDef? theme}) =>
      TextStyle(
        fontFamily: displayFont,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? theme?.chalkAccent ?? const Color(0xFFE8CE7A),
        letterSpacing: 1.2,
        shadows: const [
          Shadow(
              color: Color(0x66000000),
              offset: Offset(0, 2),
              blurRadius: 4),
        ],
      );

  static TextStyle body(double size, {Color? color, ChalkThemeDef? theme}) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? theme?.chalk ?? const Color(0xFFF5F1E4),
        height: 1.35,
      );

  static TextStyle label(double size, {Color? color, ChalkThemeDef? theme}) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? theme?.chalkAccent ?? const Color(0xFFE8CE7A),
        letterSpacing: 0.8,
      );

  static ThemeData theme([ChalkThemeDef? t]) {
    t ??= ChalkThemes.byId('classic');
    final isLight = t.id == 'parchment';
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: t.boardDark,
      colorScheme: ColorScheme(
        brightness: isLight ? Brightness.light : Brightness.dark,
        primary: t.chalkAccent,
        onPrimary: t.boardDeep,
        secondary: t.chalk,
        onSecondary: t.boardDeep,
        surface: t.boardMid,
        onSurface: t.chalk,
        error: const Color(0xFFD64545),
        onError: t.chalk,
      ),
      textTheme: TextTheme(
        displayLarge: display(34, theme: t),
        displayMedium: display(26, theme: t),
        titleLarge: display(22, theme: t),
        bodyLarge: body(16, theme: t),
        bodyMedium: body(14, theme: t),
        labelLarge: label(14, theme: t),
      ),
      dialogTheme: DialogThemeData(backgroundColor: t.boardMid),
    );
  }
}

/// Chalkboard background with chalk dust and a soft vignette.
class ChalkBackdrop extends StatelessWidget {
  final Widget child;
  final ChalkThemeDef? theme;
  const ChalkBackdrop({super.key, required this.child, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? ChalkThemes.byId('classic');
    return Container(
      decoration: BoxDecoration(color: t.boardDark),
      child: CustomPaint(
        painter: _ChalkDustPainter(t),
        child: child,
      ),
    );
  }
}

class _ChalkDustPainter extends CustomPainter {
  final ChalkThemeDef t;
  _ChalkDustPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final vignette = RadialGradient(
      center: const Alignment(0, -0.25),
      radius: 1.15,
      colors: [
        t.boardMid.withValues(alpha: 0.55),
        t.boardDark.withValues(alpha: 0.0),
        Colors.black.withValues(alpha: 0.5),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = vignette.createShader(Offset.zero & size),
    );
    // Chalk dust smudges.
    final dust = Paint()..color = t.chalk.withValues(alpha: 0.045);
    final rng = [0.13, 0.37, 0.61, 0.83, 0.25, 0.52, 0.74, 0.9, 0.06, 0.46];
    for (int i = 0; i < rng.length; i++) {
      final cx = size.width * rng[i];
      final cy = size.height * rng[(i + 3) % rng.length];
      canvas.drawCircle(
          Offset(cx, cy), 34 + (i % 3) * 22, dust);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A chunky wooden-framed button with chalk text — physically pressable.
class ChalkButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final double width;
  final double fontSize;
  final ChalkThemeDef? theme;

  const ChalkButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width = 240,
    this.fontSize = 19,
    this.theme,
  });

  @override
  State<ChalkButton> createState() => _ChalkButtonState();
}

class _ChalkButtonState extends State<ChalkButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme ?? ChalkThemes.byId('classic');
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: widget.width,
        padding: const EdgeInsets.symmetric(vertical: 15),
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: enabled
                ? [t.frameMid, t.frameDark, t.frameDeep]
                : [
                    t.frameDeep.withValues(alpha: 0.7),
                    t.frameDeep.withValues(alpha: 0.5)
                  ],
          ),
          border: Border.all(color: t.chalkAccent, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: t.chalkAccent.withValues(alpha: _pressed ? 0.05 : 0.18),
              offset: const Offset(0, -2),
              blurRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              offset: Offset(0, _pressed ? 2 : 6),
              blurRadius: _pressed ? 4 : 10,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: School.display(widget.fontSize,
              theme: t,
              color:
                  enabled ? t.chalk : t.chalk.withValues(alpha: 0.45)),
        ),
      ),
    );
  }
}

/// A framed chalkboard plaque for titles.
class ChalkPlaque extends StatelessWidget {
  final String title;
  final String? subtitle;
  final ChalkThemeDef? theme;
  const ChalkPlaque({super.key, required this.title, this.subtitle, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? ChalkThemes.byId('classic');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.boardDeep, t.boardDark],
        ),
        border: Border.all(color: t.chalkAccent, width: 3),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              offset: const Offset(0, 6),
              blurRadius: 12),
          BoxShadow(
              color: t.chalk.withValues(alpha: 0.35),
              offset: const Offset(0, -1),
              blurRadius: 1),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: School.display(30, theme: t),
              textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!,
                style: School.body(14,
                    theme: t, color: t.chalk.withValues(alpha: 0.75)),
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// A chalk toggle.
class ChalkToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final ChalkThemeDef? theme;
  const ChalkToggle(
      {super.key, required this.value, required this.onChanged, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? ChalkThemes.byId('classic');
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 64,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: value ? t.frameDark : t.boardDeep,
          border: Border.all(color: t.chalkAccent, width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(0, 3),
                blurRadius: 5),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [t.chalk, t.chalkAccent, t.frameMid],
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A chalk-stick volume slider.
class ChalkSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ChalkThemeDef? theme;
  const ChalkSlider(
      {super.key, required this.value, required this.onChanged, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? ChalkThemes.byId('classic');
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 6,
        activeTrackColor: t.chalkAccent,
        inactiveTrackColor: t.boardDeep,
        thumbShape: _ChalkThumb(t),
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: Slider(value: value, onChanged: onChanged),
    );
  }
}

class _ChalkThumb extends SliderComponentShape {
  final ChalkThemeDef t;
  const _ChalkThumb(this.t);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(26, 26);

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final canvas = context.canvas;
    canvas.drawCircle(
        center + const Offset(0, 2),
        12,
        Paint()..color = Colors.black.withValues(alpha: 0.6));
    canvas.drawCircle(
        center,
        11,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.5),
            radius: 1.0,
            colors: [t.chalk, t.chalkAccent, t.frameMid],
          ).createShader(Rect.fromCircle(center: center, radius: 11)));
  }
}

/// Small helper: a labeled settings row.
class SettingRow extends StatelessWidget {
  final String label;
  final Widget control;
  final ChalkThemeDef? theme;
  const SettingRow(
      {super.key, required this.label, required this.control, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? ChalkThemes.byId('classic');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: t.boardDeep.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: t.chalkAccent.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: School.body(16, theme: t))),
          control,
        ],
      ),
    );
  }
}
