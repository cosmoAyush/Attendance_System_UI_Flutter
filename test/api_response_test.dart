import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';

void main() {
  group('LoginResponse Tests', () {
    test('should parse successful login response correctly', () {
      final jsonResponse = {
        "httpStatus": "OK",
        "message": "Login successful",
        "code": 200,
        "asyncRequest": false
      };

      final loginResponse = LoginResponse.fromJson(jsonResponse);

      expect(loginResponse.httpStatus, equals("OK"));
      expect(loginResponse.message, equals("Login successful"));
      expect(loginResponse.code, equals(200));
      expect(loginResponse.asyncRequest, equals(false));
      expect(loginResponse.isSuccess, isTrue);
    });

    test('should handle failed login response correctly', () {
      final jsonResponse = {
        "httpStatus": "BAD_REQUEST",
        "message": "Invalid credentials",
        "code": 401,
        "asyncRequest": false
      };

      final loginResponse = LoginResponse.fromJson(jsonResponse);

      expect(loginResponse.httpStatus, equals("BAD_REQUEST"));
      expect(loginResponse.message, equals("Invalid credentials"));
      expect(loginResponse.code, equals(401));
      expect(loginResponse.asyncRequest, equals(false));
      expect(loginResponse.isSuccess, isFalse);
    });

    test('should check success based on code field', () {
      // Success case
      final successResponse = LoginResponse(
        httpStatus: "OK",
        message: "Login successful",
        code: 200,
        asyncRequest: false,
      );
      expect(successResponse.isSuccess, isTrue);

      // Failure case
      final failureResponse = LoginResponse(
        httpStatus: "OK",
        message: "Login successful",
        code: 401,
        asyncRequest: false,
      );
      expect(failureResponse.isSuccess, isFalse);
    });

    test('should handle missing fields gracefully', () {
      final jsonResponse = {
        "message": "Login successful",
        "code": 200,
      };

      final loginResponse = LoginResponse.fromJson(jsonResponse);

      expect(loginResponse.httpStatus, equals(""));
      expect(loginResponse.message, equals("Login successful"));
      expect(loginResponse.code, equals(200));
      expect(loginResponse.asyncRequest, equals(false));
    });
  });

  group('ApiError Tests', () {
    test('should parse API error response correctly', () {
      final jsonError = {
        "httpStatus": "BAD_REQUEST",
        "message": "Invalid credentials",
        "code": 401,
        "asyncRequest": false
      };

      final apiError = ApiError.fromJson(jsonError);

      expect(apiError.statusCode, equals(401));
      expect(apiError.message, equals("Invalid credentials"));
    });

    test('should provide user-friendly error messages', () {
      final apiError401 = ApiError.fromStatusCode(401, "Unauthorized");
      expect(apiError401.displayMessage, equals("Invalid credentials. Please check your email and password."));

      final apiError404 = ApiError.fromStatusCode(404, "Not Found");
      expect(apiError404.displayMessage, equals("Service not found. Please try again later."));

      final apiError500 = ApiError.fromStatusCode(500, "Server Error");
      expect(apiError500.displayMessage, equals("Server error. Please try again later."));
    });
  });
} 