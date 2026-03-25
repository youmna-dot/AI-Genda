// lib/features/auth/views/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final _auth = AuthController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result =
        await _auth.sendPasswordReset(email: _emailCtrl.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      context.go('/reset-password', extra: _emailCtrl.text.trim());
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back 
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFE8E4F5), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C3FC8).withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: Color(0xFF7C5CBF)),
                ),
              ),
              const SizedBox(height: 36),

              //  Icon 
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEDE6FF), Color(0xFFD8CEF0)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C5CBF).withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.lock_reset_rounded,
                      color: Color(0xFF7C5CBF), size: 32),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Forgot Password?',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E0F5C),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your email and we'll send you a reset code.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF8A84A3),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // Error Banner 
              if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
                _Banner(message: _errorMessage!, isError: true),
                const SizedBox(height: 16),
              ],

              //  Form 
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8A84A3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: const Color(0xFF1E0F5C)),
                      validator: (v) =>
                          v != null && v.trim().contains('@')
                              ? null
                              : 'Enter a valid email',
                      decoration: InputDecoration(
                        hintText: 'email@example.com',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFFBBB8CC)),
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Color(0xFF8A84A3), size: 20),
                        filled: true,
                        fillColor: _isLoading
                            ? const Color(0xFFEFEEF5)
                            : const Color(0xFFF7F5FF),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFE8E4F5), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF7C5CBF), width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFE74C3C), width: 1.2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFE74C3C), width: 1.5),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFE8E4F5), width: 1.2),
                        ),
                        errorStyle: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFFE74C3C)),
                      ),
                    ),
                    const SizedBox(height: 28),

                    //  Send Code Button 
                    GestureDetector(
                      onTap: _isLoading ? null : _handleSendCode,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isLoading
                                ? [
                                    const Color(0xFFAA99D9),
                                    const Color(0xFF8870B8)
                                  ]
                                : [
                                    const Color(0xFF8B6FD4),
                                    const Color(0xFF5B3A9E)
                                  ],
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
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                  ),
                                )
                              : Text(
                                  'Send Reset Code',
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
                    const SizedBox(height: 20),

                    // Back to Sign In 
                    Center(
                      child: GestureDetector(
                        onTap: _isLoading ? null : () => context.pop(),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '← ',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF7C5CBF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: 'Back to Sign In',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF7C5CBF),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      const Color(0xFF7C5CBF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//  Banner 
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