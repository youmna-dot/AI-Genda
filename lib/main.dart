// main.dart
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    });

    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    final path = uri.path.toLowerCase();

    // Confirm Email 
    // https://aigenda.runasp.net/Auth/confirm-email?userId=...&code=...
    if (path.contains('confirm-email')) {
      final userId = uri.queryParameters['userId'] ??
          uri.queryParameters['userid'] ?? '';
      final code = uri.queryParameters['code'] ?? '';

      if (userId.isNotEmpty && code.isNotEmpty) {
        router.go('/confirm-email', extra: <String, String>{
          'userId': userId,
          'code':   code,
          'email':  uri.queryParameters['email'] ?? '',
        });
      }
    }

    //  Reset Password 
    //  https://aigenda.runasp.net/Auth/reset-password?email=...
    if (path.contains('reset-password')) {
      final email = uri.queryParameters['email'] ?? '';
      if (email.isNotEmpty) {
        router.go('/reset-password', extra: email);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'AI Genda',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Poppins',
      ),
    );
  }
}