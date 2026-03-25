import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _bgPulse;
  late AnimationController _orbitController;
  late AnimationController _ringController;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late AnimationController _nameController;
  late Animation<double> _nameOpacity;
  late Animation<Offset> _nameSlide;
  late Animation<double> _shimmerProgress;
  late AnimationController _taglineController;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  late AnimationController _buttonsController;
  late Animation<double> _buttonsOpacity;
  late Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();

    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
    _bgPulse = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

    _orbitController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();

    _ringController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _ringScale = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _ringController, curve: Curves.elasticOut));
    _ringOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _ringController, curve: const Interval(0.0, 0.4)));

    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _logoController, curve: const Interval(0.0, 0.4)));

    _nameController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _nameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _nameController, curve: const Interval(0, 0.5)));
    _nameSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _nameController, curve: Curves.easeOutCubic));
    _shimmerProgress = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(parent: _nameController, curve: Curves.easeInOut));

    _taglineController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _taglineController, curve: Curves.easeOut));
    _taglineSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _taglineController, curve: Curves.easeOutCubic));

    _buttonsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _buttonsController, curve: Curves.easeOut));
    _buttonsSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _buttonsController, curve: Curves.easeOutCubic));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _ringController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _nameController.forward();
    await Future.delayed(const Duration(milliseconds: 350));
    _taglineController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _buttonsController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _orbitController.dispose();
    _ringController.dispose();
    _logoController.dispose();
    _nameController.dispose();
    _taglineController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgController, _orbitController]),
        builder: (context, _) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFFEEEBF8), const Color(0xFFF5F2FF),
                      _bgPulse.value)!,
                  Color.lerp(const Color(0xFFE8E4F5), const Color(0xFFEDF0FF),
                      _bgPulse.value)!,
                  Color.lerp(const Color(0xFFEFF0FB), const Color(0xFFE8F4FF),
                      1 - _bgPulse.value)!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Orbiting dots
                _buildOrbitDot(
                  size: size,
                  orbitRadius: 110,
                  dotSize: 8,
                  color: const Color(0xFF7C5CBF),
                  opacity: 0.5,
                  speed: 1.0,
                  angleOffset: 0.0,
                ),
                _buildOrbitDot(
                  size: size,
                  orbitRadius: 130,
                  dotSize: 5,
                  color: const Color(0xFF3ECFCF),
                  opacity: 0.45,
                  speed: 0.7,
                  angleOffset: 2.1,
                ),
                _buildOrbitDot(
                  size: size,
                  orbitRadius: 95,
                  dotSize: 6,
                  color: const Color(0xFFAB8EE0),
                  opacity: 0.4,
                  speed: 1.3,
                  angleOffset: 4.2,
                ),
                _buildOrbitDot(
                  size: size,
                  orbitRadius: 150,
                  dotSize: 4,
                  color: const Color(0xFF7C5CBF),
                  opacity: 0.28,
                  speed: 0.5,
                  angleOffset: 1.0,
                ),
                _buildOrbitDot(
                  size: size,
                  orbitRadius: 120,
                  dotSize: 5,
                  color: const Color(0xFF3ECFCF),
                  opacity: 0.32,
                  speed: 0.9,
                  angleOffset: 3.5,
                ),

                // Purple blob top-left
                Positioned(
                  top: -100,
                  left: -100,
                  child: Opacity(
                    opacity: 0.16 + 0.07 * _bgPulse.value,
                    child: Container(
                      width: 360,
                      height: 360,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          const Color(0xFF7C5CBF),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                ),

                // Teal blob bottom-right
                Positioned(
                  bottom: 60,
                  right: -100,
                  child: Opacity(
                    opacity: 0.12 + 0.06 * (1 - _bgPulse.value),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          const Color(0xFF3ECFCF),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                ),

                // Main content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        _buildLogoSection(),
                        const SizedBox(height: 28),
                        _buildAppName(),
                        const SizedBox(height: 14),
                        _buildTagline(),
                        const Spacer(flex: 2),
                        _buildButtons(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Single orbit dot ,no array indexing 
  Widget _buildOrbitDot({
    required Size size,
    required double orbitRadius,
    required double dotSize,
    required Color color,
    required double opacity,
    required double speed,
    required double angleOffset,
  }) {
    final cx = size.width / 2;
    final cy = size.height * 0.34;
    final angle = _orbitController.value * 2 * math.pi * speed + angleOffset;
    final x = cx + orbitRadius * math.cos(angle) - dotSize / 2;
    final y = cy + orbitRadius * 0.45 * math.sin(angle) - dotSize / 2;

    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.7),
                blurRadius: dotSize * 2,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_logoController, _ringController, _bgController]),
      builder: (context, _) {
        final floatOffset = math.sin(_bgController.value * math.pi) * 7;
        return Transform.translate(
          offset: Offset(0, -floatOffset),
          child: SizedBox(
            width: 210,
            height: 210,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Opacity(
                  opacity: _ringOpacity.value * 0.4,
                  child: Transform.scale(
                    scale: _ringScale.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF7C5CBF).withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                // Middle ring
                Opacity(
                  opacity: _ringOpacity.value * 0.3,
                  child: Transform.scale(
                    scale: _ringScale.value * 0.82,
                    child: Container(
                      width: 165,
                      height: 165,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFAB8EE0).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // Glow
                Opacity(
                  opacity: _logoOpacity.value * (0.2 + 0.1 * _bgPulse.value),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C5CBF).withOpacity(0.55),
                          blurRadius: 45,
                          spreadRadius: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                // Logo
                Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Image.asset(
                      'assets/logo.png',
                      width: 125,
                      height: 125,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return AnimatedBuilder(
      animation: _nameController,
      builder: (context, _) {
        return FadeTransition(
          opacity: _nameOpacity,
          child: SlideTransition(
            position: _nameSlide,
            child: ShaderMask(
              shaderCallback: (bounds) {
                final s = _shimmerProgress.value;
                return LinearGradient(
                  begin: Alignment(s - 0.5, 0),
                  end: Alignment(s + 0.5, 0),
                  colors: const [
                    Color(0xFF4A2D8A),
                    Color(0xFF7C5CBF),
                    Color(0xFFBBA8E8),
                    Color(0xFF7C5CBF),
                    Color(0xFF4A2D8A),
                  ],
                  stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                ).createShader(bounds);
              },
              child: Text(
                'AIGENDA',
                style: GoogleFonts.poppins(
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 7,
                  height: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: _taglineController,
      builder: (context, _) {
        return FadeTransition(
          opacity: _taglineOpacity,
          child: SlideTransition(
            position: _taglineSlide,
            child: Column(
              children: [
                Text(
                  'نظّم عقلك، مش بس مهامك',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E0F5C),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Organize your mind, not just your tasks',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A84A3),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Breathing dots
                AnimatedBuilder(
                  animation: _bgController,
                  builder: (context, _) {
                    final pulse0 =
                        math.sin(_bgController.value * math.pi * 2 + 0.0) *
                                0.5 +
                            0.5;
                    final pulse1 =
                        math.sin(_bgController.value * math.pi * 2 + 1.05) *
                                0.5 +
                            0.5;
                    final pulse2 =
                        math.sin(_bgController.value * math.pi * 2 + 2.1) *
                                0.5 +
                            0.5;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 7,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C5CBF)
                                .withOpacity(0.55 + 0.45 * pulse0),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Container(
                          width: 22 + pulse1 * 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFAB8EE0)
                                .withOpacity(0.55 + 0.45 * pulse1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Container(
                          width: 7,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3ECFCF)
                                .withOpacity(0.55 + 0.45 * pulse2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtons(BuildContext context) {
    return AnimatedBuilder(
      animation: _buttonsController,
      builder: (context, child) => FadeTransition(
        opacity: _buttonsOpacity,
        child: SlideTransition(position: _buttonsSlide, child: child),
      ),
      child: Column(
        children: [
          _PressScaleButton(
            onTap: () => context.go('/onboarding'),
            child: Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C3FC8).withOpacity(0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF6C3FC8).withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get Started',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  // const SizedBox(width: 6),
                  // Text(
                  //   '/ Get Started',
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 13,
                  //     fontWeight: FontWeight.w500,
                  //     color: Colors.white.withOpacity(0.72),
                  //   ),
                  // ),
                  const SizedBox(width: 12),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => context.go('/auth'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'I have an account  ',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: const Color(0xFF8A84A3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'Sign In ',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF7C5CBF),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF7C5CBF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Press-to-scale button wrapper 
class _PressScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressScaleButton({required this.child, required this.onTap});

  @override
  State<_PressScaleButton> createState() => _PressScaleButtonState();
}

class _PressScaleButtonState extends State<_PressScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}