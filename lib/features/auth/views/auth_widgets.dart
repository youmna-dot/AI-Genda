// lib/features/auth/views/auth_widgets.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════
// SHARED SCAFFOLD
// ══════════════════════════════════════════════
class AuthScaffold extends StatefulWidget {
  final Widget child;
  final String headerTitle;
  final String headerSubtitle;
  const AuthScaffold({
    super.key,
    required this.child,
    required this.headerTitle,
    required this.headerSubtitle,
  });
  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _bgCtrl;
  late Animation<double> _bgPulse;
  late AnimationController _orbitCtrl;
  late AnimationController _cardCtrl;
  late Animation<double> _cardSlide;
  late Animation<double> _cardOpacity;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _bgPulse = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _cardSlide = Tween<double>(begin: 80, end: 0).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardOpacity =
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    Future.delayed(
        const Duration(milliseconds: 80), () => _cardCtrl.forward());
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _bgCtrl.dispose();
    _orbitCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  Widget _orbitDot({
    required Size size,
    required double orbitRadius,
    required double dotSize,
    required Color color,
    required double opacity,
    required double speed,
    required double angleOffset,
  }) {
    final double cx = size.width / 2;
    final double cy = size.height * 0.22;
    final double angle =
        _orbitCtrl.value * 2 * math.pi * speed + angleOffset;
    final double x = cx + orbitRadius * math.cos(angle) - dotSize / 2;
    final double y = cy + orbitRadius * 0.4 * math.sin(angle) - dotSize / 2;
    return Positioned(
      left: x, top: y,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: dotSize, height: dotSize,
          decoration: BoxDecoration(
            color: color, shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: dotSize * 2,
                  spreadRadius: 1)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF8),
      body: AnimatedBuilder(
        animation:
            Listenable.merge([_bgCtrl, _orbitCtrl, _floatCtrl, _cardCtrl]),
        builder: (context, _) {
          final double floatOffset =
              math.sin(_floatCtrl.value * math.pi) * 7;
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFFEEEBF8),
                          const Color(0xFFF5F2FF), _bgPulse.value)!,
                      Color.lerp(const Color(0xFFE8E4F5),
                          const Color(0xFFEDF0FF), _bgPulse.value)!,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -80, left: -80,
                child: Opacity(
                  opacity: 0.14 + 0.06 * _bgPulse.value,
                  child: Container(
                    width: 300, height: 300,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        Color(0xFF7C5CBF), Colors.transparent,
                      ]),
                    ),
                  ),
                ),
              ),
              _orbitDot(size: size, orbitRadius: 90, dotSize: 6,
                  color: const Color(0xFF7C5CBF), opacity: 0.4,
                  speed: 1.0, angleOffset: 0.0),
              _orbitDot(size: size, orbitRadius: 110, dotSize: 4,
                  color: const Color(0xFF3ECFCF), opacity: 0.35,
                  speed: 0.7, angleOffset: 2.1),
              _orbitDot(size: size, orbitRadius: 75, dotSize: 5,
                  color: const Color(0xFFAB8EE0), opacity: 0.35,
                  speed: 1.3, angleOffset: 4.2),
              Positioned(
                top: 0, left: 0, right: 0,
                height: size.height * 0.37,
                child: SafeArea(
                  bottom: false,
                  child: Transform.translate(
                    offset: Offset(0, -floatOffset),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120, height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7C5CBF).withOpacity(
                                        0.28 + 0.1 * _bgPulse.value),
                                    blurRadius: 40, spreadRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 118, height: 118,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF7C5CBF).withOpacity(0.18),
                                  width: 1,
                                ),
                              ),
                            ),
                            Image.asset('assets/logo.png',
                                width: 100, height: 100,
                                fit: BoxFit.contain),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(colors: [
                            Color(0xFF4A2D8A),
                            Color(0xFF7C5CBF),
                            Color(0xFF9B7FD4),
                          ]).createShader(bounds),
                          child: Text('AIGENDA',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 5,
                                height: 1,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                top: size.height * 0.31,
                child: Transform.translate(
                  offset: Offset(0, _cardSlide.value),
                  child: Opacity(
                    opacity: _cardOpacity.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Color(0xFFFAF9FF)],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF6C3FC8).withOpacity(0.12),
                              blurRadius: 30,
                              offset: const Offset(0, -8)),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AuthCardHeader(
                              title: widget.headerTitle,
                              subtitle: widget.headerSubtitle,
                            ),
                            const SizedBox(height: 20),
                            widget.child,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// SHARED WIDGETS
