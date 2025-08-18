# Focus Journey — App Flow & Implementation Guide

> **Context**: This is a story-driven focus timer app that converts user focus sessions into narrative progress. A user's Pomodoro/timer sessions award XP and visual progress that advances in a "journey" (mountain path + character) and in other visual metaphors (plant growth, character cards). Illustrations should be in the "fabulous" dreamy style. Key interactions include: hold-to-commit animations, claim-XP after sessions, journey nodes (locked/complete/current), greyscale-for-unlocked-areas, and gentle, emotionally-guided micro-interactions. The app will be built in Flutter (Android Studio) and needs offline/resilient timer behavior, performant image & animation delivery (Rive/Lottie/JSON preferred over MP4 where possible), clear state handling, and product analytics.

## 1. High-level Concept & Goals

### Primary Promise
Turn focused time into meaningful, emotionally-rich progress (character growth / journey).

### Retention Engine
- **Immediate micro-feedback** (loader, pulses)
- **Reward loops** (XP, level unlocks)
- **Social proof** (optional)
- **Visible progress** (= "I'm closer to the next win")

### Polish
Use subtle animations, haptics, sound cues, and "fabulous" images to make using the app feel calming and rewarding (Emotional Design principles).

### Platform
Flutter (single codebase). Target Android first, iOS later (or both simultaneously).

---

## 2. Primary User Flows

### A. First-time Onboarding

1. **Age Input**: Ask age (short input), then optionally time spent unproductively per day with card choices (0–1 hr, 1–2 hr, 3–4 hr, 4–5 hr, 5+ hr).

2. **Life-lost Calculation**: Show "life-lost" calculation (e.g., "At this rate you'd lose X years of life to passive screen time").

3. **Freedom Switch**: Present the Freedom Switch (toggle + animated onboarding).

4. **Character Selection**: Offer to pick/assign a character (name, avatar). Default characters: David / Themba / custom.

### B. Timer Session

- User chooses session length (preset or custom). Start button triggers timer state (Running).
- While running, show focus screen (plant grows, progress curvature, swipeable "Surrender").
- On completion → "Claim XP" microflow (small celebratory animation). XP is added to user account / character.

### C. Journey Screen

- Tap Journey in bottom nav → mountain vector-based map.
- Nodes shown along a path. Tapping a node opens level modal (three images + story text + unlock details).
- Node states: Completed (full color), Current (glow + animated avatar), Locked (grayscale + lock icon).
- Greyscale/colour reveal of mountain above current level.

### D. Character / Level Interactions

- XP accumulation triggers level-up animations and unlocks story cards.
- Option to spend XP (optional) to unlock certain vanity items or earlier story reveal.

---

## 3. Screens & Components (Detailed)

> **Note**: Use `go_router` or `beamer` in Flutter for routing; state via `riverpod` or `bloc` depending on team preference.

### Screen List (with required subcomponents)

#### 1. Onboarding
- Age input (large numeric input)
- Unproductive hours card stack (tap one to select)
- "Life lost" calculation view
- Freedom switch animation + "I will commit" CTA

#### 2. Home / Timer
- Big circular timer (central)
- Timer presets row (10, 25, 40, 60, custom)
- Mini-summary card (streak, XP)
- Bottom nav

#### 3. Focus Screen (inspired by plant UI)
- Full-screen card with background (fabulous-style composition)
- Plant illustration, curved progress line (vector)
- Timer text
- Surrender swipeable CTA (bright theme color: yellow)
- Microfeedback: plant growth states + particle spark on milestones

#### 4. Journey Screen (mountain)
- Background vector mountain, path layer, node layer
- Node widget (3 states)
- Mask/overlay for greyscale reveal above current progress
- Character avatar position (on platform node)

#### 5. Level Modal+
- Carousel of 3 fabulous-style images
- Short narration text
- Actions: Play small cutscene, Use XP (if applicable), Close

#### 6. Profile / Settings
- Stats (XP, levels, streaks)
- Art gallery (unlocked images)
- Theme & accessibility controls

#### 7. Store / Rewards (optional)
- Cosmetic packs, story packs

---

## 4. Timer & Session State Machine

