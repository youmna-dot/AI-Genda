// lib/features/auth/views/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isResending = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _successMessage;

  final _auth = AuthController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Password validator ──
  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter a password';
    if (v.length < 8) return 'At least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Add uppercase letter (A-Z)';
    if (!v.contains(RegExp(r'[a-z]'))) return 'Add lowercase letter (a-z)';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Add a number (0-9)';
    if (!v.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]'))) {
      return r'Add a special character e.g. !@#$%';
    }
    return null;
  }

  // ── Reset Password ──
  Future<void> _handleReset() async {
    final code =
        _codeCtrl.text.replaceAll(RegExp(r'\s+'), '').trim();

    if (code.isEmpty) {
      setState(
          () => _errorMessage = 'Please enter the verification code.');
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await _auth.resetPassword(
      email: widget.email,
      code: code,
      newPassword: _newPassCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      setState(() => _isSuccess = true);
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  // ── Resend Code ──
  Future<void> _handleResend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result =
        await _auth.sendPasswordReset(email: widget.email);

    if (!mounted) return;
    setState(() => _isResending = false);

    if (result.success) {
      setState(
          () => _successMessage = 'Code resent! Check your email.');
    } else {
      setState(() => _errorMessage = 'Failed to resend. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 28, vertical: 24),
          child: _isSuccess ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  // SUCCESS STATE
  // ══════════════════════════════════════
  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFE8FFF0),
              shape: BoxShape.circle,
              border:
                  Border.all(color: const Color(0xFF4CAF50), width: 2),
            ),
            child: const Icon(Icons.check_rounded,
                color: Color(0xFF4CAF50), size: 48),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Password Reset!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E0F5C),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your password has been changed successfully.\nYou can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF8A84A3),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () => context.go('/auth'),
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C3FC8).withOpacity(0.38),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Center(
              child: Text(
                'Back to Sign In',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════
  // FORM STATE
  // ══════════════════════════════════════
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Back ──
        GestureDetector(
          onTap: () => context.go('/forgot-password'),
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
                  color: const Color(0xFF6C3FC8).withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: Color(0xFF7C5CBF), size: 20),
          ),
        ),
        const SizedBox(height: 32),

        // ── Icon ──
        Center(
          child: Container(
            width: 80,
            height: 80,
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
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: const Icon(Icons.lock_reset_rounded,
                color: Colors.white, size: 38),
          ),
        ),
        const SizedBox(height: 24),

        Center(
          child: Text(
            'Reset Password',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E0F5C),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'We sent a reset code to\n${widget.email}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF8A84A3),
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ── Error / Success Banners ──
        if (_errorMessage != null) ...[
          _Banner(message: _errorMessage!, isError: true),
          const SizedBox(height: 16),
        ],
        if (_successMessage != null) ...[
          _Banner(message: _successMessage!, isError: false),
          const SizedBox(height: 16),
        ],

        // ── Verification Code ──
        Text(
          'Verification Code',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8A84A3),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _codeCtrl,
          keyboardType: TextInputType.text,
          maxLines: null,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E0F5C),
            letterSpacing: 1.0,
          ),
          decoration: InputDecoration(
            hintText: 'Paste your reset code here',
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFFBBB8CC),
              letterSpacing: 0,
            ),
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
        ),
        const SizedBox(height: 8),
        Text(
          '💡 Copy the code from your email and paste it here',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF8A84A3),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),

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
                    ),
                  )
                : RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Didn't receive it?  ",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF8A84A3),
                          ),
                        ),
                        TextSpan(
                          text: 'Resend',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
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
        const SizedBox(height: 24),

        // ── Password Fields ──
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Password',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8A84A3),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _newPassCtrl,
                obscureText: _obscureNew,
                validator: _validatePassword,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: const Color(0xFF1E0F5C)),
                decoration: _fieldDecoration(
                  hint: 'Min 8 chars, A-Z, 0-9, !@#\$',
                  icon: Icons.key_outlined,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8A84A3),
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Confirm Password',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8A84A3),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmPassCtrl,
                obscureText: _obscureConfirm,
                validator: (v) => v != _newPassCtrl.text
                    ? "Passwords don't match"
                    : null,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: const Color(0xFF1E0F5C)),
                decoration: _fieldDecoration(
                  hint: '••••••••',
                  icon: Icons.key_outlined,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8A84A3),
                      size: 20,
                    ),
                    onPressed: () => setState(
                        () => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '💡 Password must have: A-Z · a-z · 0-9 · special char (!@#\$%)',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: const Color(0xFF8A84A3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Reset Button ──
        GestureDetector(
          onTap: _isLoading ? null : _handleReset,
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
                        color: const Color(0xFF6C3FC8).withOpacity(0.38),
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
                      ),
                    )
                  : Text(
                      'Reset Password',
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
      ],
    );
  }

  // ── Field Decoration Helper ──
  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
          fontSize: 13, color: const Color(0xFFBBB8CC)),
      prefixIcon:
          Icon(icon, color: const Color(0xFF8A84A3), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7F5FF),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFE8E4F5), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF7C5CBF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFE74C3C), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
      ),
      errorStyle: GoogleFonts.poppins(
          fontSize: 11, color: const Color(0xFFE74C3C)),
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
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFFEEEE)
            : const Color(0xFFE8FFF0),
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