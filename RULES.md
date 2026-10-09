# Hangman — Rules

The schoolhouse edition of the classic word-guessing game. One player, a
secret word, and a chalk figure that fills in with every wrong guess.

## 1. Objective
Guess the hidden word before the chalk figure is fully drawn. Solve as many
words as you can in a run and build a streak.

## 2. Setup
1. The player picks a difficulty (Easy 3–5 letters, Medium 6–8, Hard 9–12 —
   Hard is Pro), a pace (Relaxed or Timed), and a run length (3, 6, or
   9 words — 9-word runs are Pro).
2. The engine draws that many words from the difficulty's word bank, shuffled,
   with no repeats inside a run.
3. Each word shows its category as a hint (Animals, Food, Space, Nature,
   Sports, Music).
4. Wrong-guess budget per word depends on difficulty: **Easy 8**, **Medium 6**,
   **Hard 5**. The classic six parts are head, body, left arm, right arm,
   left leg, right leg; the Easy tier adds a chalk cap and a scarf for
   misses 7–8.

## 3. Turn order
Solo game. The player taps one letter at a time, in any order they like.
After each guess the engine re-arms the guessing phase (correct guess that
doesn't finish the word) or moves to the next word (solved/failed word).

## 4. Legal moves
- Tap any unguessed A–Z letter while the engine is in the guessing phase.
- Correct letters are revealed in every position they occur, with a
  staggered flip-in animation.
- Guessing continues until the word is complete or the wrong-guess budget
  (or the clock) runs out.

## 5. Illegal moves
- Tapping a letter that was already guessed: ignored with an "invalid" sound.
- Tapping during letter-reveal, word-settle, word-dealing, or pause:
  ignored — input is locked outside the guessing phase by construction.
- Non A–Z input is never accepted.

## 6. Captures
Not applicable — there are no opposing pieces.

## 7. Special rules
- **Timed mode:** each word has a countdown (Easy 75s, Medium 90s, Hard 120s).
  The clock ticks audibly under 10 seconds. At 0 the word is failed and the
  answer is revealed — same as 6 wrong guesses.
- **Wrong-guess budget:** reaching the tier's miss budget (Easy 8, Medium 6,
  Hard 5) fails the word; the answer is revealed.
- **Streak:** consecutive solved words build a streak. A failed word resets
  the streak to 0. The run's best streak is recorded.
- **Pause:** freezing mid-word stops the clock and all phase timers; resume
  re-arms them exactly where they left off.

## 8. Scoring
- +1 star per solved word.
- Run score = words solved out of words played (e.g. 4/6).
- Lifetime stats: runs played, words solved, best streak, perfect runs.

## 9. Winning conditions
- **Word:** reveal every letter before 6 wrong guesses (and before the clock
  in Timed mode).
- **Run:** a run is "cleared" when every word in it is solved. There is no
  final boss — the reward is the score, the streak, and the bragging rights.

## 10. Draw conditions
Not applicable — every word ends solved or failed; every run ends with a
score.

## 11. AI strategy
Not applicable — solo game, no opponents. Difficulty comes from word length
and (in Timed mode) the clock.

## 12. Edge cases
- Words never repeat inside a run; the bank is far larger than the longest
  run (9), so repeats across runs are rare and harmless.
- All words are plain A–Z (no hyphens, apostrophes, or accents), so every
  letter is guessable from the keyboard.
- Backgrounding mid-word: the engine pauses; the watchdog re-arms timers on
  resume — the word can never be lost or stuck.
- Timer expiry and the final allowed wrong guess on the same frame: whichever the
  engine processes first fails the word; the other is a no-op because the
  phase has already moved to word-settle.

## 13. Test cases
1. Correct guess reveals all positions of that letter and keeps the guessing
   phase open.
2. Wrong guess increments the wrong counter and draws the next figure part.
3. Re-tapping a guessed letter is ignored (invalid event, no state change).
4. The final allowed wrong guess fails the word, reveals the answer, then deals
   the next word after a beat.
5. Completing the last letter solves the word, increments the score and the
   streak, then deals the next word after a beat.
6. Failing a word resets the streak; solving words in a row builds it.
7. Timed mode: the clock ticks down; at 0 the word fails and the answer is
   revealed.
8. After the last word, the run-over panel shows with the final score.
9. Restart resets score, streak, and word index and deals a fresh run.
10. Pause freezes timers; resume continues the same word with the same clock.