```
IDLE -> RUNNING -> PAUSED -> COMPLETED -> CLAIMABLE -> CLAIMED
                 ↳ CANCELLED (SURRENDER)
```

### State Descriptions

- **IDLE**: Timer ready, user sets length.
- **RUNNING**: Ticking; UI shows growth animation timeline. Use Ticker / Timer in Flutter.
- **PAUSED**: User paused; animation freezes.
- **COMPLETED**: Timer reached 0; show completion animation + claim button.
- **CLAIMABLE**: User can claim XP; hold-to-claim or tap-then-collect.
- **CLAIMED**: XP added and persisted.

### Surrender Flow
User swipes the surrender box; confirm with a small animation (plant wilts), mark session as cancelled → award minimal/no XP + reset streak (or partial penalty per your product decision).

> **Important**: Timer must survive background/lock (see "Offline / platform" section).

---

## 5. XP, Level & Story Mechanics (Rules + Formulas)

### Basic Rules

- **XP per minute** = baseXP = 1 (example)
- **Session XP** = round(session_minutes * baseXP * modifiers)

### Modifiers

- **Completion bonus**: +20% for finishing full session
- **Streak bonus**: +5% per day of active streak (cap at +50%)
- **No-surrender bonus**: apply completion only if not surrendered

### Example

```
25 min pomodoro: base XP = 25
Completion bonus = 25 * 0.2 = 5
Streak (3 days) = 25 * 0.15 = 3.75
Total XP = 25 + 5 + 3.75 = ~34 XP
```

### Level Thresholds

Use non-linear thresholds so early levels are fast and later ones take more XP:

- Level 1 → 2: 100 XP
- Level 2 → 3: 250 XP
- Level 3 → 4: 500 XP

**Formula**: `threshold(L) = floor(base * (growthFactor^L))` e.g. `100 * 1.6^L`

### Ways to Spend/Use XP

- **Automatic leveling**: XP accumulates, character levels up, story unlocks
- **Optional currency use**: XP can be spent on cosmetics or unlocking optional story branches
- **Energy mechanic** (optional): Attempting a major story requires "energy" or XP spend

---

## 6. Journey UI: Vector Path, Nodes, and Reveal Mechanics

### Implementation Approaches (Flutter)

#### 1. CustomPainter Path + Node Overlay
- Draw mountain background as image layer
- Use CustomPainter to draw a bezier path for the walkway
- Precompute node positions along the path (list of Offsets)
- Draw the curved progress reveal by drawing the colored path segment up to current progress value

#### 2. Vector (SVG) + Marker Map
- Put scalable SVG mountain with path marker points defined in SVG coordinates
- Use `flutter_svg` to render and overlay clickable transparent nodes
- To reveal greyscale above current level: overlay a ColorFiltered widget + ShaderMask gradient

#### 3. Rive Interactive Scene
- If you prefer a single vector asset with interactive markers and animations, export a Rive scene
- Rive is ideal for complex vector interactions and runs very well in Flutter

### Greyscale Reveal Technique (Practical)

1. Keep full-color mountain image in a top layer
2. Place a greyscale version beneath it
3. Use a ClipPath or a ShaderMask to reveal color up to y of current progress
4. Or apply ColorFiltered to the top area: `ColorFiltered(colorFilter: ColorFilter.matrix(grayMatrix))`
5. Animate the mask smoothly when progress changes

### Node States & Visuals

- **Locked**: grayscale icon, reduced opacity, lock badge
- **Current**: full color, glow ring (animated), small bounce animation
- **Complete**: full color + small check mark + subtle sparkle particle

---

## 7. Assets & Formats (Designer Handoff)

### Per-level Assets

- **3 "fabulous" image scenes** (PNG or WebP, 2048 × 2048 px or vector where possible) — no embedded text
- **Thumbnail** 512 × 512 or 720 × 480 for gallery
- **Rive/Lottie file** for small cutscene or avatar micro-animation (optional)

### Sprite + UI Assets

- Rounded card backgrounds (9-patch or scalable)
- Icons as SVG (vector)
- Progress curve vector (SVG) and a small stroke path asset
- Placeholder and blurred versions for progressive loading

### Naming & Metadata

