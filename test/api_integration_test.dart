import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';

void main() {
  group('API Integration Tests', () {
    test('LoginRequest toJson should work correctly', () {
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final json = request.toJson();
      
      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');
      expect(json.length, 2);
    });

    test('LoginResponse fromJson should work correctly', () {
      final json = {
        'httpStatus': 'OK',
        'message': 'Login successful',
        'code': 200,
        'asyncRequest': false,
      };

      final response = LoginResponse.fromJson(json);
      
      expect(response.code, 200);
      expect(response.message, 'Login successful');
      expect(response.httpStatus, 'OK');
      expect(response.asyncRequest, false);
      expect(response.isSuccess, true);
    });

    test('ApiError fromJson should work correctly', () {
      final json = {
        'code': 401,
        'message': 'Invalid credentials',
        'error': 'Authentication failed',
      };

      final error = ApiError.fromJson(json);
      
      expect(error.statusCode, 401);
      expect(error.message, 'Invalid credentials');
      expect(error.error, 'Authentication failed');
      expect(error.displayMessage, 'Invalid credentials. Please check your email and password.');
    });

    test('ApiError fromStatusCode should work correctly', () {
      final error = ApiError.fromStatusCode(500, 'Internal server error');
      
      expect(error.statusCode, 500);
      expect(error.message, 'Internal server error');
      expect(error.error, null);
      expect(error.displayMessage, 'Server error. Please try again later.');
    });
  });
} 