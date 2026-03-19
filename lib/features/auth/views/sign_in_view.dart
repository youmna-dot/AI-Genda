// lib/features/auth/views/sign_in_view.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import 'auth_widgets.dart';

class SignInView extends StatefulWidget {
  final VoidCallback onSwitchToSignUp;
  const SignInView({super.key, required this.onSwitchToSignUp});
  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  final _auth = AuthController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    final result = await _auth.signIn(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.success) {
      context.go('/home');
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  void _handleGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Google login coming soon!',
          style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: const Color(0xFF7C5CBF),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _handleFacebook() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Facebook login coming soon!',
          style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: const Color(0xFF7C5CBF),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      headerTitle: 'Welcome Back!',
      headerSubtitle: 'welcome back, we missed you',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null) ...[
              AuthErrorBanner(message: _errorMessage!),
              const SizedBox(height: 14),
            ],
            const AuthFieldLabel(label: 'Email'),
            const SizedBox(height: 6),
            AuthTextField(
              controller: _emailCtrl,
              hint: 'email@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              validator: (v) =>
                  v != null && v.contains('@') ? null : 'Enter a valid email',
            ),
            const SizedBox(height: 16),
            const AuthFieldLabel(label: 'Password'),
            const SizedBox(height: 6),
            AuthTextField(
              controller: _passwordCtrl,
              hint: '••••••••',
              prefixIcon: Icons.key_outlined,
              obscure: _obscurePassword,
              enabled: !_isLoading,
              suffixIcon: AuthEyeToggle(
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your password';
                if (v.length < 8) return 'At least 8 characters';
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading
                    ? null
                    : () => context.push('/forgot-password'),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(top: 4, bottom: 2)),
                child: Text('Forgot Password?',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF7C5CBF),
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ),
            const SizedBox(height: 6),
            AuthGradientButton(
                label: 'Sign In',
                isLoading: _isLoading,
                onTap: _handleSignIn),
            const SizedBox(height: 20),
            const AuthOrDivider(),
            const SizedBox(height: 16),
            AuthSocialRow(
              isLoading: _isLoading,
              onGoogleTap: _handleGoogle,
              onFacebookTap: _handleFacebook,
            ),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _isLoading ? null : widget.onSwitchToSignUp,
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "Don't have an account?  ",
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF8A84A3)),
                    ),
                    TextSpan(
                      text: 'Sign Up',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF7C5CBF),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF7C5CBF),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}