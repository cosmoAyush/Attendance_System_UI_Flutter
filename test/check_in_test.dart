import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/attendance_models.dart';

void main() {
  group('Check-In API Tests', () {
    test('should parse successful check-in response', () {
      final json = {
        "httpStatus": "OK",
        "message": "Attendance marked successfully",
        "code": 200,
        "asyncRequest": false
      };

      final response = CheckInResponse.fromJson(json);
      
      expect(response.httpStatus, 'OK');
      expect(response.message, 'Attendance marked successfully');
      expect(response.code, 200);
      expect(response.asyncRequest, false);
      expect(response.isSuccess, true);
      expect(response.isAlreadyMarked, false);
    });

    test('should parse already marked attendance response', () {
      final json = {
        "httpStatus": "OK",
        "message": "You have already marked your attendance today",
        "code": 500,
        "asyncRequest": false
      };

      final response = CheckInResponse.fromJson(json);
      
      expect(response.httpStatus, 'OK');
      expect(response.message, 'You have already marked your attendance today');
      expect(response.code, 500);
      expect(response.asyncRequest, false);
      expect(response.isSuccess, false);
      expect(response.isAlreadyMarked, true);
    });

    test('should handle different message variations for already marked', () {
      final json1 = {
        "httpStatus": "OK",
        "message": "You have already marked your attendance today",
        "code": 500,
        "asyncRequest": false
      };

      final json2 = {
        "httpStatus": "OK",
        "message": "You have already marked your attendance today",
        "code": 500,
        "asyncRequest": false
      };

      final response1 = CheckInResponse.fromJson(json1);
      final response2 = CheckInResponse.fromJson(json2);
      
      expect(response1.isAlreadyMarked, true);
      expect(response2.isAlreadyMarked, true);
    });

    test('should handle successful response correctly', () {
      final json = {
        "httpStatus": "OK",
        "message": "Attendance marked successfully",
        "code": 200,
        "asyncRequest": false
      };

      final response = CheckInResponse.fromJson(json);
      
      expect(response.isSuccess, true);
      expect(response.isAlreadyMarked, false);
      expect(response.message, 'Attendance marked successfully');
    });

    test('should handle other error responses', () {
      final json = {
        "httpStatus": "ERROR",
        "message": "Some other error occurred",
        "code": 400,
        "asyncRequest": false
      };

      final response = CheckInResponse.fromJson(json);
      
      expect(response.isSuccess, false);
      expect(response.isAlreadyMarked, false);
      expect(response.message, 'Some other error occurred');
    });
  });
} 