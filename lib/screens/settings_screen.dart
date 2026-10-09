import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../theme/chalk_themes.dart';
import '../theme/schoolhouse.dart';

/// Settings: music/SFX toggles, volume, lifetime stats.
class SettingsScreen extends StatelessWidget {
  final SchoolAudio audio;
  final SchoolSettings settings;
  const SettingsScreen(
      {super.key, required this.audio, required this.settings});

  ChalkThemeDef get _t => ChalkThemes.byId(
        settings.themeId,
        custom: settings.customTheme,
      );

  @override
  Widget build(BuildContext context) {
    final t = _t;
    return ChalkBackdrop(
      theme: t,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: t.chalk),
            onPressed: () {
              audio.click();
              Navigator.of(context).pop();
            },
          ),
          title: Text('Setup', style: School.display(22, theme: t)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: settings,
            builder: (_, _) => ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              children: [
                Text('Sound', style: School.label(15, theme: t)),
                const SizedBox(height: 6),
                SettingRow(
                  theme: t,
                  label: 'Music',
                  control: ChalkToggle(
                    theme: t,
                    value: settings.musicOn,
                    onChanged: (v) {
                      audio.click();
                      settings.setMusic(v);
                      audio.configure(
                        musicOn: v,
                        sfxOn: settings.sfxOn,
                        volume: settings.volume,
                      );
                    },
                  ),
                ),
                SettingRow(
                  theme: t,
                  label: 'Sound effects',
                  control: ChalkToggle(
                    theme: t,
                    value: settings.sfxOn,
                    onChanged: (v) {
                      settings.setSfx(v);
                      audio.configure(
                        musicOn: settings.musicOn,
                        sfxOn: v,
                        volume: settings.volume,
                      );
                      audio.click();
                    },
                  ),
                ),
                SettingRow(
                  theme: t,
                  label: 'Volume',
                  control: SizedBox(
                    width: 150,
                    child: ChalkSlider(
                      theme: t,
                      value: settings.volume,
                      onChanged: (v) {
                        settings.setVolume(v);
                        audio.configure(
                          musicOn: settings.musicOn,
                          sfxOn: settings.sfxOn,
                          volume: v,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Your records', style: School.label(15, theme: t)),
                const SizedBox(height: 6),
                _StatCard(theme: t, rows: [
                  ('Runs played', '${settings.gamesPlayed}'),
                  ('Words solved', '${settings.wordsSolved}'),
                  ('Best streak', '${settings.bestStreak}'),
                  ('Perfect runs', '${settings.runsCleared}'),
                ]),
                const SizedBox(height: 18),
                Text('About', style: School.label(15, theme: t)),
                const SizedBox(height: 6),
                Text(
                  'Hangman — the schoolhouse edition.\nGuess the hidden word before the chalk figure is complete.\n\nMade with care by WAJIHA.',
                  style: School.body(14,
                      theme: t,
                      color: t.chalk.withValues(alpha: 0.75)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final ChalkThemeDef theme;
  final List<(String, String)> rows;
  const _StatCard({required this.theme, required this.rows});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: t.boardDeep.withValues(alpha: 0.6),
        border:
            Border.all(color: t.chalkAccent.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                      child: Text(r.$1, style: School.body(15, theme: t))),
                  Text(r.$2, style: School.label(15, theme: t)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
