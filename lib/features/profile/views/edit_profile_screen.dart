// lib/features/profile/views/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

// EDIT PROFILE SCREEN
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _jobTitleCtrl   = TextEditingController();

  // Date of Birth 
  DateTime? _selectedDate;

  // Change Email 
  final _newEmailCtrl  = TextEditingController();
  final _emailCodeCtrl = TextEditingController();

  final _profileCtrl = ProfileController();

  bool _isLoadingProfile  = true;
  bool _isSaving          = false;
  bool _isEmailStep2      = false;
  bool _isSendingEmail    = false;
  bool _isConfirmingEmail = false;

  String? _errorMessage;
  String? _successMessage;
  String? _emailError;
  String? _emailSuccess;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _jobTitleCtrl.dispose();
    _newEmailCtrl.dispose();
    _emailCodeCtrl.dispose();
    super.dispose();
  }

  // LOAD — GET /me
  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);
    final profile = await _profileCtrl.getProfile();
    if (!mounted) return;

    if (profile != null) {
      _firstNameCtrl.text = profile.firstName;
      _lastNameCtrl.text  = profile.lastName;
      _jobTitleCtrl.text  = profile.jobTitle ?? '';

      if (profile.dateOfBirth != null && profile.dateOfBirth!.isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(profile.dateOfBirth!);
        } catch (_) {}
      }
    } else {
      _firstNameCtrl.text = AuthController.currentFirstName ?? '';
      _lastNameCtrl.text  = AuthController.currentLastName  ?? '';
    }

    setState(() => _isLoadingProfile = false);
  }

  // Date Picker 
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C5CBF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E0F5C),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7C5CBF),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Format date 
  String get _formattedDate {
    if (_selectedDate == null) return '';
    return '${_selectedDate!.year}-'
        '${_selectedDate!.month.toString().padLeft(2, '0')}-'
        '${_selectedDate!.day.toString().padLeft(2, '0')}';
  }

  // SAVE — PUT /me
  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedDate == null) {
      setState(() => _errorMessage = 'Please select your date of birth.');
      return;
    }

    setState(() {
      _isSaving       = true;
      _errorMessage   = null;
      _successMessage = null;
    });

    final result = await _profileCtrl.updateProfile(
      firstName:   _firstNameCtrl.text.trim(),
      lastName:    _lastNameCtrl.text.trim(),
      dateOfBirth: _formattedDate, // yyyy-MM-dd
      jobTitle:    _jobTitleCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.success) {
      setState(() => _successMessage = 'Profile updated successfully!');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) context.pop();
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  // CHANGE EMAIL 1
  Future<void> _handleRequestEmailChange() async {
    final newEmail = _newEmailCtrl.text.trim();
    if (newEmail.isEmpty || !newEmail.contains('@')) {
      setState(() => _emailError = 'Enter a valid email.');
      return;
    }

    setState(() {
      _isSendingEmail = true;
      _emailError     = null;
      _emailSuccess   = null;
    });

    final result = await _profileCtrl.requestChangeEmail(newEmail: newEmail);

    if (!mounted) return;
    setState(() => _isSendingEmail = false);

    if (result.success) {
      setState(() {
        _isEmailStep2 = true;
        _emailSuccess = 'Code sent! Check your new email.';
      });
    } else {
      setState(() => _emailError = result.errorMessage);
    }
  }

  // CHANGE EMAIL  2
  Future<void> _handleConfirmEmailChange() async {
    final code = _emailCodeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _emailError = 'Enter the verification code.');
      return;
    }

    setState(() {
      _isConfirmingEmail = true;
      _emailError        = null;
      _emailSuccess      = null;
    });

    final result = await _profileCtrl.confirmChangeEmail(
      newEmail: _newEmailCtrl.text.trim(),
      code:     code,
    );

    if (!mounted) return;
    setState(() => _isConfirmingEmail = false);

    if (result.success) {
      setState(() {
        _isEmailStep2 = false;
        _emailSuccess = 'Email changed successfully!';
        _newEmailCtrl.clear();
        _emailCodeCtrl.clear();
      });
    } else {
      setState(() => _emailError = result.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: _isLoadingProfile
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF7C5CBF)),
                  strokeWidth: 2.5,
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 24),
                    _buildAvatar(),
                    const SizedBox(height: 28),
                    _buildProfileForm(),
                    const SizedBox(height: 28),
                    _buildEmailSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  // Top Bar 
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
                  blurRadius: 8, offset: const Offset(0, 2),
                )
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: Color(0xFF7C5CBF), size: 20),
          ),
        ),
        const SizedBox(width: 14),
        Text('Edit Profile',
            style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E0F5C))),
      ],
    );
  }

  //  Avatar 
  Widget _buildAvatar() {
    final firstName = AuthController.currentFirstName ?? '';
    final lastName  = AuthController.currentLastName  ?? '';
    final initials  = [
      if (firstName.isNotEmpty) firstName[0],
      if (lastName.isNotEmpty)  lastName[0],
    ].join().toUpperCase();

    return Center(
      child: Stack(
        children: [
          Container(
            width: 90, height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF8B6FD4), Color(0xFF5B3A9E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEDE6FF),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  initials.isEmpty ? 'U' : initials,
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5B3A9E),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF7C5CBF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 13),
            ),
          ),
        ],
      ),
    );
  }

  //  Profile Form 
  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE9F8), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3FC8).withOpacity(0.05),
            blurRadius: 16, offset: const Offset(0, 4),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'Personal Info'),
            const SizedBox(height: 16),

            // Error / Success 
            if (_errorMessage != null) ...[
              _Banner(message: _errorMessage!, isError: true),
              const SizedBox(height: 14),
            ],
            if (_successMessage != null) ...[
              _Banner(message: _successMessage!, isError: false),
              const SizedBox(height: 14),
            ],

            // First + Last Name 
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    label: 'First Name',
                    controller: _firstNameCtrl,
                    hint: 'First name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    label: 'Last Name',
                    controller: _lastNameCtrl,
                    hint: 'Last name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Date of Birth 
            Text('Date of Birth',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8A84A3))),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedDate == null
                        ? const Color(0xFFE8E4F5)
                        : const Color(0xFF7C5CBF),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: _selectedDate == null
                          ? const Color(0xFF8A84A3)
                          : const Color(0xFF7C5CBF),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null
                          ? 'Select your date of birth'
                          : _formattedDate,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _selectedDate == null
                            ? const Color(0xFFBBB8CC)
                            : const Color(0xFF1E0F5C),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: _selectedDate == null
                          ? const Color(0xFF8A84A3)
                          : const Color(0xFF7C5CBF),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Job Title 
            _buildField(
              label: 'Job Title',
              controller: _jobTitleCtrl,
              hint: 'e.g. Software Engineer',
              icon: Icons.work_outline_rounded,
            ),
            const SizedBox(height: 24),

            // Save Button
            _GradientButton(
              label: 'Save Changes',
              isLoading: _isSaving,
              onTap: _handleSave,
            ),
          ],
        ),
      ),
    );
  }

  //  Email Section 
  Widget _buildEmailSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE9F8), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3FC8).withOpacity(0.05),
            blurRadius: 16, offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Change Email'),
          const SizedBox(height: 4),
          Text(
            'Current: ${AuthController.currentUserEmail ?? ''}',
            style: GoogleFonts.poppins(
                fontSize: 11, color: const Color(0xFF8A84A3)),
          ),
          const SizedBox(height: 16),

          if (_emailError != null) ...[
            _Banner(message: _emailError!, isError: true),
            const SizedBox(height: 14),
          ],
          if (_emailSuccess != null) ...[
            _Banner(message: _emailSuccess!, isError: false),
            const SizedBox(height: 14),
          ],

          _buildField(
            label: 'New Email',
            controller: _newEmailCtrl,
            hint: 'new@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isEmailStep2,
          ),
          const SizedBox(height: 14),

          if (!_isEmailStep2) ...[
            _GradientButton(
              label: 'Send Verification Code',
              isLoading: _isSendingEmail,
              onTap: _handleRequestEmailChange,
            ),
          ] else ...[
            _buildField(
              label: 'Verification Code',
              controller: _emailCodeCtrl,
              hint: 'Paste code from your new email',
              icon: Icons.verified_outlined,
            ),
            const SizedBox(height: 14),
            _GradientButton(
              label: 'Confirm Email Change',
              isLoading: _isConfirmingEmail,
              onTap: _handleConfirmEmailChange,
            ),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () => setState(() {
                  _isEmailStep2 = false;
                  _emailError   = null;
                  _emailSuccess = null;
                  _emailCodeCtrl.clear();
                }),
                child: Text(
                  'Use a different email',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF7C5CBF),
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF7C5CBF),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  //  Field Builder 
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
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
                Icon(icon, color: const Color(0xFF8A84A3), size: 20),
            filled: true,
            fillColor: enabled
                ? const Color(0xFFF7F5FF)
                : const Color(0xFFEFEEF5),
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFFE8E4F5), width: 1.2),
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
}

// SHARED WIDGETS
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E0F5C)));
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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