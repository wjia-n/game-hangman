import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../theme/chalk_themes.dart';
import '../theme/schoolhouse.dart';

/// Custom chalkboard creator (PRO): pick board, frame, chalk and tile
/// colors. Persisted as ARGB ints.
class CustomThemeScreen extends StatelessWidget {
  final SchoolAudio audio;
  final SchoolSettings settings;
  const CustomThemeScreen(
      {super.key, required this.audio, required this.settings});

  static const _swatches = [
    0xFF1E3A2B, 0xFF1B2438, 0xFF3A2E1A, 0xFF42202A, 0xFF1E3242, 0xFF2E3440,
    0xFF24382A, 0xFF3E2620, 0xFFE8DCC2, 0xFF33222E, 0xFF2A3A44, 0xFF38281E,
    0xFF5C3A21, 0xFF8A5A2E, 0xFF6E4E2E, 0xFF7A4A22, 0xFF4A3B24, 0xFF4E3420,
    0xFFF5F1E4, 0xFFE8CE7A, 0xFFD99A2B, 0xFF7FB069, 0xFF6FA8D8, 0xFFE07A3C,
    0xFFE08A8A, 0xFF9A7FB8, 0xFFC97B3C, 0xFFA3BE8C, 0xFF8AB4D8, 0xFFC98AB0,
  ];

  static const _labels = {
    'boardDark': 'Board dark',
    'boardMid': 'Board main',
    'boardDeep': 'Board deep',
    'frameDark': 'Frame dark',
    'frameMid': 'Frame main',
    'frameDeep': 'Frame deep',
    'chalk': 'Chalk',
    'chalkAccent': 'Chalk accent',
    'tileFace': 'Tile face',
    'tileEdge': 'Tile edge',
    'ink': 'Ink',
  };

  ChalkThemeDef get _t => settings.customTheme;

  @override
  Widget build(BuildContext context) {
    return ChalkBackdrop(
      theme: _t,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _t.chalk),
            onPressed: () {
              audio.click();
              Navigator.of(context).pop();
            },
          ),
          title:
              Text('My Chalkboard', style: School.display(22, theme: _t)),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {
                audio.click();
                settings.resetCustomColors();
              },
              child: Text('Reset', style: School.label(13, theme: _t)),
            ),
          ],
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: settings,
            builder: (_, _) => ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              children: [
                // Live preview.
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _t.boardMid,
                    border: Border.all(color: _t.frameMid, width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        offset: const Offset(0, 6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final l in 'WORD'.split(''))
                          Container(
                            width: 30,
                            height: 42,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 3),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: _t.tileFace,
                              border: Border(
                                bottom: BorderSide(
                                    color: _t.tileEdge, width: 3),
                              ),
                            ),
                            child: Text(l,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: _t.ink,
                                  fontFamily: 'serif',
                                )),
                          ),
                        const SizedBox(width: 8),
                        Text('chalk',
                            style: School.display(22, theme: _t)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                for (final key in _labels.keys) ...[
                  Text(_labels[key]!,
                      style: School.label(13, theme: _t)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final argb in _swatches)
                        GestureDetector(
                          onTap: () {
                            audio.click();
                            settings.setCustomColor(key, argb);
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(argb),
                              border: Border.all(
                                color: settings.customColors[key] == argb
                                    ? _t.chalk
                                    : Colors.black
                                        .withValues(alpha: 0.35),
                                width:
                                    settings.customColors[key] == argb
                                        ? 3
                                        : 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 10),
                Center(
                  child: ChalkButton(
                    label: 'Use this board',
                    theme: _t,
                    width: 230,
                    onTap: () {
                      audio.click();
                      settings.setTheme('custom');
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
