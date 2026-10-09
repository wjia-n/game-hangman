# Hangman — The Schoolhouse Edition

The classic word-guessing game, rebuilt as a cozy schoolhouse: chalkboard,
wooden gallows, chalk letters and paper letter-tiles. By WAJIHA.

Package: `com.gameswajiha.hangman` · Repo: `wjia-n/game-hangman`

## Features

- **Solo word runs** — 3, 6, or 9 words per run (9 is Pro)
- **3 difficulty tiers** — Easy (3–5 letters, 8 misses), Medium (6–8 letters,
  6 misses), Hard (9–12 letters, 5 misses — Pro)
- **Relaxed & Timed modes** — per-word countdown with audible final 10 seconds
- **Animated gallows** — the chalk figure draws part-by-part with a
  sketch-bounce pop; letters flip in with a staggered animation
- **Engine-owned state machine + watchdog** — phases (dealing → guessing →
  letterReveal → wordSettle → runOver); stuck states impossible by
  construction; see RULES.md
- **14 chalkboard themes + 9 chalk styles + custom theme creator** (Pro)
- **Renameable player**, persisted as one order-preserving JSON string
  (`hangman_player_names_json`) — saved on every keystroke
- **Synthesized audio** — menu music + gameplay BGM + chalk/wood/paper SFX,
  cached clips, busy-guard, pause/resume on lifecycle, prewarm on splash
- **Pro screen** — Free-vs-Pro comparison, real Play Billing
  (`hangmanpro` one-time, `hangmancoffee` / `hangmanchocolate` consumable
  tips), graceful when unconfigured
- **Share + in-app review** with the real Play Store URL
- **Splash flow** — WAJIHA company moment → game splash (logo + animated
  loading line + Credits: WAJIHA)

## Build

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

Release signing is wired through the repo's `build.yml` workflow
(`UPLOAD_KEYSTORE_BASE64` / `UPLOAD_KEYSTORE_PASSWORD` / `UPLOAD_KEY_ALIAS` /
`UPLOAD_KEY_PASSWORD` secrets). Store products (`hangmanpro`,
`hangmancoffee`, `hangmanchocolate`) must be created in Play Console —
until then the Pro screen shows an honest "available after store setup"
state.
