# API Integration Documentation

## Overview

This document describes the API integration setup for the Employee Attendance System, including configuration, authentication, and error handling.

## 🏗️ Architecture

### File Structure
```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart          # API configuration
│   └── network/
│       └── dio_client.dart          # HTTP client setup
├── models/
│   └── api/
│       └── auth_models.dart         # Authentication models
└── services/
    └── api/
        ├── base_api_service.dart    # Base API service
        └── auth_api_service.dart    # Authentication API service
```

## ⚙️ Configuration

### App Configuration (`lib/core/config/app_config.dart`)

```dart
class AppConfig {
  // API Configuration
  static const String baseUrl = "http://localhost:8080";
  static const String apiVersion = "/api/v1";
  static const String apiBaseUrl = "$baseUrl$apiVersion";
  
  // API Endpoints
  static const String authEndpoint = "/auth/authenticate";
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Cookie Configuration
  static const String cookieName = 'jwt';
  static const bool withCredentials = true;
}
```

## 🔐 Authentication

### Cookie-Based JWT Authentication

The system uses cookie-based JWT authentication with Spring Boot backend:

- **Login Endpoint**: `POST /api/v1/auth/authenticate`
- **Authentication**: Cookie-based (automatic)
- **Session Management**: Automatic cookie handling

### Request Format
```json
{
  "email": "string",
  "password": "string"
}
```

### Response Format
```json
{
  "httpStatus": "OK",
  "message": "Login successful",
  "code": 200,
  "asyncRequest": false
}
```

## 📡 HTTP Client Setup

### Dio Configuration (`lib/core/network/dio_client.dart`)

```dart
class DioClient {
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
}
```

### Interceptors

1. **Logging Interceptor**: Logs all requests and responses
2. **Auth Interceptor**: Handles cookie-based authentication
3. **Error Interceptor**: Standardizes error handling

## 🎯 API Services

### Base API Service (`lib/services/api/base_api_service.dart`)

Provides common HTTP methods and error handling:

```dart
abstract class BaseApiService {
  static final Dio _dio = DioClient.instance;

  // GET request
  static Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters});

  // POST request
  static Future<Response> post(String endpoint, {dynamic data});

  // PUT request
  static Future<Response> put(String endpoint, {dynamic data});

  // DELETE request
  static Future<Response> delete(String endpoint, {dynamic data});
}
```

### Authentication API Service (`lib/services/api/auth_api_service.dart`)

```dart
class AuthApiService {
  static final Dio _dio = DioClient.instance;

  // Authenticate user
  static Future<LoginResponse> authenticate({
    required String email,
    required String password,
  }) async {
    // Implementation with proper error handling
  }

  // Logout user
  static Future<void> logout() async {
    // Implementation
  }

  // Check authentication status
  static Future<bool> isAuthenticated() async {
    // Implementation
  }
}
```

## 📊 Data Models

### Authentication Models (`lib/models/api/auth_models.dart`)

```dart
// Login Request
class LoginRequest {
  final String email;
  final String password;
  
  Map<String, dynamic> toJson();
}

// Login Response
class LoginResponse {
  final String httpStatus;
  final String message;
  final int code;
  final bool asyncRequest;
  
  bool get isSuccess => code == 200 && httpStatus == 'OK';
}

// API Error
class ApiError {
  final int statusCode;
  final String message;
  final String? error;
  
  String get displayMessage; // User-friendly error message
}
```

## 🚨 Error Handling

### Error Types

1. **401 Unauthorized**: Invalid credentials
2. **404 Not Found**: Resource not found
3. **500 Internal Server Error**: Server error
4. **Network Errors**: Connection issues
5. **Timeout Errors**: Request timeouts

### Error Handling in UI

```dart
try {
  final success = await AuthService.login(
    email: email,
    password: password,
  );
  
  if (success) {
    // Navigate to dashboard
  }
} on ApiError catch (e) {
  // Show user-friendly error message
  _showErrorSnackBar(e.displayMessage);
} catch (e) {
  // Handle unexpected errors
  _showErrorSnackBar('An unexpected error occurred');
}
```

## 🔧 Usage Examples

### Login Implementation

```dart
// In login screen
Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final success = await AuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      _showSuccessSnackBar('Login successful!');
      AppRouter.navigateToAndRemoveUntil(context, AppRouter.dashboard);
    }
  } on ApiError catch (e) {
    if (mounted) {
      _showErrorSnackBar(e.displayMessage);
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

### Adding New API Endpoints

1. **Add endpoint to config**:
```dart
// In app_config.dart
static const String attendanceEndpoint = "/attendance";
```

2. **Create API service**:
```dart
// In attendance_api_service.dart
class AttendanceApiService {
  static Future<List<AttendanceRecord>> getAttendanceRecords() async {
    final response = await BaseApiService.get(AppConfig.attendanceEndpoint);
    
    if (BaseApiService.isSuccess(response)) {
      return BaseApiService.parseResponseList(
        response,
        AttendanceRecord.fromJson,
      );
    }
    
    throw ApiError.fromStatusCode(response.statusCode ?? 500, 'Failed to fetch attendance');
  }
}
```

## 🔒 Security Considerations

### Cookie Security
- Cookies are automatically handled by the browser/device
- `withCredentials: true` ensures cookies are sent with requests
- HTTPS should be used in production

### Error Information
- Don't expose sensitive information in error messages
- Use generic messages for security-related errors
- Log detailed errors for debugging

## 🧪 Testing

### Unit Tests
```dart
test('login should return success for valid credentials', () async {
  // Mock Dio response
  when(dio.post(any, data: anyNamed('data')))
      .thenAnswer((_) async => Response(
            data: {
              'httpStatus': 'OK',
              'message': 'Login successful',
              'code': 200,
              'asyncRequest': false,
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

  final result = await AuthApiService.authenticate(
    email: 'test@example.com',
    password: 'password',
  );

  expect(result.isSuccess, true);
});
```

### Integration Tests
```dart
testWidgets('login should show error for invalid credentials', (tester) async {
  await tester.pumpWidget(LoginScreen());
  
  await tester.enterText(find.byType(TextFormField).first, 'invalid@email.com');
  await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
  await tester.tap(find.text('Sign In'));
  await tester.pump();
  
  expect(find.text('Invalid credentials'), findsOneWidget);
});
```

## 🚀 Deployment

### Production Configuration
1. Update `baseUrl` in `app_config.dart`
2. Enable HTTPS
3. Configure proper CORS settings
4. Set up proper error logging

### Environment Variables
```dart
// For different environments
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
```

## 📝 Best Practices

1. **Error Handling**: Always handle API errors gracefully
2. **Loading States**: Show loading indicators during API calls
3. **Validation**: Validate input before making API calls
4. **Logging**: Log API requests and responses for debugging
5. **Retry Logic**: Implement retry logic for network failures
6. **Caching**: Cache frequently accessed data
7. **Offline Support**: Handle offline scenarios gracefully

## 🔄 Future Enhancements

1. **Token Refresh**: Automatic token refresh
2. **Request Caching**: Implement request caching
3. **Offline Queue**: Queue requests when offline
4. **Retry Logic**: Automatic retry for failed requests
5. **Request Cancellation**: Cancel ongoing requests
6. **Progress Tracking**: Track upload/download progress 