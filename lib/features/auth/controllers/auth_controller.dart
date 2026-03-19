// lib/features/auth/controllers/auth_controller.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  const AuthResult({required this.success, this.errorMessage});
}

class AuthController {
  static const String _baseUrl = 'https://aigenda.runasp.net/api';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    validateStatus: (status) => true,
  ));

  static String? currentUserEmail;
  static String? currentFirstName;
  static String? currentLastName;
  static String? currentUserId;
  static String? _accessToken;
  static String? _refreshToken;

  static String? get currentUserName {
    final full = '${currentFirstName ?? ''} ${currentLastName ?? ''}'.trim();
    return full.isEmpty ? null : full;
  }

  static Future<void> _saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  static Future<String?> getAccessToken() async {
    if (_accessToken != null) return _accessToken;
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    return _accessToken;
  }

  static Future<Options> get _authOptions async {
    final token = await getAccessToken();
    return Options(headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    });
  }

  // REGISTER
  Future<AuthResult> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    if (firstName.trim().isEmpty)
      return const AuthResult(success: false, errorMessage: 'Enter your first name.');
    if (lastName.trim().isEmpty)
      return const AuthResult(success: false, errorMessage: 'Enter your last name.');
    if (!email.trim().contains('@'))
      return const AuthResult(success: false, errorMessage: 'Enter a valid email.');
    if (password.length < 8)
      return const AuthResult(success: false, errorMessage: 'Password must be at least 8 characters.');

    try {
      final response = await _dio.post('/Auth/register', data: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'confirmPassword': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentFirstName = firstName.trim();
        currentLastName = lastName.trim();
        currentUserEmail = email.trim().toLowerCase();

        final data = response.data;
        if (data != null && data is Map) {
          currentUserId = data['id'] ?? data['userId'] ?? data['user_id'] ?? '';
          currentLastName = data['secondName'] ?? data['lastName'] ?? lastName.trim();
          final token = data['accessToken'] ?? data['token'];
          if (token != null) {
            await _saveTokens(token, data['refreshToken'] ?? '');
          }
        }
        return const AuthResult(success: true);
      } else {
        return AuthResult(success: false, errorMessage: _parseError(response.data));
      }
    } on DioException catch (e) {
      return AuthResult(
          success: false,
          errorMessage: e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout
              ? 'Connection timeout. Check your internet.'
              : 'Connection error. Check your internet.');
    } catch (_) {
      return const AuthResult(success: false, errorMessage: 'Connection error. Check your internet.');
    }
  }

  // LOGIN
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    if (!email.trim().contains('@'))
      return const AuthResult(success: false, errorMessage: 'Enter a valid email.');
    if (password.isEmpty)
      return const AuthResult(success: false, errorMessage: 'Enter your password.');

    try {
      final response = await _dio.post('/Auth', data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      final data = response.data;

      if (data is Map && data['problemDetails'] != null) {
        return AuthResult(success: false, errorMessage: _parseError(data));
      }

      final token = data is Map ? (data['accessToken'] ?? data['token']) : null;

      if (response.statusCode == 200 && token != null) {
        await _saveTokens(token, data['refreshToken'] ?? '');
        currentUserEmail = email.trim().toLowerCase();
        currentFirstName = data['firstName'] ?? '';
        currentLastName  = data['secondName'] ?? data['lastName'] ?? '';
        currentUserId    = data['id'] ?? data['userId'] ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('first_name', currentFirstName ?? '');
        await prefs.setString('last_name',  currentLastName  ?? '');
        await prefs.setString('email',      currentUserEmail ?? '');
        await prefs.setString('user_id',    currentUserId    ?? '');

        return const AuthResult(success: true);
      } else {
        return AuthResult(success: false, errorMessage: _parseError(data));
      }
    } on DioException catch (e) {
      return AuthResult(
          success: false,
          errorMessage: e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout
              ? 'Connection timeout. Check your internet.'
              : 'Connection error. Check your internet.');
    } catch (_) {
      return const AuthResult(success: false, errorMessage: 'Connection error. Check your internet.');
    }
  }

  // CONFIRM EMAIL
  Future<AuthResult> confirmEmail({
    required String userId,
    required String code,
  }) async {
    try {
      final response = await _dio.post('/Auth/confirm-email', data: {
        'userId': userId.trim(),
        'code': code.replaceAll(RegExp(r'\s+'), '').trim(),
      });

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const AuthResult(success: true);
      } else {
        return AuthResult(success: false, errorMessage: _parseError(response.data));
      }
    } on DioException catch (_) {
      return const AuthResult(success: false, errorMessage: 'Connection error. Check your internet.');
    }
  }

  // RESEND CONFIRM EMAIL
  Future<AuthResult> resendConfirmEmail({required String email}) async {
    try {
      final response = await _dio.post('/Auth/resend-confirm-email',
          data: {'email': email.trim().toLowerCase()});

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const AuthResult(success: true);
      } else {
        return AuthResult(success: false, errorMessage: _parseError(response.data));
      }
    } on DioException catch (_) {
      return const AuthResult(success: false, errorMessage: 'Connection error. Check your internet.');
    }
  }

  // FORGOT PASSWORD
  Future<AuthResult> sendPasswordReset({required String email}) async {
    if (!email.trim().contains('@'))
      return const AuthResult(success: false, errorMessage: 'Enter a valid email.');

    try {
      final response = await _dio.post('/Auth/forget-password',
          data: {'email': email.trim().toLowerCase()});

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return const AuthResult(success: true);
      } else {
        return AuthResult(success: false, errorMessage: _parseError(response.data));
      }
    } on DioException catch (_) {
      return const AuthResult(success: false, errorMessage: 'Connection error. Check your internet.');
    }
  }

  // RESET PASSWORD
  Future<AuthResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.put('/Auth/reset-password', data: {
        'email': email.trim().toLowerCase(),
        'code': code.replaceAll(RegExp(r'\s+'), '').trim(),
        'newPassword': newPassword,
      });

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const AuthResult(success: true);
      } else {
        return AuthResult(success: false, errorMessage: _parseError(response.data));
      }
    } on DioException catch (_) {
      return const AuthResult(success: false, errorMessage: 'Connection error. Check your internet.');
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    _accessToken     = null;
    _refreshToken    = null;
    currentUserEmail = null;
    currentFirstName = null;
    currentLastName  = null;
    currentUserId    = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // RESTORE SESSION
  static Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) return false;
    _accessToken     = token;
    _refreshToken    = prefs.getString('refresh_token');
    currentFirstName = prefs.getString('first_name');
    currentLastName  = prefs.getString('last_name');
    currentUserEmail = prefs.getString('email');
    currentUserId    = prefs.getString('user_id');
    return true;
  }

  // PARSE ERROR
  String _parseError(dynamic data) {
    if (data == null) return 'Something went wrong. Please try again.';
    try {
      if (data is String) return data;
      if (data['problemDetails'] != null) {
        final pd = data['problemDetails'];
        if (pd['error'] is List && (pd['error'] as List).isNotEmpty) {
          final errors = pd['error'] as List;
          return errors.length > 1 ? errors[1].toString() : errors[0].toString();
        }
        if (pd['title'] != null) return pd['title'].toString();
      }
      if (data['message'] != null) return data['message'].toString();
      if (data['title'] != null) return data['title'].toString();
      if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstVal = errors.values.first;
          if (firstVal is List && firstVal.isNotEmpty) return firstVal[0].toString();
        }
      }
    } catch (_) {}
    return 'Something went wrong. Please try again.';
  }
}