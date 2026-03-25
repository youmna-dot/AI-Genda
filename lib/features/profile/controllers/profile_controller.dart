// lib/features/profile/controllers/profile_controller.dart

import 'package:dio/dio.dart';
import '../../auth/controllers/auth_controller.dart';

// RESULT WRAPPER
class ProfileResult {
  final bool success;
  final String? errorMessage;
  const ProfileResult({required this.success, this.errorMessage});
}

// PROFILE MODEL
class ProfileModel {
  final String firstName;
  final String lastName;
  final String email;
  final String? jobTitle;
  final String? dateOfBirth; // format: yyyy-MM-dd

  const ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.jobTitle,
    this.dateOfBirth,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      firstName:   json['firstName']  ?? '',
      lastName:    json['secondName'] ?? json['lastName'] ?? '',
      email:       json['email']      ?? '',
      jobTitle:    json['jobTitle'],
      dateOfBirth: json['dateOfBirth'],
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty  ? lastName[0]  : '';
    return '$f$l'.toUpperCase();
  }
}

// PROFILE CONTROLLER
class ProfileController {
  static const String _baseUrl = 'https://aigenda.runasp.net';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept':       'application/json',
    },
    validateStatus: (status) => true,
  ));

  // Auth header 
  Future<Options> get _authOptions async {
    final token = await AuthController.getAccessToken();
    return Options(headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    });
  }

  // Error parser 
  String _parseError(dynamic data) {
    if (data == null) return 'Something went wrong. Please try again.';
    try {
      if (data is String && data.isNotEmpty) return data;
      if (data is Map) {
        if (data['problemDetails'] != null) {
          final pd = data['problemDetails'];
          if (pd['error'] is List && (pd['error'] as List).isNotEmpty) {
            final errors = pd['error'] as List;
            return errors.length > 1
                ? errors[1].toString()
                : errors[0].toString();
          }
          if (pd['title'] != null) return pd['title'].toString();
        }
        if (data['message'] != null) return data['message'].toString();
        if (data['title']   != null) return data['title'].toString();
        if (data['errors']  != null) {
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstVal = errors.values.first;
            if (firstVal is List && firstVal.isNotEmpty) {
              return firstVal[0].toString();
            }
          }
        }
      }
    } catch (_) {}
    return 'Something went wrong. Please try again.';
  }

  // GET /me  — 
  Future<ProfileModel?> getProfile() async {
    try {
      final response = await _dio.get('/me', options: await _authOptions);
      if (response.statusCode == 200 && response.data is Map) {
        final profile = ProfileModel.fromJson(
            response.data as Map<String, dynamic>);
        AuthController.currentFirstName = profile.firstName;
        AuthController.currentLastName  = profile.lastName;
        AuthController.currentUserEmail = profile.email;
        return profile;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // PUT /me 
  Future<ProfileResult> updateProfile({
    required String firstName,
    required String lastName,
    required String dateOfBirth, // ← required عشان الباك مش بيقبل فاضي
    String? jobTitle,
  }) async {
    if (firstName.trim().isEmpty) {
      return const ProfileResult(
          success: false, errorMessage: 'First name is required.');
    }
    if (lastName.trim().isEmpty) {
      return const ProfileResult(
          success: false, errorMessage: 'Last name is required.');
    }
    if (dateOfBirth.trim().isEmpty) {
      return const ProfileResult(
          success: false, errorMessage: 'Date of birth is required.');
    }

    try {
      final body = <String, dynamic>{
        'firstName':   firstName.trim(),
        'secondName':  lastName.trim(),
        'dateOfBirth': dateOfBirth.trim(), // format: yyyy-MM-dd
        'jobTitle':    jobTitle?.trim() ?? '',
      };

      final response = await _dio.put(
        '/me',
        data: body,
        options: await _authOptions,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        AuthController.currentFirstName = firstName.trim();
        AuthController.currentLastName  = lastName.trim();
        return const ProfileResult(success: true);
      }
      return ProfileResult(
          success: false, errorMessage: _parseError(response.data));
    } on DioException catch (e) {
      return ProfileResult(
          success: false,
          errorMessage: e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout
              ? 'Connection timeout. Check your internet.'
              : 'Connection error. Check your internet.');
    }
  }

  // PUT /me/change-password
  Future<ProfileResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.isEmpty) {
      return const ProfileResult(
          success: false, errorMessage: 'Enter your current password.');
    }
    if (newPassword.length < 8) {
      return const ProfileResult(
          success: false,
          errorMessage: 'New password must be at least 8 characters.');
    }
    if (newPassword != confirmPassword) {
      return const ProfileResult(
          success: false, errorMessage: "Passwords don't match.");
    }

    try {
      final response = await _dio.put(
        '/me/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword':     newPassword,
        },
        options: await _authOptions,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const ProfileResult(success: true);
      }
      return ProfileResult(
          success: false, errorMessage: _parseError(response.data));
    } on DioException catch (e) {
      return ProfileResult(
          success: false,
          errorMessage: e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout
              ? 'Connection timeout. Check your internet.'
              : 'Connection error. Check your internet.');
    }
  }

  // POST /me/change-email 
  Future<ProfileResult> requestChangeEmail({
    required String newEmail,
  }) async {
    if (!newEmail.trim().contains('@')) {
      return const ProfileResult(
          success: false, errorMessage: 'Enter a valid email.');
    }

    try {
      final response = await _dio.post(
        '/me/change-email',
        data: {'newemail': newEmail.trim().toLowerCase()},
        options: await _authOptions,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const ProfileResult(success: true);
      }
      return ProfileResult(
          success: false, errorMessage: _parseError(response.data));
    } on DioException catch (e) {
      return ProfileResult(
          success: false,
          errorMessage: e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout
              ? 'Connection timeout. Check your internet.'
              : 'Connection error. Check your internet.');
    }
  }

  
  // PUT /me/confirm-change-email 
  
  Future<ProfileResult> confirmChangeEmail({
    required String newEmail,
    required String code,
  }) async {
    if (code.trim().isEmpty) {
      return const ProfileResult(
          success: false, errorMessage: 'Enter the verification code.');
    }

    try {
      final userId = AuthController.currentUserId ?? '';
      final response = await _dio.put(
        '/me/confirm-change-email',
        data: {
          'id':       userId,
          'newemail': newEmail.trim().toLowerCase(),
          'code':     code.replaceAll(RegExp(r'\s+'), '').trim(),
        },
        options: await _authOptions,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        AuthController.currentUserEmail = newEmail.trim().toLowerCase();
        return const ProfileResult(success: true);
      }
      return ProfileResult(
          success: false, errorMessage: _parseError(response.data));
    } on DioException catch (e) {
      return ProfileResult(
          success: false,
          errorMessage: e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout
              ? 'Connection timeout. Check your internet.'
              : 'Connection error. Check your internet.');
    }
  }
}