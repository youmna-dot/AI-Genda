// lib/features/auth/views/sign_up_view.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import 'auth_widgets.dart';

class SignUpView extends StatefulWidget {
  final VoidCallback onSwitchToSignIn;
  const SignUpView({super.key, required this.onSwitchToSignIn});
  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  final _auth = AuthController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    final result = await _auth.signUp(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.success) {
      context.go('/confirm-email', extra: <String, String>{
        'userId': AuthController.currentUserId ?? '',
        'email': _emailCtrl.text.trim(),
      });
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

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter a password';
    if (v.length < 8) return 'At least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Add at least one uppercase letter (A-Z)';
    if (!v.contains(RegExp(r'[a-z]'))) return 'Add at least one lowercase letter (a-z)';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Add at least one number (0-9)';
    if (!v.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]'))) {
      return 'Add a special character e.g. !@#\$%';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      headerTitle: 'Create Account',
      headerSubtitle: 'join us and start your journey',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null) ...[
              AuthErrorBanner(message: _errorMessage!),
              const SizedBox(height: 14),
            ],

            // ── First Name + Last Name ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthFieldLabel(label: 'First Name'),
                      const SizedBox(height: 6),
                      AuthTextField(
                        controller: _firstNameCtrl,
                        hint: 'Youmna',
                        prefixIcon: Icons.person_outline_rounded,
                        enabled: !_isLoading,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthFieldLabel(label: 'Last Name'),
                      const SizedBox(height: 6),
                      AuthTextField(
                        controller: _lastNameCtrl,
                        hint: 'Ahmed',
                        prefixIcon: Icons.person_outline_rounded,
                        enabled: !_isLoading,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

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
            const SizedBox(height: 14),

            const AuthFieldLabel(label: 'Password'),
            const SizedBox(height: 6),
            AuthTextField(
              controller: _passwordCtrl,
              hint: 'Min 8 chars, A-Z, 0-9, !@#\$',
              prefixIcon: Icons.key_outlined,
              obscure: _obscurePass,
              enabled: !_isLoading,
              suffixIcon: AuthEyeToggle(
                obscure: _obscurePass,
                onToggle: () => setState(() => _obscurePass = !_obscurePass),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 14),

            const AuthFieldLabel(label: 'Confirm Password'),
            const SizedBox(height: 6),
            AuthTextField(
              controller: _confirmCtrl,
              hint: '••••••••',
              prefixIcon: Icons.key_outlined,
              obscure: _obscureConfirm,
              enabled: !_isLoading,
              suffixIcon: AuthEyeToggle(
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) =>
                  v != _passwordCtrl.text ? "Passwords don't match" : null,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '💡 Password must have: A-Z · a-z · 0-9 · special char (!@#\$%)',
                style: GoogleFonts.poppins(
                    fontSize: 10.5, color: const Color(0xFF8A84A3)),
              ),
            ),
            const SizedBox(height: 20),

            AuthGradientButton(
                label: 'Create Account',
                isLoading: _isLoading,
                onTap: _handleSignUp),
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
                onTap: _isLoading ? null : widget.onSwitchToSignIn,
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Already have an account?  ',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF8A84A3)),
                    ),
                    TextSpan(
                      text: 'Sign In',
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