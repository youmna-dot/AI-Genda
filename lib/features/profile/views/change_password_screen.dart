// lib/features/profile/views/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../controllers/profile_controller.dart';

// ══════════════════════════════════════════════════════
// CHANGE PASSWORD SCREEN
// ══════════════════════════════════════════════════════
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;
  bool _isSuccess      = false;

  String? _errorMessage;

  final _profileCtrl = ProfileController();

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Password Validator ──
  String? _validateNewPassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter a new password';
    if (v.length < 8) return 'At least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Add uppercase letter (A-Z)';
    if (!v.contains(RegExp(r'[a-z]'))) return 'Add lowercase letter (a-z)';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Add a number (0-9)';
    if (!v.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]'))) {
      return r'Add a special character e.g. !@#$%';
    }
    return null;
  }

  // ════════════════════════════════════════
  // CHANGE PASSWORD — PUT /me/change-password
  // ════════════════════════════════════════
  Future<void> _handleChangePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading     = true;
      _errorMessage  = null;
    });

    final result = await _profileCtrl.changePassword(
      currentPassword: _currentPassCtrl.text,
      newPassword:     _newPassCtrl.text,
      confirmPassword: _confirmPassCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      setState(() => _isSuccess = true);
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  // ════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: _isSuccess
            ? _buildSuccess(context)
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 32),
                    _buildIcon(),
                    const SizedBox(height: 28),
                    _buildForm(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Top Bar ──
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFE8E4F5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C3FC8).withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: Color(0xFF7C5CBF), size: 20),
          ),
        ),
        const SizedBox(width: 14),
        Text('Change Password',
            style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E0F5C))),
      ],
    );
  }

  // ── Icon ──
  Widget _buildIcon() {
    return Center(
      child: Container(
        width: 80, height: 80,
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
        child: const Icon(Icons.lock_outline_rounded,
            color: Colors.white, size: 36),
      ),
    );
  }

  // ── Form ──
  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE9F8), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3FC8).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Error Banner ──
            if (_errorMessage != null) ...[
              _Banner(message: _errorMessage!, isError: true),
              const SizedBox(height: 16),
            ],

            // ── Current Password ──
            _buildPasswordField(
              label: 'Current Password',
              controller: _currentPassCtrl,
              hint: '••••••••',
              obscure: _obscureCurrent,
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
              validator: (v) => v == null || v.isEmpty
                  ? 'Enter your current password'
                  : null,
            ),
            const SizedBox(height: 14),

            // ── New Password ──
            _buildPasswordField(
              label: 'New Password',
              controller: _newPassCtrl,
              hint: 'Min 8 chars, A-Z, 0-9, !@#\$',
              obscure: _obscureNew,
              onToggle: () =>
                  setState(() => _obscureNew = !_obscureNew),
              validator: _validateNewPassword,
            ),
            const SizedBox(height: 14),

            // ── Confirm Password ──
            _buildPasswordField(
              label: 'Confirm New Password',
              controller: _confirmPassCtrl,
              hint: '••••••••',
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) => v != _newPassCtrl.text
                  ? "Passwords don't match"
                  : null,
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '💡 Must have: A-Z · a-z · 0-9 · special char (!@#\$%)',
                style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: const Color(0xFF8A84A3)),
              ),
            ),
            const SizedBox(height: 24),

            // ── Change Password Button ──
            _GradientButton(
              label: 'Change Password',
              isLoading: _isLoading,
              onTap: _handleChangePassword,
            ),
          ],
        ),
      ),
    );
  }

  // ── Password Field Builder ──
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8A84A3))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: GoogleFonts.poppins(
              fontSize: 14, color: const Color(0xFF1E0F5C)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                fontSize: 13, color: const Color(0xFFBBB8CC)),
            prefixIcon: const Icon(Icons.key_outlined,
                color: Color(0xFF8A84A3), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF8A84A3),
                size: 20,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F5FF),
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
            errorStyle: GoogleFonts.poppins(
                fontSize: 11, color: const Color(0xFFE74C3C)),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════
  // SUCCESS STATE
  // ════════════════════════════════════════
  Widget _buildSuccess(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8FFF0),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF4CAF50), width: 2.5),
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
              'Password Changed! 🎉',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E0F5C),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your password has been updated successfully.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF8A84A3),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 36),
            _GradientButton(
              label: 'Back to Profile',
              isLoading: false,
              onTap: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════
class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [const Color(0xFFAA99D9), const Color(0xFF8870B8)]
                : [const Color(0xFF8B6FD4), const Color(0xFF5B3A9E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF6C3FC8).withOpacity(0.32),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  )
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ))
              : Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2)),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final bool isError;
  const _Banner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isError
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFF2E7D32),
                )),
          ),
        ],
      ),
    );
  }
}