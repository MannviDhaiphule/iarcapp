import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../app_shell.dart';

/// The animated splash screen shown when the app launches.
class SplashScreen extends StatefulWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _sequenceController;
  late AnimationController _hoverController;
  late AnimationController _propellerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _sequenceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
    _hoverController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    // 10 rotations per second -> 100ms per rotation
    _propellerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100))
      ..repeat();

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _sequenceController,
        curve: const Interval(0.0, 0.5 / 3.0, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _sequenceController,
        curve: const Interval(2.8 / 3.0, 1.0),
      ),
    );

    _sequenceController.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            settings: const RouteSettings(name: '/home'),
            pageBuilder: (_, __, ___) => const AppShell(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _sequenceController.dispose();
    _hoverController.dispose();
    _propellerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      body: AnimatedBuilder(
        animation: _sequenceController,
        builder: (context, child) {
          final fade = _fadeAnimation.value;
          return Opacity(
            opacity: fade,
            child: Stack(
              children: [
                // Radial gradient background
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.colorAccentGlow.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Drone and Text
                Positioned.fill(
                  child: Column(
                    children: [
                      const Spacer(flex: 40),
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _scaleAnimation,
                          _hoverController,
                          _propellerController
                        ]),
                        builder: (context, child) {
                          final scale = _scaleAnimation.value;
                          final hoverY =
                              (_hoverController.value - 0.5) * 16.0; // ±8px

                          if (_sequenceController.value < 0.5 / 3.0) {
                            // Only scale, no hover yet
                            return Transform.scale(
                              scale: scale,
                              child: CustomPaint(
                                size: const Size(120, 120),
                                painter: _DronePainter(
                                  propellerAngle:
                                      _propellerController.value * 2 * math.pi,
                                ),
                              ),
                            );
                          }

                          return Transform.translate(
                            offset: Offset(0, hoverY),
                            child: Transform.scale(
                              scale: 1.0,
                              child: CustomPaint(
                                size: const Size(120, 120),
                                painter: _DronePainter(
                                  propellerAngle:
                                      _propellerController.value * 2 * math.pi,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 48),
                      // Text
                      _GlitchText(
                          sequenceValue: _sequenceController.value * 3.0),
                      const Spacer(flex: 60),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DronePainter extends CustomPainter {
  final double propellerAngle;

  _DronePainter({required this.propellerAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Glow under drone
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.colorAccent.withValues(alpha: 0.15),
          Colors.transparent
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 60));
    canvas.drawCircle(center, 60, glowPaint);

    // Arms
    final armPaint = Paint()
      ..color = AppTheme.colorBorder
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const armLength = 30.0;
    // Draw arms in X shape
    canvas.drawLine(center, center + const Offset(armLength, armLength), armPaint);
    canvas.drawLine(center, center + const Offset(-armLength, armLength), armPaint);
    canvas.drawLine(center, center + const Offset(armLength, -armLength), armPaint);
    canvas.drawLine(center, center + const Offset(-armLength, -armLength), armPaint);

    // Motor circles
    final motorPositions = [
      center + const Offset(armLength, armLength),
      center + const Offset(-armLength, armLength),
      center + const Offset(armLength, -armLength),
      center + const Offset(-armLength, -armLength),
    ];

    final motorFill = Paint()..color = AppTheme.colorSurfaceElevated;
    final motorBorder = Paint()
      ..color = AppTheme.colorAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var pos in motorPositions) {
      canvas.drawCircle(pos, 8, motorFill);
      canvas.drawCircle(pos, 8, motorBorder);

      // Propellers
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(propellerAngle);

      final propPaint = Paint()
        ..color = AppTheme.colorAccent.withValues(alpha: 0.7);
      for (int i = 0; i < 4; i++) {
        canvas.drawOval(
            Rect.fromCenter(center: const Offset(10, 0), width: 16, height: 4),
            propPaint);
        canvas.rotate(math.pi / 2);
      }

      canvas.restore();
    }

    // Body
    final bodyRect = Rect.fromCenter(center: center, width: 40, height: 40);
    final bodyRRect =
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(8));
    final bodyFill = Paint()..color = AppTheme.colorSurface;
    final bodyBorder = Paint()
      ..color = AppTheme.colorAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(bodyRRect, bodyFill);
    canvas.drawRRect(bodyRRect, bodyBorder);

    // Center dot
    final dotPaint = Paint()..color = AppTheme.colorAccent;
    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DronePainter oldDelegate) {
    return oldDelegate.propellerAngle != propellerAngle;
  }
}

class _GlitchText extends StatefulWidget {
  final double sequenceValue; // In seconds (0 to 3.0)

  const _GlitchText({required this.sequenceValue});

  @override
  State<_GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<_GlitchText> {
  final String _targetText = "EDHITHA";
  final List<String> _glitchChars = ['@', '#', '\$', '%', '&', '*', '!', '?'];
  late List<String> _currentChars;
  late List<bool> _resolved;
  Timer? _glitchTimer;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _currentChars = List.filled(_targetText.length, " ");
    _resolved = List.filled(_targetText.length, false);
    _glitchTimer =
        Timer.periodic(const Duration(milliseconds: 60), _updateGlitch);
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    super.dispose();
  }

  void _updateGlitch(Timer timer) {
    if (!mounted) return;

    // Target text starts glitching at 0.8s
    final time = widget.sequenceValue;
    if (time < 0.8) return;

    bool changed = false;

    for (int i = 0; i < _targetText.length; i++) {
      if (_resolved[i]) continue;

      // Each letter starts 100ms after the previous one
      final letterStartTime = 0.8 + (i * 0.1);
      final letterResolveTime = letterStartTime + 0.18; // 3 rapid substitutions

      if (time >= letterResolveTime) {
        _currentChars[i] = _targetText[i];
        _resolved[i] = true;
        changed = true;
      } else if (time >= letterStartTime) {
        _currentChars[i] = _glitchChars[_random.nextInt(_glitchChars.length)];
        changed = true;
      }
    }

    if (changed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we haven't reached 0.8s, don't show text
    if (widget.sequenceValue < 0.8) {
      return const SizedBox(height: 40); // Placeholder to maintain height
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_targetText.length, (index) {
        final char = _currentChars[index];
        final isResolved = _resolved[index];

        return Text(
          char,
          style: GoogleFonts.spaceMono(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 6.0,
            color:
                isResolved ? AppTheme.colorTextPrimary : AppTheme.colorAccent,
          ),
        );
      }),
    );
  }
}
