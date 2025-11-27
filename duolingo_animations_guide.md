# Duolingo-Style Animations Guide 🎨

This guide shows you how to create Duolingo-inspired animations in Flutter.

## Key Duolingo Animation Characteristics

1. **Playful & Bouncy** - Uses elastic/spring physics
2. **Celebratory** - Confetti, scale bounces, and color bursts
3. **Smooth Transitions** - Gentle easing curves
4. **Attention-Grabbing** - Subtle wobbles and pulses
5. **Rewarding** - Success animations with visual feedback
6. **Character Animations** - Expressive mascot movements

## Common Animation Patterns

### 1. **Bounce/Spring Animation**
Used for: Button presses, correct answers, achievements
- Quick scale up, then bounce back with overshoot
- Curve: `Curves.elasticOut` or custom spring

### 2. **Shake Animation**
Used for: Wrong answers, errors
- Horizontal shake (left-right-left)
- Quick duration (300-500ms)

### 3. **Pulse/Heartbeat**
Used for: Streak flames, notifications, attention
- Scale up and down repeatedly
- Subtle (1.0 to 1.1 scale)

### 4. **Confetti/Celebration**
Used for: Level completion, milestones
- Particles falling from top
- Random colors and rotations

### 5. **Slide & Fade**
Used for: Screen transitions, new content
- Combine opacity and position
- Staggered for multiple items

### 6. **Progress Fill**
Used for: XP bars, lesson progress
- Animated width or clip
- Often with a shimmer effect

### 7. **Character Expressions**
Used for: Duo the owl reactions
- Eye blinks, head tilts, jumps
- State-based (happy, sad, excited)

## Implementation Examples

See the following files for complete implementations:
- `duolingo_animations_demo.dart` - Interactive demo screen
- `duolingo_animation_widgets.dart` - Reusable animation widgets

## Tools & Packages

### Recommended Packages:
```yaml
dependencies:
  flutter_animate: ^4.5.0  # Easy declarative animations
  lottie: ^3.0.0           # For complex JSON animations
  rive: ^0.13.0            # For interactive character animations
  confetti: ^0.7.0         # For celebration effects
```

### Animation Controllers
- Use `AnimationController` for custom animations
- Use `TweenAnimationBuilder` for simple state-based animations
- Use `AnimatedContainer` for property animations

## Best Practices

1. **Keep it Short** - Most animations should be 200-500ms
2. **Use Curves** - Never use `Curves.linear`, prefer `easeOut`, `elasticOut`, `bounceOut`
3. **Stagger Delays** - For lists, add 50-100ms delay between items
4. **Feedback First** - Animation should feel responsive (start immediately)
5. **Don't Overdo It** - Too many animations = distraction
6. **Test Performance** - Use `RepaintBoundary` for complex animations

## Color Palette (Duolingo-inspired)

```dart
// Success/Correct
Color(0xFF58CC02) // Bright green

// Error/Wrong
Color(0xFFFF4B4B) // Bright red

// Primary/Accent
Color(0xFF1CB0F6) // Bright blue

// Warning
Color(0xFFFFC800) // Bright yellow

// Background
Color(0xFFF7F7F7) // Light gray
```

## Animation Timing Reference

| Animation Type | Duration | Curve |
|---------------|----------|-------|
| Button Press | 100ms | easeOut |
| Correct Answer | 400ms | elasticOut |
| Wrong Answer (Shake) | 500ms | easeInOut |
| Screen Transition | 300ms | easeOutCubic |
| Celebration | 1000ms | easeOut |
| Pulse (loop) | 1500ms | easeInOut |
| Progress Bar | 800ms | easeOut |

## Examples in This Project

Check out these files to see Duolingo-style animations in action:
- Timer setup screen with smooth wheel animations
- Focus timer with progress animations
- (Add more as you implement them)
