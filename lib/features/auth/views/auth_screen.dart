// lib/features/auth/views/auth_screen.dart
import 'package:flutter/material.dart';
import 'sign_in_view.dart';
import 'sign_up_view.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isSignIn = true;
  late AnimationController _switchCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _switchCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _fadeAnim = CurvedAnimation(parent: _switchCtrl, curve: Curves.easeInOut);
    _switchCtrl.value = 1.0;
  }

  void _switchView(bool toSignIn) async {
    await _switchCtrl.reverse();
    setState(() => _isSignIn = toSignIn);
    _switchCtrl.forward();
  }

  @override
  void dispose() {
    _switchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: _isSignIn
          ? SignInView(onSwitchToSignUp: () => _switchView(false))
          : SignUpView(onSwitchToSignIn: () => _switchView(true)),
    );
  }
}