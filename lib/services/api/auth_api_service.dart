import 'package:dio/dio.dart';
import 'package:attendance_system_hris/core/config/app_config.dart';
import 'package:attendance_system_hris/core/network/dio_client.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';

class AuthApiService {
  static final Dio _dio = DioClient.instance;

  /// Authenticate user with email and password
  /// Returns LoginResponse on success, throws ApiError on failure
  static Future<LoginResponse> authenticate({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Starting authentication for email: $email');
      print('🔐 API URL: ${AppConfig.apiBaseUrl}${AppConfig.authEndpoint}');
      
      final request = LoginRequest(
        email: email,
        password: password,
      );

      print('🔐 Request data: ${request.toJson()}');

      final response = await _dio.post(
        AppConfig.authEndpoint,
        data: request.toJson(),
      );

      print('🔐 Raw response: ${response.data}');
      print('🔐 Response status code: ${response.statusCode}');
      print('🔐 Response headers: ${response.headers}');

      // Parse the response
      final loginResponse = LoginResponse.fromJson(response.data);
      
      // Debug logging
      print('🔐 Parsed Response Code: ${loginResponse.code}');
      print('🔐 Parsed Response Message: ${loginResponse.message}');
      
      // Check the code field from response body
      if (loginResponse.code == 200) {
        print('✅ Login successful - code is 200');
        return loginResponse;
      } else {
        print('❌ Login failed - code is ${loginResponse.code}');
        throw ApiError.fromJson(response.data);
      }
    } on DioException catch (e) {
      print('❌ DioException caught: ${e.type}');
      print('❌ DioException message: ${e.message}');
      print('❌ DioException error: ${e.error}');
      print('❌ DioException response status: ${e.response?.statusCode}');
      print('❌ DioException response data: ${e.response?.data}');
      
      // Handle Dio-specific errors
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Authentication failed',
        );
      }
    } catch (e) {
      print('❌ General exception caught: ${e.toString()}');
      print('❌ Exception type: ${e.runtimeType}');
      
      // Handle other errors
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Logout user
  /// Clears cookies and session data
  static Future<LogoutResponse> logout() async {
    try {
      print('🔐 AuthApiService: Logout request');
      print('🔐 AuthApiService: API URL: ${AppConfig.apiBaseUrl}/auth/logout');
      
      final response = await _dio.post('/auth/logout');
      
      print('🔐 AuthApiService: Raw response: ${response.data}');
      print('🔐 AuthApiService: Response status code: ${response.statusCode}');
      
      final logoutResponse = LogoutResponse.fromJson(response.data);
      
      print('🔐 AuthApiService: Logout response processed');
      print('🔐 AuthApiService: Response Code: ${logoutResponse.code}');
      print('🔐 AuthApiService: Response Message: ${logoutResponse.message}');
      
      return logoutResponse;
    } on DioException catch (e) {
      print('❌ AuthApiService: DioException caught: ${e.type}');
      print('❌ AuthApiService: DioException message: ${e.message}');
      print('❌ AuthApiService: DioException error: ${e.error}');
      print('❌ AuthApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AuthApiService: DioException response data: ${e.response?.data}');
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        // Handle specific error response codes
        final errorData = e.response!.data;
        final statusCode = e.response?.statusCode ?? 500;
        
        switch (statusCode) {
          case 400:
            throw ApiError.fromStatusCode(400, 'Bad request: Invalid logout request');
          case 401:
            throw ApiError.fromStatusCode(401, 'Unauthorized: Session expired or invalid');
          case 403:
            throw ApiError.fromStatusCode(403, 'Forbidden: Access denied');
          case 500:
            throw ApiError.fromStatusCode(500, 'Server error: Internal server error');
          default:
            throw ApiError.fromJson(errorData);
        }
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to logout',
        );
      }
    } catch (e) {
      print('❌ AuthApiService: General exception caught: ${e.toString()}');
      print('❌ AuthApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Check if user is authenticated
  /// Validates current session with backend
  static Future<bool> isAuthenticated() async {
    try {
      print('🔐 AuthApiService: Checking authentication status');
      print('🔐 AuthApiService: API URL: ${AppConfig.apiBaseUrl}${AppConfig.isAuthenticatedEndpoint}');
      
      final response = await _dio.post(AppConfig.isAuthenticatedEndpoint);
      
      print('🔐 AuthApiService: Raw response: ${response.data}');
      print('🔐 AuthApiService: Response status code: ${response.statusCode}');
      
      // Parse the response
      final authResponse = LoginResponse.fromJson(response.data);
      
      print('🔐 AuthApiService: Parsed Response Code: ${authResponse.code}');
      print('🔐 AuthApiService: Parsed Response Message: ${authResponse.message}');
      
      return authResponse.code == 200;
    } on DioException catch (e) {
      print('❌ AuthApiService: DioException caught: ${e.type}');
      print('❌ AuthApiService: DioException message: ${e.message}');
      print('❌ AuthApiService: DioException error: ${e.error}');
      print('❌ AuthApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AuthApiService: DioException response data: ${e.response?.data}');
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        final authResponse = LoginResponse.fromJson(e.response!.data);
        print('🔐 AuthApiService: Error Response Code: ${authResponse.code}');
        print('🔐 AuthApiService: Error Response Message: ${authResponse.message}');
        return authResponse.code == 200;
      }
      
      return false;
    } catch (e) {
      print('❌ AuthApiService: General exception caught: ${e.toString()}');
      print('❌ AuthApiService: Exception type: ${e.runtimeType}');
      return false;
    }
  }

  /// Quick attendance action (check-in/check-out)
  /// Allows users to mark attendance without full login
  static Future<QuickAttendanceResponse> quickAttendance(QuickAttendanceRequest request) async {
    try {
      print('⚡ AuthApiService: Quick attendance action');
      print('⚡ AuthApiService: API URL: ${AppConfig.apiBaseUrl}${AppConfig.quickAttendanceEndpoint}');
      print('⚡ AuthApiService: Request data: ${request.toJson()}');
      
      final response = await _dio.post(AppConfig.quickAttendanceEndpoint, data: request.toJson());
      
      print('⚡ AuthApiService: Raw response: ${response.data}');
      print('⚡ AuthApiService: Response status code: ${response.statusCode}');
      
      final quickAttendanceResponse = QuickAttendanceResponse.fromJson(response.data);
      
      print('⚡ AuthApiService: Quick attendance response processed');
      print('⚡ AuthApiService: Response Code: ${quickAttendanceResponse.code}');
      print('⚡ AuthApiService: Response Message: ${quickAttendanceResponse.message}');
      
      return quickAttendanceResponse;
    } on DioException catch (e) {
      print('❌ AuthApiService: DioException caught: ${e.type}');
      print('❌ AuthApiService: DioException message: ${e.message}');
      print('❌ AuthApiService: DioException error: ${e.error}');
      print('❌ AuthApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AuthApiService: DioException response data: ${e.response?.data}');
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        // Handle the specific error response format
        final errorData = e.response!.data;
        if (errorData['code'] == 500) {
          // This is the expected error response for already checked out
          return QuickAttendanceResponse.fromJson(errorData);
        } else {
          throw ApiError.fromJson(errorData);
        }
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to mark attendance',
        );
      }
    } catch (e) {
      print('❌ AuthApiService: General exception caught: ${e.toString()}');
      print('❌ AuthApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Refresh authentication token/session
  static Future<bool> refreshToken() async {
    try {
      final response = await _dio.post('/auth/refresh');
      return response.statusCode == 200;
    } on DioException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Forgot password - send OTP to email
  static Future<ForgotPasswordResponse> forgotPassword(String email) async {
    try {
      print('🔐 AuthApiService: Forgot password request');
      print('🔐 AuthApiService: API URL: ${AppConfig.apiBaseUrl}${AppConfig.forgotPasswordEndpoint}');
      print('🔐 AuthApiService: Email: $email');
      
      final request = ForgotPasswordRequest(email: email);
      final response = await _dio.post(AppConfig.forgotPasswordEndpoint, data: request.toJson());
      
      print('🔐 AuthApiService: Raw response: ${response.data}');
      print('🔐 AuthApiService: Response status code: ${response.statusCode}');
      
      final forgotPasswordResponse = ForgotPasswordResponse.fromJson(response.data);
      
      print('🔐 AuthApiService: Forgot password response processed');
      print('🔐 AuthApiService: Response Code: ${forgotPasswordResponse.code}');
      print('🔐 AuthApiService: Response Message: ${forgotPasswordResponse.message}');
      
      return forgotPasswordResponse;
    } on DioException catch (e) {
      print('❌ AuthApiService: DioException caught: ${e.type}');
      print('❌ AuthApiService: DioException message: ${e.message}');
      print('❌ AuthApiService: DioException error: ${e.error}');
      print('❌ AuthApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AuthApiService: DioException response data: ${e.response?.data}');
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to send forgot password request',
        );
      }
    } catch (e) {
      print('❌ AuthApiService: General exception caught: ${e.toString()}');
      print('❌ AuthApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Verify OTP and update password
  static Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    try {
      print('🔐 AuthApiService: Verify OTP request');
      print('🔐 AuthApiService: API URL: ${AppConfig.apiBaseUrl}${AppConfig.verifyOtpEndpoint}');
      print('🔐 AuthApiService: Request data: ${request.toJson()}');
      
      final response = await _dio.post(AppConfig.verifyOtpEndpoint, data: request.toJson());
      
      print('🔐 AuthApiService: Raw response: ${response.data}');
      print('🔐 AuthApiService: Response status code: ${response.statusCode}');
      
      final verifyOtpResponse = VerifyOtpResponse.fromJson(response.data);
      
      print('🔐 AuthApiService: Verify OTP response processed');
      print('🔐 AuthApiService: Response Code: ${verifyOtpResponse.code}');
      print('🔐 AuthApiService: Response Message: ${verifyOtpResponse.message}');
      
      return verifyOtpResponse;
    } on DioException catch (e) {
      print('❌ AuthApiService: DioException caught: ${e.type}');
      print('❌ AuthApiService: DioException message: ${e.message}');
      print('❌ AuthApiService: DioException error: ${e.error}');
      print('❌ AuthApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AuthApiService: DioException response data: ${e.response?.data}');
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        // Handle specific error response codes
        final errorData = e.response!.data;
        if (errorData['code'] == 500 || errorData['code'] == 404 || errorData['code'] == 401) {
          return VerifyOtpResponse.fromJson(errorData);
        } else {
          throw ApiError.fromJson(errorData);
        }
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to verify OTP',
        );
      }
    } catch (e) {
      print('❌ AuthApiService: General exception caught: ${e.toString()}');
      print('❌ AuthApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
} 