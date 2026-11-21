# Momo — a happiness companion

**One Happiness Index (0–100) from three inputs you can see: mood
check-ins (40%), daily routines (35%), and budget health (25%).** The
formula is shown in the UI, never hidden. Momo is a small corgi who lives
on your phone — a floating bubble, a home-screen widget, lock-screen
check-ins — and notices how you are doing, kindly, never guilt-trippy.

> **v0.1 — started, not finished.** All 30 screens exist as functional
> routes (mobile + web presentations from one codebase), the index math is
> real and tested, and everything persists locally. Sign-in is local-only
> (no backend yet) and the native widget / lock-screen extension /
> system-level bubble are phase-2 work — each screen says so plainly.
> See [Honest limits](#honest-limits) and [Roadmap](#roadmap).

## What it does

1. **Mood check-in** — 10 questions drawn at random from a bank of 10
   dimensions (sleep, energy, stress, focus, social, movement, mood,
   appetite, calm, outlook). Five answers each, scored 0–4. The mood
   component is the average of your recent check-ins.
2. **Daily routines** — routines you create (wake time, workout, deep
   work, reading, …), followed or missed. The routine component is the
   completion rate over the last 30 days. Streaks **pause, they don't
   punish**: a missed day freezes the streak; the next completed day
   resumes from the frozen value.
3. **Budget planner/tracker** — one monthly plan across spending
   categories, spent vs planned per category, plus a simulator that runs
   the real budget formula on hypothetical numbers ("What if Food were
   $450/mo?").

The three components combine into the Happiness Index:

```
index = mood × 40% + routines × 35% + budget × 25%
```

Bands: **Thriving** 80–100 · **Content** 60–79 · **Low** 40–59 ·
**Struggling** below 40. The band — not the number — is the point: Momo
reacts to the band.

## The formulas

### Mood component

One check-in's score is the mean answer mapped to 0–100
(`mean / 4 × 100`). The mood component is the mean of check-in scores
from the last 7 days. No check-ins yet → no number is invented; the UI
asks for a first check-in.

### Routine component

```
routines = completed slots / (routines × 30 days) × 100
```

over the last 30 days. No routines yet → no number is invented.

### Budget component

```
score = 100 − 48 × max(0, utilization − 0.35) − 15 × overCategories
```

where `utilization = spent / planned` for the month. Spending up to 35%
of the plan costs nothing; past that, each 10% of utilization costs
~5 points; each category over its plan costs 15 points. Clamped 0–100.

## Guest-first, local-first

- **No account needed.** The whole pet works as a guest. An account
  unlocks only two things: sync across devices and read-only friend
  sharing (index + band — never amounts, never answers).
- **On-device only.** All state is one JSON document in
  `shared_preferences`. There is no backend in v0.1 and nothing is
  uploaded. Export (JSON file or clipboard), sign out, and delete-all
  live in Data Controls.
- **Amounts stay hidden.** The widget snapshot and lock-screen prompts
  carry the index + band only — safe for a screenshot, by design.

## Honest limits

Read this before quoting any number from the demo:

- **The seeded numbers are a demo story, not measured data.** First
  launch seeds the V7 design's canonical numbers — index 75 (Content)
  from mood 76, routines 72, budget 78; $2,400/mo plan, $1,936 spent;
  six routines, 5 of 6 done today, a 12-day streak; history 68 → 75.
  They are labelled DEMO wherever they show, and Settings → Demo data
  clears them. The formulas then run on real activity only.
- **The simulator is live, the design mock numbers were static.** The
  V7 mock showed fixed simulator values (Food $450 → 81, …) that don't
  follow one consistent formula. v0.1 computes every simulator row from
  the real budget formula above, so values differ from the mock — and
  are self-consistent instead.
- **Sign-in is local-only.** No email is sent; any 6-digit code verifies
  on-device. "Sync" records the preference locally; there is no server
  yet. Real magic-link email + multi-device sync need a backend
  (phase 2).
- **The companion is in-app in v0.1.** The floating bubble works over
  Momo's own screens; the widget state is ready (index + band only) and
  the lock-screen flow runs the real check-in — but a true system-level
  bubble, home-screen widget, and lock-screen extension need native
  platform code (phase 2). Nothing pretends otherwise.
- **No alarms (yet).** Routine times are labels, not scheduled
  notifications. Nudges are in-app only in v0.1.

## Verification

Flutter/Dart is not installed on the build VM, so the Dart test suite is
**authored, not yet run** — run `flutter test` on a machine with Flutter
to execute it. The suite covers:

- **Happiness Index math**: the seeded 76/72/78 → 75.1 → 75, per-input
  contributions (30.4 / 25.2 / 19.5), rounding, and every band boundary.
- **Budget formula**: the seeded month scores 78, the 35% free band,
  the 15-point over-category penalty, clamping, and both simulator
  directions.
- **Check-ins**: the 10-dimension bank, deterministic shuffled draws,
  scoring extremes, and the null-when-empty rule.
- **Routines**: streak growth, the pause rule (a miss never resets to
  zero), the 30-day completion rate, and JSON round-trips.
- **Controller**: the seeded demo computes to 75/Content end-to-end,
  check-in submission moves the mood component, toggling a routine grows
  its streak, expenses move spent, clearing demo data leaves no invented
  index, the local sign-in flow, and JSON export validity.

```sh
flutter test     # Dart test suite
flutter analyze  # lints
```

## Run the app

```sh
flutter pub get
flutter run            # mobile / desktop
flutter run -d chrome  # web
```

## Layout

```
lib/
  main.dart                  Entry point (loads state, seeds demo on first launch)
  app.dart                   App shell + all 30 routes + floating bubble
  app_routes.dart            Route names + screen atlas labels
  core/
    constants.dart           Formula weights, bands, demo fixture, currencies
    theme.dart               V7 palette (night-sky cocoa, coral→peach CTAs)
    format.dart              Money / date formatting
  engine/                    Pure logic — no Flutter state, fully tested
    happiness.dart           Index formula, bands
    checkin.dart             Question bank, random draw, scoring
    routines.dart            Routine model, streaks (pause, don't punish)
    budget.dart              Categories, expenses, budget score, simulator
    insights.dart            Insights computed from the user's own numbers
  state/
    momo_state.dart          The whole app state as one JSON document
    momo_controller.dart     ChangeNotifier: derived values + all actions
    momo_scope.dart          InheritedNotifier provider
  services/
    storage_service.dart     KeyValueStore (prefs in app, memory in tests)
    export_service*.dart     JSON export (native file / web download / stub)
    companion_service.dart   Widget-safe snapshot (index + band, no amounts)
  widgets/
    momo_avatar.dart         Momo the corgi (SVG logo, mood ring, bobbing)
    index_ring.dart          Animated Happiness Index ring
    glass_card.dart          Glass cards, kickers, gradient buttons, stat tiles
    formula_card.dart        The formula, shown in the open
    app_scaffold.dart        Adaptive shell (mobile + desktop sidebar) + TwoColumn
    budget_widgets.dart      Category bars, simulator rows
    momo_bubble.dart         Draggable in-app companion bubble
  screens/                   30 screens (01 splash → 30 data controls)
    splash_screen.dart             onboarding_a_screen.dart
    onboarding_b_screen.dart       add_details_screen.dart
    home_screen.dart               checkin_screen.dart
    checkin_result_screen.dart     routines_screen.dart
    routine_detail_screen.dart     overlay_bubble_screen.dart
    widget_screen.dart             lock_screen_screen.dart
    bands_screen.dart              budget_screen.dart
    insights_screen.dart           history_screen.dart
    goal_setter_screen.dart        milestone_screen.dart
    settings_screen.dart           privacy_screen.dart
    welcome_screen.dart            guest_mode_screen.dart
    sign_in_screen.dart            create_account_screen.dart
    verify_screen.dart             upgrade_prompt_screen.dart
    migrate_screen.dart            account_screen.dart
    connected_screen.dart          data_controls_screen.dart
test/                        Dart test suite (flutter test)
assets/logos/                Momo logo system (SVG): icon, horizontal,
                             stacked, app-icon. The lockups carry a dark
                             wordmark — shown on a light chip in-app.
web/                         Web entry (index.html, manifest.json)
```

Every route renders both presentations: a mobile layout on narrow
screens and a desktop layout (sidebar shell + wider content) on wide
screens — the 30 mobile + 30 web screens of the V7 design, from one
codebase.

## Roadmap (phase 2)

1. **Dual dark/light themes** — the theme is structured for the swap
   (`AppTheme` gains a second `ThemeData`, the shell a mode toggle).
2. **Backend + real auth** — magic-link email, multi-device sync,
   real share links.
3. **Native companion** — system-level bubble (Android overlay),
   home-screen widget (AppWidget / WidgetKit), lock-screen extension.
4. **Scheduled nudges** — routine-time notifications, Sunday nudge.
5. **Drift/SQLite history** — relational store for check-in and expense
   history as it grows (today: one JSON document in shared_preferences).
6. **Secure storage for secrets** — account tokens move to
   flutter_secure_storage when real auth lands.
7. **Bank sync (opt-in, on-device)** — automatic expense import, with
   the same on-device promise.

## Appendix: CI workflow (add via web UI)

No `.github/workflows/` file is included in this repo (the GitHub App
cannot push workflow files). To add CI, create
`.github/workflows/flutter.yml` in the GitHub web UI with:

```yaml
name: Flutter
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.x'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```