class AuthCardHeader extends StatelessWidget {
  final String title, subtitle;
  const AuthCardHeader({super.key, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF7C5CBF), Color(0xFFAB8EE0)]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22, fontWeight: FontWeight.w700,
              color: const Color(0xFF1E0F5C), letterSpacing: -0.3,
            )),
        const SizedBox(height: 3),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 12.5, color: const Color(0xFF7C5CBF))),
      ],
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFE74C3C), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFFE74C3C),
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  final String label;
  const AuthFieldLabel({super.key, required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF8A84A3)));
}

class AuthEyeToggle extends StatelessWidget {
  final bool obscure;
  final VoidCallback onToggle;
  const AuthEyeToggle({super.key, required this.obscure, required this.onToggle});
  @override
  Widget build(BuildContext context) => IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: const Color(0xFF8A84A3), size: 20,
      ),
      onPressed: onToggle);
}

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscure, enabled;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller, required this.hint,
    required this.prefixIcon, this.obscure = false,
    this.enabled = true, this.suffixIcon,
    this.keyboardType, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: GoogleFonts.poppins(
          fontSize: 14, color: const Color(0xFF1E0F5C)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            fontSize: 13, color: const Color(0xFFBBB8CC)),
        prefixIcon:
            Icon(prefixIcon, color: const Color(0xFF8A84A3), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled
            ? const Color(0xFFF7F5FF)
            : const Color(0xFFEFEEF5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E4F5), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C5CBF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E4F5), width: 1.2),
        ),
        errorStyle: GoogleFonts.poppins(
            fontSize: 11, color: const Color(0xFFE74C3C)),
      ),
    );
  }
}

class AuthGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  const AuthGradientButton({
    super.key,
    required this.label, required this.onTap, this.isLoading = false,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity, height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: isLoading
                ? [const Color(0xFFAA99D9), const Color(0xFF8870B8)]
                : [const Color(0xFF8B6FD4), const Color(0xFF5B3A9E)],
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: isLoading ? [] : [
            BoxShadow(
                color: const Color(0xFF6C3FC8).withOpacity(0.38),
                blurRadius: 18, offset: const Offset(0, 8))
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: Colors.white, letterSpacing: 0.3)),
        ),
      ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFE8E4F5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('Or continue with',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFF8A84A3))),
        ),
        Expanded(child: Container(height: 1, color: const Color(0xFFE8E4F5))),
      ],
    );
  }
}

class AuthSocialRow extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleTap, onFacebookTap;
  const AuthSocialRow({
    super.key,
    required this.isLoading,
    required this.onGoogleTap,
    required this.onFacebookTap,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SocialBtn(
          onTap: isLoading ? null : onGoogleTap,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _GoogleIcon(),
            const SizedBox(width: 8),
            Text('Google', style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: const Color(0xFF1E0F5C))),
          ]),
        )),
        const SizedBox(width: 12),
        Expanded(child: _SocialBtn(
          onTap: isLoading ? null : onFacebookTap,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _FacebookIcon(),
            const SizedBox(width: 8),
            Text('Facebook', style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: const Color(0xFF1E0F5C))),
          ]),
        )),
      ],
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _SocialBtn({required this.child, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E4F5), width: 1.2),
          boxShadow: [
            BoxShadow(color: const Color(0xFF6C3FC8).withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 3))
          ],
        ),
        child: child,
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 20, height: 20,
        child: CustomPaint(painter: _GooglePainter()));
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;
    final Rect rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.85);
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFFEEEEEE));
    canvas.drawArc(rect, -1.05, 1.05, true, Paint()..color = const Color(0xFFEA4335));
    canvas.drawArc(rect, 0.0, 1.57, true, Paint()..color = const Color(0xFF34A853));
    canvas.drawArc(rect, 1.57, 1.57, true, Paint()..color = const Color(0xFFFBBC05));
    canvas.drawArc(rect, 3.14, 1.09, true, Paint()..color = const Color(0xFF4285F4));
    canvas.drawCircle(Offset(cx, cy), r * 0.55, Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(cx, cy - r * 0.15, r * 0.85, r * 0.3),
        Paint()..color = const Color(0xFF4285F4));
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _FacebookIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: const BoxDecoration(
          color: Color(0xFF1877F2), shape: BoxShape.circle),
      child: const Center(
        child: Text('f',
            style: TextStyle(color: Colors.white, fontSize: 13,
                fontWeight: FontWeight.w700, height: 1)),
      ),
    );
  }
}