```
level_{n}scene{1..3}.webp
character_{id}_avatar.riv / .json
mountain_bg_layer_color.png, _greyscale.png, _path.svg
```

### File Size Guidance

- **Images**: compress to WebP, aim < 200KB for thumbnails, < 600–900KB for full scenes
- **Rive files**: typically small (tens of KBs to a few hundred KBs)
- **Avoid many MP4s** — only use for rare cinematic cutscenes; prefer vector animations

---

## 8. Animations & Implementation (Rive/Lottie + Flutter Tips)

### Use-case Guidance

- **Micro-interactions & UI transitions**: `flutter_animate` or `implicit_animation` + `AnimatedContainer`
- **Interactive vector animation** (button expands, plant grows): Rive preferred — supports interaction (press/hold) and state machines
- **Loader/response dots and microfeedback**: small Lottie JSON or Flutter animated widgets

### Hold-to-expand Button (Your "Fingerprint / Hold" Effect)

Create a Rive file with a state machine:
- `idle`, `pressing`, `complete`

When user presses and holds, feed the `isPressing` boolean and `holdProgress` float to the Rive state machine — it expands the inner circle to a larger ring and reveals text ("Almost there") when `holdProgress >= threshold`.

In Flutter, use `GestureDetector` with `onLongPressStart` / `onLongPressEnd` + timed progress feed.

**Alternative (pure Flutter)**: animate scale + overlay radial gradient using `AnimatedBuilder`.

### Plant Growth

Prefer Rive for morphing vector plant or step-based sprite changes (grow stage 0..N). Trigger certain frames on session progress milestones.

---

## 9. Data Model & APIs (Suggested)

### Minimal Entities

```dart
User {
  id,
  name,
  age,
  xp_total,
  level,
  streak_days,
  current_character_id,
  unlocked_levels: [levelId],
  last_session: { time, duration, status }
}

Session {
  id,
  user_id,
  started_at,
  duration_minutes,
  status, // RUNNING, COMPLETED, SURRENDERED
  xp_awarded
}

Level {
  id,
  index,
  required_xp,
  images: [url],
  unlocked_at
}
```

### Suggested Endpoints (REST)

```
POST /auth/login
GET /user/:id
POST /session/start { userId, duration }
POST /session/complete { sessionId } => returns xp awarded
POST /xp/claim { sessionId }
GET /journey returns mountain layout and node states
POST /level/unlock (if you allow spending XP)
```

### Offline-first Design

Use local store (Hive/SQLite) as primary and sync to server when online. Store session start timestamp; compute elapsed on completion based on server time if needed (to prevent tampering).

---

## 10. Offline / Background Timer & Platform Concerns

### Android

If you want the timer to continue when the app is backgrounded, use a foreground service (Android). Flutter plugin options: `flutter_foreground_task` or platform channels to native service. Handle Doze mode by using `AlarmManager` or scheduling exact timers carefully.

### iOS

Background timers are limited; consider saving start timestamp when app goes backgrounded and compute elapsed next foreground. Use local notifications to nudge user.

### Strategy Recommended

**Simpler & robust**: Save `startTimestamp` when session starts and compute `elapsed = now - start` whenever needed (on resume). Use local notifications to remind end-of-session. Only use a background service for continuous UI audio/precise intervals if necessary.

---

## 11. Performance & Optimization Checklist

- Use `RepaintBoundary` for heavy animated widgets
- Use vector Rive for many UI animations (better than frame-based mp4)
- Lazy-load large images and show blurred placeholders. Use `cached_network_image`
- Use progressive images (small → large)
- Avoid huge single-layer shadows; prefer subtle elevations in Flutter
- Profile UI with Flutter DevTools (engine frames, raster cache)
- Limit widget rebuilds using `const` widgets and state scoping (`riverpod` providers or BLoC)
- Optimize asset sizes and use WebP/AVIF where possible

---

## 12. Accessibility, Localization & Testing

### Accessibility
- Use semantic labels on all tappable components
- Ensure color contrast: test for yellow/white theme (some yellow shades can be low contrast)
- Large tap targets (>48dp) for important CTAs
- Support screen readers, haptic feedback, and adjustments (text scale)

