// lib/features/profile/views/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/views/home_screen.dart' show AppData;
import '../controllers/profile_controller.dart';

// ══════════════════════════════════════════════════════
// PROFILE SCREEN
// ══════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  final VoidCallback onSignOut;
  const ProfileScreen({super.key, required this.onSignOut});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _controller = ProfileController();
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ── جيب بيانات اليوزر من الـ API عشان تتحدث ──
  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);
    await _controller.getProfile();
    if (mounted) setState(() => _isLoadingProfile = false);
  }

  @override
  Widget build(BuildContext context) {
    final firstName = AuthController.currentFirstName ?? '';
    final lastName  = AuthController.currentLastName  ?? '';
    final email     = AuthController.currentUserEmail ?? '';
    final initials  = [
      if (firstName.isNotEmpty) firstName[0],
      if (lastName.isNotEmpty)  lastName[0],
    ].join().toUpperCase();
    final fullName  = '$firstName $lastName'.trim();

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
                child: Column(
                  children: [
                    _buildTopBar(context),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: _ProfileCard(
                        initials: initials.isEmpty ? 'U' : initials,
                        fullName: fullName.isEmpty ? 'User' : fullName,
                        email: email,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── ACCOUNT ──
                          const _SectionLabel(label: 'Account'),
                          _MenuCard(items: [
                            _MenuItem(
                              icon: Icons.person_outline_rounded,
                              iconBg: const Color(0xFFEDE6FF),
                              iconColor: const Color(0xFF7C5CBF),
                              label: 'Edit Profile',
                              sub: 'Update your info',
                              onTap: () async {
                                // ← انتظر رجوع من Edit Profile
                                // وبعدين حدّث البيانات
                                await context.push('/edit-profile');
                                _loadProfile();
                              },
                            ),
                            _MenuItem(
                              icon: Icons.lock_outline_rounded,
                              iconBg: const Color(0xFFE6F4FF),
                              iconColor: const Color(0xFF3B7ADE),
                              label: 'Change Password',
                              sub: 'Keep your account safe',
                              onTap: () =>
                                  context.push('/change-password'),
                            ),
                          ]),

                          // ── PREFERENCES ──
                          const _SectionLabel(label: 'Preferences'),
                          _MenuCard(items: [
                            _MenuItem(
                              icon: Icons.dark_mode_outlined,
                              iconBg: const Color(0xFFE6FFEF),
                              iconColor: const Color(0xFF1D9E75),
                              label: 'Dark Mode',
                              sub: 'Switch appearance',
                              trailing: _ToggleSwitch(
                                  value: false, onChanged: (_) {}),
                            ),
                            _MenuItem(
                              icon: Icons.notifications_none_rounded,
                              iconBg: const Color(0xFFFFF8E1),
                              iconColor: const Color(0xFFFFB300),
                              label: 'Notifications',
                              sub: 'Reminders and alerts',
                              onTap: () {},
                            ),
                            _MenuItem(
                              icon: Icons.star_outline_rounded,
                              iconBg: const Color(0xFFFFEBEE),
                              iconColor: const Color(0xFFE53935),
                              label: 'Rate AI-Genda',
                              sub: 'Share your feedback',
                              onTap: () {},
                            ),
                          ]),

                          const SizedBox(height: 14),

                          // ── SIGN OUT ──
                          _SignOutButton(onTap: () async {
                            HapticFeedback.mediumImpact();
                            await AuthController().signOut();
                            widget.onSignOut();
                          }),

                          const SizedBox(height: 20),

                          // ── FOOTER ──
                          Center(
                            child: Column(children: [
                              Text('Powered by',
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: const Color(0xFFC0BCDA))),
                              Text('ByteVerse',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF7C5CBF))),
                            ]),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 36),
          Text('Profile',
              style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E0F5C))),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFE8E4F5), width: 1.2),
            ),
            child: const Icon(Icons.settings_outlined,
                color: Color(0xFF7C5CBF), size: 18),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// PROFILE CARD
// ══════════════════════════════════════════════════════
class _ProfileCard extends StatelessWidget {
  final String initials;
  final String fullName;
  final String email;
  const _ProfileCard({
    required this.initials,
    required this.fullName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDE9F8), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3FC8).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Avatar ──
          Stack(
            children: [
              Container(
                width: 86,
                height: 86,
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
                      initials,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF5B3A9E),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C5CBF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Name + Verified ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  fullName,
                  style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E0F5C)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FFF0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A7A47),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 6),
                  ),
                  const SizedBox(width: 3),
                  Text('Verified',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A7A47))),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // ── Email ──
          Text(email,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFF8A84A3))),
          const SizedBox(height: 16),

          // ── Stats — بيانات حقيقية من AppData ──
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: Color(0xFFF0EEF8), width: 1)),
            ),
            child: Row(
              children: [
                _StatItem(
                    value: '${AppData.workspaces.length}',
                    label: 'Workspaces'),
                _StatDivider(),
                _StatItem(
                    value: '${AppData.tasks.length}',
                    label: 'Tasks'),
                _StatDivider(),
                _StatItem(
                    value: '${AppData.projects.length}',
                    label: 'Projects'),
                _StatDivider(),
                _StatItem(
                    value: '${AppData.notes.length}',
                    label: 'Notes'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// STAT ITEM & DIVIDER
// ══════════════════════════════════════════════════════
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E0F5C))),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 10, color: const Color(0xFF8A84A3))),
      ]),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 30, color: const Color(0xFFF0EEF8));
  }
}

// ══════════════════════════════════════════════════════
// SECTION LABEL
// ══════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF8A84A3),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// MENU CARD
// ══════════════════════════════════════════════════════
class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE9F8), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3FC8).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              items[i],
              if (i < items.length - 1)
                const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF5F3FF),
                    indent: 64),
            ],
          );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// MENU ITEM
// ══════════════════════════════════════════════════════
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String sub;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.sub,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E0F5C))),
                  const SizedBox(height: 1),
                  Text(sub,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF8A84A3))),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFFC8C4DD), size: 20),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// TOGGLE SWITCH
// ══════════════════════════════════════════════════════
class _ToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleSwitch({required this.value, required this.onChanged});

  @override
  State<_ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<_ToggleSwitch> {
  late bool _val;

  @override
  void initState() {
    super.initState();
    _val = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _val = !_val);
        widget.onChanged(_val);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 42,
        height: 24,
        decoration: BoxDecoration(
          color: _val
              ? const Color(0xFF7C5CBF)
              : const Color(0xFFD8CEF0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment:
              _val ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// SIGN OUT BUTTON
// ══════════════════════════════════════════════════════
class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: const Color(0xFFFFD6D6), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                color: Color(0xFFE53935), size: 20),
            const SizedBox(width: 8),
            Text('Sign Out',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE53935))),
          ],
        ),
      ),
    );
  }
}