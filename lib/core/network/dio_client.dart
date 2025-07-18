import 'package:dio/dio.dart';
import 'package:attendance_system_hris/core/config/app_config.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';

class DioClient {
  static Dio? _instance;
  static String? _jwtToken;
  
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        headers: AppConfig.defaultHeaders,
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      _LoggingInterceptor(),
      _AuthInterceptor(),
      _ErrorInterceptor(),
    ]);

    return dio;
  }

  static void resetInstance() {
    _instance = null;
    _jwtToken = null;
  }

  // Method to set JWT token manually
  static void setJwtToken(String token) {
    _jwtToken = token;
    final displayLength = token.length > 20 ? 20 : token.length;
    print('🍪 JWT token set: ${token.substring(0, displayLength)}...');
  }

  // Method to get JWT token
  static String? getJwtToken() {
    return _jwtToken;
  }

  // Method to clear JWT token
  static void clearJwtToken() {
    _jwtToken = null;
    print('🧹 JWT token cleared');
  }

  // Method to check if JWT token exists
  static bool hasJwtToken() {
    return _jwtToken != null && _jwtToken!.isNotEmpty;
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
    print('🌐 REQUEST DATA: ${options.data}');
    print('🌐 REQUEST HEADERS: ${options.headers}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('✅ RESPONSE DATA: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('❌ ERROR MESSAGE: ${err.message}');
    print('❌ ERROR DATA: ${err.response?.data}');
    super.onError(err, handler);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add JWT token to request headers if available
    final jwtToken = DioClient.getJwtToken();
    if (jwtToken != null && jwtToken.isNotEmpty) {
      // Add as Authorization header
      options.headers['Authorization'] = 'Bearer $jwtToken';
      
      // Also add as Cookie header for backend compatibility
      options.headers['Cookie'] = '${AppConfig.cookieName}=$jwtToken';
      
      final displayLength = jwtToken.length > 20 ? 20 : jwtToken.length;
      print('🍪 Adding JWT token to request: ${jwtToken.substring(0, displayLength)}...');
    } else {
      print('⚠️ No JWT token found for ${options.path}');
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle successful authentication and store JWT token
    if (response.requestOptions.path.contains('/auth/authenticate') && 
        response.statusCode == 200) {
      print('🔐 Authentication successful - checking for JWT token');
      
      // Try to extract JWT token from response
      final data = response.data;
      if (data != null && data is Map<String, dynamic>) {
        final token = data['data']?['token'] ?? data['token'];
        if (token != null && token is String) {
          DioClient.setJwtToken(token);
          print('🍪 JWT token extracted and stored from response');
        } else {
          print('⚠️ No JWT token found in authentication response');
        }
      }
      
      // Also check Set-Cookie headers
      final setCookieHeaders = response.headers['set-cookie'];
      if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
        print('🍪 Received Set-Cookie headers:');
        for (final cookie in setCookieHeaders) {
          print('   $cookie');
          // Try to extract JWT from Set-Cookie
          if (cookie.contains('${AppConfig.cookieName}=')) {
            final jwtMatch = RegExp(r'jwt=([^;]+)').firstMatch(cookie);
            if (jwtMatch != null) {
              final jwtToken = jwtMatch.group(1);
              if (jwtToken != null) {
                DioClient.setJwtToken(jwtToken);
                print('🍪 JWT token extracted from Set-Cookie header');
              }
            }
          }
        }
      }
    }
    
    super.onResponse(response, handler);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle specific error cases
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        err = err.copyWith(
          error: 'Connection timeout. Please check your internet connection.',
        );
        break;
      case DioExceptionType.badResponse:
        // Handle HTTP error responses
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        
        if (data != null && data is Map<String, dynamic>) {
          // Try to parse error from response
          try {
            // Check if response has code field and it's not 200
            if (data['code'] != null && data['code'] != 200) {
              final apiError = ApiError.fromJson(data);
              err = err.copyWith(error: apiError.displayMessage);
            } else {
              err = err.copyWith(
                error: _getErrorMessage(statusCode),
              );
            }
          } catch (e) {
            // Fallback to generic error message
            err = err.copyWith(
              error: _getErrorMessage(statusCode),
            );
          }
        } else {
          err = err.copyWith(
            error: _getErrorMessage(statusCode),
          );
        }
        break;
      case DioExceptionType.cancel:
        err = err.copyWith(error: 'Request was cancelled');
        break;
      case DioExceptionType.connectionError:
        err = err.copyWith(error: 'No internet connection');
        break;
      default:
        err = err.copyWith(error: 'An unexpected error occurred');
        break;
    }
    
    super.onError(err, handler);
  }

  String _getErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You don\'t have permission to access this resource.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
} 