### Localization
- Localize copy and store image alt-text keys for translations

### Testing
- **Unit tests**: timer logic, XP calculation, unlock logic
- **Integration tests**: onboarding -> timer -> claim -> journey progression

---

## 13. Analytics, Events & Retention Metrics

### Important Events

```
onboarding_completed (age, unproductive_hours)
session_started (duration, timer_preset)
session_completed (duration, xp_awarded)
session_surrendered
xp_claimed
level_unlocked (level_id)
journey_node_tapped (node_id)
freedom_switch_toggled
```

### KPIs

- Daily active users (DAU), weekly (WAU)
- Retention D1/D7/D30
- Average sessions per user / day
- Streak length distribution
- CLV / monetization conversion (if store exists)

---

## 14. Milestones & Developer Checklist

### Phase 0 — Discovery & Design
- [ ] Finalize color palette, typography, and emotional design rules
- [ ] Designer: deliver all art assets for level 0 and 1 (3 images each, thumbnails)
- [ ] Provide Rive files for hold-to-commit animation and plant growth basics

### Phase 1 — MVP (Core)
- [ ] Build onboarding flows (age + unproductive time)
- [ ] Implement timer view (UI + start/pause/complete logic)
- [ ] Implement session claim XP logic + local persistence (Hive)
- [ ] Implement focus screen (static plant + curved progress line)
- [ ] Implement Journey screen skeleton (mountain background + node overlay positions)

### Phase 2 — Polish & Animations
- [ ] Integrate Rive animations (button hold, plant morph)
- [ ] Add masking greyscale reveal for mountain
- [ ] Add level modal with 3-image carousel
- [ ] Add sound/haptics and microinteractions

### Phase 3 — Sync & Analytics
- [ ] Add server sync + analytics instrumentation
- [ ] Add background handling and push notifications for sessions
- [ ] Performance and accessibility sweep

---

## 15. Appendix: Code Snippets & Pseudocode

### XP Formula (Pseudocode)

```dart
double computeXP(int minutes, int streakDays, bool completed, bool surrendered) {
  double xp = minutes * 1.0;
  if (completed && !surrendered) {
    xp *= 1.2; // completion bonus
  }
  double streakBonus = min(0.05 * streakDays, 0.5); // capped 50%
  xp *= (1 + streakBonus);
  return xp.round();
}
```

### Greyscale Reveal Idea (Flutter Outline)

```dart
Stack(
  children: [
    Image.asset('mountain_color.png'),
    // greyscale layer on top, masked by clip path
    ClipPath(
      clipper: revealClipper(progressFraction),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(_greyscaleMatrix),
        child: Image.asset('mountain_color.png'),
      ),
    ),
    // nodes overlay
    ...nodes.map((n) => Positioned(left: n.x, top: n.y, child: NodeWidget(n)))
  ],
)
```

### Hold-to-expand (Flutter + Rive Pseudo Integration)

Feed `holdProgress` from Flutter `Timer.periodic` into Rive state machine parameter. Trigger complete output when `holdProgress >= threshold`.

---

## Design Tokens (Example Color Palette)

```css
primaryYellow — #FFD24A (use for CTA / surrender swipe)
accentPlantGreen — #6BCB6B (plant only)
bgWhite — #FFFFFF (main backgrounds)
textDark — #1F2D3D (primary body)
mutedGray — #A6B2BD (subtext)
```

> **Ensure WCAG contrast** for text over backgrounds.

---

## Final Notes & Recommended Next Steps

### 1. XP Model Decision
Decide XP model (auto-leveling vs spendable currency). **Recommendation**: auto-leveling + optional small cosmetic shop if you want users to feel progress without friction.

### 2. Asset Pipeline
Deliver minimal assets for Level 0 (3 images, 1 Rive for hold/plant). Implement a working arts + animation pipeline early; iterate on visuals after core UX is stable.

### 3. Core Implementation Priority
Implement the timer & claim flow first — it's the app's heartbeat. Once sessions are stable, build the Journey screen and polish visuals.

---

*This document serves as the comprehensive implementation guide for the Focus Journey app. Use it as a reference throughout development and update as requirements evolve.*
