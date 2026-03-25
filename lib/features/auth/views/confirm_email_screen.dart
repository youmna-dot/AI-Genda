// lib/features/auth/views/confirm_email_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';

class ConfirmEmailScreen extends StatefulWidget {
  final String userId;
  final String email;
  const ConfirmEmailScreen({
    super.key,
    required this.userId,
    required this.email,
  });
  @override
  State<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends State<ConfirmEmailScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;
  bool _isSuccess = false; // ← success state
  String? _errorMessage;
  String? _successMessage;
  final _auth = AuthController();

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter the verification code.');
      _shakeCtrl.forward(from: 0);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _auth.confirmEmail(
      userId: widget.userId,
      code: code,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      // ← اعرض شاشة النجاح الأول
      setState(() => _isSuccess = true);
      // ← استنى 3 ثواني وبعدين روح Sign In
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      context.go('/auth');
    } else {
      setState(() => _errorMessage = result.errorMessage);
      _shakeCtrl.forward(from: 0);
    }
  }

  Future<void> _handleResend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await _auth.resendConfirmEmail(email: widget.email);

    if (!mounted) return;
    setState(() => _isResending = false);

    if (result.success) {
      setState(() => _successMessage = 'Code resent! Check your email.');
    } else {
      setState(() => _errorMessage = 'Failed to resend. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: _isSuccess
            ? _buildSuccess()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Back ──
                    GestureDetector(
                      onTap: () => context.go('/auth'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFE8E4F5), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF6C3FC8).withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Color(0xFF7C5CBF), size: 20),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── Icon ──
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C3FC8).withOpacity(0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: const Icon(Icons.mark_email_read_rounded,
                            color: Colors.white, size: 42),
                      ),
                    ),
                    const SizedBox(height: 28),

                    Center(
                      child: Text(
                        'Check Your Email!',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E0F5C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'We sent a verification code to',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: const Color(0xFF8A84A3)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        widget.email.isNotEmpty ? widget.email : 'your email',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7C5CBF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── Banners ──
                    if (_errorMessage != null) ...[
                      _Banner(message: _errorMessage!, isError: true),
                      const SizedBox(height: 16),
                    ],
                    if (_successMessage != null) ...[
                      _Banner(message: _successMessage!, isError: false),
                      const SizedBox(height: 16),
                    ],

                    // ── Code Field ──
                    Text(
                      'Verification Code',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8A84A3)),
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(
                            _shakeAnim.value > 0
                                ? 8 *
                                    (1 - _shakeAnim.value) *
                                    ((_shakeAnim.value * 10).toInt() % 2 == 0
                                        ? 1
                                        : -1)
                                : 0,
                            0),
                        child: child,
                      ),
                      child: TextField(
                        controller: _codeCtrl,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E0F5C),
                          letterSpacing: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your verification code',
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFFBBB8CC),
                              letterSpacing: 0),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Color(0xFFE8E4F5), width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Color(0xFF7C5CBF), width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _handleConfirm(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '💡 Copy the code from your email and paste it here',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: const Color(0xFF8A84A3)),
                    ),
                    const SizedBox(height: 32),

                    // ── Confirm Button ──
                    GestureDetector(
                      onTap: _isLoading ? null : _handleConfirm,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isLoading
                                ? [
                                    const Color(0xFFAA99D9),
                                    const Color(0xFF8870B8)
                                  ]
                                : [
                                    const Color(0xFF8B6FD4),
                                    const Color(0xFF5B3A9E)
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: _isLoading
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF6C3FC8)
                                        .withOpacity(0.38),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ))
                              : Text(
                                  'Confirm Email',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Resend ──
                    Center(
                      child: GestureDetector(
                        onTap: _isResending ? null : _handleResend,
                        child: _isResending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF7C5CBF)),
                                ))
                            : RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: "Didn't receive it?  ",
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: const Color(0xFF8A84A3)),
                                  ),
                                  TextSpan(
                                    text: 'Resend',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: const Color(0xFF7C5CBF),
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          const Color(0xFF7C5CBF),
                                    ),
                                  ),
                                ]),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/auth'),
                        child: Text(
                          'Back to Sign In',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF8A84A3),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ══════════════════════════════════════
  // SUCCESS STATE
  // ══════════════════════════════════════
  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Check Icon ──
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8FFF0),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4CAF50), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF4CAF50), size: 52),
            ),
            const SizedBox(height: 28),

            Text(
              'Email Confirmed 🎉',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E0F5C),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your email has been verified successfully.\nYou can now sign in with your account.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF8A84A3),
                height: 1.7,
              ),
            ),
            const SizedBox(height: 32),

            // ── Loading indicator ──
            const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFF7C5CBF)),
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 16),
            Text(
              'Taking you to Sign In...',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF8A84A3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Banner ──
class _Banner extends StatelessWidget {
  final String message;
  final bool isError;
  const _Banner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:
            isError ? const Color(0xFFFFEEEE) : const Color(0xFFE8FFF0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? const Color(0xFFFFCDD2)
              : const Color(0xFFA5D6B0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: isError
                ? const Color(0xFFE74C3C)
                : const Color(0xFF2E7D32),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isError
                    ? const Color(0xFFE74C3C)
                    : const Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}