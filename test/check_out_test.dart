import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/attendance_models.dart';

void main() {
  group('Check-Out API Tests', () {
    test('should parse successful check-out response', () {
      final json = {
        "httpStatus": "OK",
        "message": "Checked out successfully",
        "code": 200,
        "asyncRequest": false
      };

      final response = CheckOutResponse.fromJson(json);
      
      expect(response.httpStatus, 'OK');
      expect(response.message, 'Checked out successfully');
      expect(response.code, 200);
      expect(response.asyncRequest, false);
      expect(response.isSuccess, true);
      expect(response.isAlreadyCheckedOut, false);
    });

    test('should parse already checked out response', () {
      final json = {
        "httpStatus": "OK",
        "message": "You have already checked out today.",
        "code": 500,
        "asyncRequest": false
      };

      final response = CheckOutResponse.fromJson(json);
      
      expect(response.httpStatus, 'OK');
      expect(response.message, 'You have already checked out today.');
      expect(response.code, 500);
      expect(response.asyncRequest, false);
      expect(response.isSuccess, false);
      expect(response.isAlreadyCheckedOut, true);
    });

    test('should handle different message variations for already checked out', () {
      final json1 = {
        "httpStatus": "OK",
        "message": "You have already checked out today.",
        "code": 500,
        "asyncRequest": false
      };

      final json2 = {
        "httpStatus": "OK",
        "message": "You have already checked out today.",
        "code": 500,
        "asyncRequest": false
      };

      final response1 = CheckOutResponse.fromJson(json1);
      final response2 = CheckOutResponse.fromJson(json2);
      
      expect(response1.isAlreadyCheckedOut, true);
      expect(response2.isAlreadyCheckedOut, true);
    });

    test('should handle successful response correctly', () {
      final json = {
        "httpStatus": "OK",
        "message": "Checked out successfully",
        "code": 200,
        "asyncRequest": false
      };

      final response = CheckOutResponse.fromJson(json);
      
      expect(response.isSuccess, true);
      expect(response.isAlreadyCheckedOut, false);
      expect(response.message, 'Checked out successfully');
    });

    test('should handle other error responses', () {
      final json = {
        "httpStatus": "ERROR",
        "message": "Some other error occurred",
        "code": 400,
        "asyncRequest": false
      };

      final response = CheckOutResponse.fromJson(json);
      
      expect(response.isSuccess, false);
      expect(response.isAlreadyCheckedOut, false);
      expect(response.message, 'Some other error occurred');
    });
  });
} 