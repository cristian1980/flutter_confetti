import 'dart:math';
import 'dart:math' as Math;
import 'dart:ui';

import '../flutter_confetti.dart';

class ConfettiPhysics {
  double wobble;
  double wobbleSpeed;
  double velocity;
  double angle2D;
  double tiltAngle;
  Color color;
  double decay;
  double drift;
  double gravity;
  double scalar;
  double ovalScalar;
  double wobbleX;
  double wobbleY;
  double tiltSin;
  double tiltCos;
  double random;
  bool flat;

  int totalTicks;

  double progress = 0;
  bool get finished => progress >=  1.0;

  double x = 0;
  double y = 0;
  double x1 = 0;
  double x2 = 0;
  double y1 = 0;
  double y2 = 0;

  // Optional: for time-based tracking
  double _elapsedTime = 0;
  double? _durationInSeconds; // set lazily from totalTicks

  ConfettiPhysics(
      {required this.wobble,
        required this.wobbleSpeed,
        required this.velocity,
        required this.angle2D,
        required this.tiltAngle,
        required this.color,
        required this.decay,
        required this.drift,
        required this.random,
        required this.tiltSin,
        required this.wobbleX,
        required this.wobbleY,
        required this.gravity,
        required this.ovalScalar,
        required this.scalar,
        required this.flat,
        required this.tiltCos,
        required this.totalTicks});

  factory ConfettiPhysics.fromOptions(
      {required ConfettiOptions options, required Color color}) {
    final radAngle = options.angle * (pi / 180);
    final radSpread = options.spread * (pi / 180);

    return ConfettiPhysics(
        wobble: Random().nextDouble() * 10,
        wobbleSpeed: min(0.11, Random().nextDouble() * 0.1 + 0.05),
        velocity: options.startVelocity * 0.5 +
            Random().nextDouble() * options.startVelocity,
        angle2D:
        -radAngle + (0.5 * radSpread - Random().nextDouble() * radSpread),
        tiltAngle: (Random().nextDouble() * (0.75 - 0.25) + 0.25) * pi,
        color: color,
        decay: options.decay,
        drift: options.drift,
        random: Random().nextDouble() + 2,
        tiltSin: 0,
        tiltCos: 0,
        wobbleX: 0,
        wobbleY: 0,
        gravity: options.gravity * 3,
        ovalScalar: 0.6,
        scalar: options.scalar,
        flat: options.flat,
        totalTicks: options.ticks);
  }


// Define a target FPS that your original tick-based system was designed for.
// 60 is a common and safe assumption.
  static const double TARGET_FPS = 60.0;

  // New time-based update with deltaTime in seconds
  updateWithDelta(double deltaTime) {
    deltaTime = max(0.001, deltaTime); // Clamp to 1ms minimum
    _elapsedTime += deltaTime;

    // Assume 60 FPS = 1 tick per ~0.0167 seconds
    _durationInSeconds ??= totalTicks / 60.0;

    // Approximate equivalent ticket count
    progress = clampDouble(_elapsedTime / _durationInSeconds!, 0.0, 1.0);

    if (progress >= 1.0) {
      return; // No update needed if already finished
    }

    // Create a scale factor. If running at 60fps, deltaTime is ~1/60s and timeScale is ~1.0.
    // If running at 30fps, deltaTime is ~1/30s and timeScale is ~2.0, applying the physics twice as hard to catch up.
    double timeScale = deltaTime * TARGET_FPS;

    // POSITION UPDATE
    // The velocity and forces are now applied proportionally to the elapsed time.
    x += (Math.cos(angle2D) * velocity + drift) * timeScale;
    y += (Math.sin(angle2D) * velocity + gravity) * timeScale;

    // VELOCITY DECAY
    // This is an exponential decay. To make it framerate-independent,
    // we use pow() to apply the decay over the time-scaled interval.
    if (decay > 0.0 && decay < 1.0) {
      velocity *= Math.pow(decay, timeScale);
    }

    if (flat) {
      wobble = 0;
      wobbleX = x + (10 * scalar);
      wobbleY = y + (10 * scalar);

      tiltSin = 0;
      tiltCos = 0;
      random = 1;
    } else {
      // WOBBLE & TILT UPDATES
      // These angular velocities are also scaled by time.
      wobble += wobbleSpeed * timeScale;
      wobbleX = x + 10 * scalar * Math.cos(wobble);
      wobbleY = y + 10 * scalar * Math.sin(wobble);

      tiltAngle += 0.1 * timeScale;
      tiltSin = Math.sin(tiltAngle);
      tiltCos = Math.cos(tiltAngle);

      // This random value is reset each frame, not accumulated, so it doesn't need scaling.
      random = Random().nextDouble() + 2;
    }

    // These final calculations depend on the updated values above.
    x1 = x + random * tiltCos;
    y1 = y + random * tiltSin;
    x2 = wobbleX + random * tiltCos;
    y2 = wobbleY + random * tiltSin;
  }


  kill() {
    progress = 1.0;
  }
}