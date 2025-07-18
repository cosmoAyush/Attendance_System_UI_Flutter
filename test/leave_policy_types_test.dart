import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/leave_models.dart';

void main() {
  group('LeavePolicyTypesResponse Tests', () {
    test('should parse valid JSON response', () {
      final json = {
        "httpStatus": "OK",
        "message": "Leave policy fetched successfully.",
        "code": 200,
        "data": [
          {
            "id": 1,
            "leaveType": "Sick Leave",
            "maxDay": "78",
            "leavePolicyCategory": {
              "id": 1,
              "name": "Monthly"
            },
            "isDeleted": false,
            "createdAt": "2025-07-08T05:54:52.000+00:00",
            "updatedAt": "2025-07-08T05:54:52.000+00:00"
          },
          {
            "id": 2,
            "leaveType": "Casual Leave",
            "maxDay": "12",
            "leavePolicyCategory": {
              "id": 1,
              "name": "Monthly"
            },
            "isDeleted": false,
            "createdAt": "2025-07-08T05:54:52.000+00:00",
            "updatedAt": "2025-07-08T05:54:52.000+00:00"
          }
        ],
        "asyncRequest": false
      };

      final response = LeavePolicyTypesResponse.fromJson(json);

      expect(response.httpStatus, equals('OK'));
      expect(response.message, equals('Leave policy fetched successfully.'));
      expect(response.code, equals(200));
      expect(response.asyncRequest, isFalse);
      expect(response.data, hasLength(2));
      expect(response.isSuccess, isTrue);
    });

    test('should handle empty data array', () {
      final json = {
        "httpStatus": "OK",
        "message": "No policies found.",
        "code": 200,
        "data": [],
        "asyncRequest": false
      };

      final response = LeavePolicyTypesResponse.fromJson(json);

      expect(response.data, isEmpty);
      expect(response.isSuccess, isTrue);
    });

    test('should handle missing optional fields', () {
      final json = {
        "code": 200,
        "data": []
      };

      final response = LeavePolicyTypesResponse.fromJson(json);

      expect(response.httpStatus, equals(''));
      expect(response.message, equals(''));
      expect(response.asyncRequest, isFalse);
      expect(response.data, isEmpty);
    });
  });

  group('LeavePolicyType Tests', () {
    test('should parse valid policy data', () {
      final json = {
        "id": 1,
        "leaveType": "Sick Leave",
        "maxDay": "78",
        "leavePolicyCategory": {
          "id": 1,
          "name": "Monthly"
        },
        "isDeleted": false,
        "createdAt": "2025-07-08T05:54:52.000+00:00",
        "updatedAt": "2025-07-08T05:54:52.000+00:00"
      };

      final policy = LeavePolicyType.fromJson(json);

      expect(policy.id, equals(1));
      expect(policy.leaveType, equals('Sick Leave'));
      expect(policy.maxDay, equals('78'));
      expect(policy.maxDayInt, equals(78));
      expect(policy.isDeleted, isFalse);
      expect(policy.createdAt, equals('2025-07-08T05:54:52.000+00:00'));
      expect(policy.updatedAt, equals('2025-07-08T05:54:52.000+00:00'));
    });

    test('should handle invalid maxDay string', () {
      final json = {
        "id": 1,
        "leaveType": "Test Leave",
        "maxDay": "invalid",
        "leavePolicyCategory": {
          "id": 1,
          "name": "Monthly"
        },
        "isDeleted": false,
        "createdAt": "2025-07-08T05:54:52.000+00:00",
        "updatedAt": "2025-07-08T05:54:52.000+00:00"
      };

      final policy = LeavePolicyType.fromJson(json);

      expect(policy.maxDay, equals('invalid'));
      expect(policy.maxDayInt, equals(0));
    });

    test('should handle missing optional fields', () {
      final json = {
        "id": 1,
        "leaveType": "Test Leave",
        "maxDay": "5"
      };

      final policy = LeavePolicyType.fromJson(json);

      expect(policy.id, equals(1));
      expect(policy.leaveType, equals('Test Leave'));
      expect(policy.maxDay, equals('5'));
      expect(policy.isDeleted, isFalse);
      expect(policy.createdAt, equals(''));
      expect(policy.updatedAt, equals(''));
    });
  });

  group('LeavePolicyCategory Tests', () {
    test('should parse valid category data', () {
      final json = {
        "id": 1,
        "name": "Monthly"
      };

      final category = LeavePolicyCategory.fromJson(json);

      expect(category.id, equals(1));
      expect(category.name, equals('Monthly'));
    });

    test('should handle missing fields', () {
      final json = <String, dynamic>{};

      final category = LeavePolicyCategory.fromJson(json);

      expect(category.id, equals(0));
      expect(category.name, equals(''));
    });
  });

  group('Integration Tests', () {
    test('should parse complete API response', () {
      final json = {
        "httpStatus": "OK",
        "message": "Leave policy fetched successfully.",
        "code": 200,
        "data": [
          {
            "id": 1,
            "leaveType": "Sick Leave",
            "maxDay": "78",
            "leavePolicyCategory": {
              "id": 1,
              "name": "Monthly"
            },
            "isDeleted": false,
            "createdAt": "2025-07-08T05:54:52.000+00:00",
            "updatedAt": "2025-07-08T05:54:52.000+00:00"
          },
          {
            "id": 2,
            "leaveType": "Annual Leave",
            "maxDay": "30",
            "leavePolicyCategory": {
              "id": 2,
              "name": "Yearly"
            },
            "isDeleted": false,
            "createdAt": "2025-07-08T05:54:52.000+00:00",
            "updatedAt": "2025-07-08T05:54:52.000+00:00"
          }
        ],
        "asyncRequest": false
      };

      final response = LeavePolicyTypesResponse.fromJson(json);

      expect(response.data, hasLength(2));
      
      final firstPolicy = response.data[0];
      expect(firstPolicy.leaveType, equals('Sick Leave'));
      expect(firstPolicy.maxDayInt, equals(78));
      expect(firstPolicy.leavePolicyCategory.name, equals('Monthly'));
      
      final secondPolicy = response.data[1];
      expect(secondPolicy.leaveType, equals('Annual Leave'));
      expect(secondPolicy.maxDayInt, equals(30));
      expect(secondPolicy.leavePolicyCategory.name, equals('Yearly'));
    });
  });
} 