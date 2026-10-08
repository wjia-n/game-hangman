import 'package:flutter/material.dart';
import 'package:wajiha_game_core/wajiha_game_core.dart';
import 'game_screen.dart';

void main() => runApp(const HangmanApp());

class HangmanApp extends StatelessWidget {
  const HangmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GameShell(
      variant: ShellVariant.neonArcade,
      title: 'Hangman',
      tagline: 'Guess the word before the stick figure runs out of luck! 🪢',
      emoji: '🪢',
      slug: 'hangman',
      howToPlay:
          '• A secret word is picked — the category hint is your lifeline.\n• Tap letters to guess. Right ones fill the blanks!\n• 6 wrong guesses and the drawing is complete… game over for that word.\n• Solve as many of the 6 words as you can. You got this! 🧠',
      playerOptions: const [1],
      supportsBots: false,
      gameBuilder: (ctx, players, cb) => HangmanScreen(players: players, callbacks: cb),
    );
  }
}
