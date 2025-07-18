import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/leave_models.dart';

void main() {
  group('LeaveRequestResponse Tests', () {
    test('should parse successful response correctly', () {
      final json = {
        "httpStatus": "OK",
        "message": "Leave request added successfully.",
        "code": 201,
        "asyncRequest": false
      };

      final response = LeaveRequestResponse.fromJson(json);

      expect(response.httpStatus, equals('OK'));
      expect(response.message, equals('Leave request added successfully.'));
      expect(response.code, equals(201));
      expect(response.asyncRequest, isFalse);
      expect(response.isSuccess, isTrue);
      expect(response.isAttendanceExists, isFalse);
    });

    test('should parse attendance exists error response correctly', () {
      final json = {
        "httpStatus": "OK",
        "message": "Attendance already exists for the date: Fri Jul 11",
        "code": 500,
        "asyncRequest": false
      };

      final response = LeaveRequestResponse.fromJson(json);

      expect(response.httpStatus, equals('OK'));
      expect(response.message, equals('Attendance already exists for the date: Fri Jul 11'));
      expect(response.code, equals(500));
      expect(response.asyncRequest, isFalse);
      expect(response.isSuccess, isFalse);
      expect(response.isAttendanceExists, isTrue);
    });

    test('should parse other error response correctly', () {
      final json = {
        "httpStatus": "OK",
        "message": "Some other error occurred.",
        "code": 400,
        "asyncRequest": false
      };

      final response = LeaveRequestResponse.fromJson(json);

      expect(response.httpStatus, equals('OK'));
      expect(response.message, equals('Some other error occurred.'));
      expect(response.code, equals(400));
      expect(response.asyncRequest, isFalse);
      expect(response.isSuccess, isFalse);
      expect(response.isAttendanceExists, isFalse);
    });
  });

  group('LeaveRequestData Tests', () {
    test('should create leave request data correctly', () {
      final startDate = DateTime(2025, 7, 10);
      final endDate = DateTime(2025, 7, 12);
      final requestData = LeaveRequestData(
        startDate: startDate,
        endDate: endDate,
        leaveType: 'Sick Leave',
        reason: 'Not feeling well, need to rest',
      );

      expect(requestData.startDate, equals(startDate));
      expect(requestData.endDate, equals(endDate));
      expect(requestData.leaveType, equals('Sick Leave'));
      expect(requestData.reason, equals('Not feeling well, need to rest'));
    });

    test('should convert to JSON correctly', () {
      final startDate = DateTime(2025, 7, 10);
      final endDate = DateTime(2025, 7, 12);
      final requestData = LeaveRequestData(
        startDate: startDate,
        endDate: endDate,
        leaveType: 'Annual Leave',
        reason: 'Family vacation',
      );

      final json = requestData.toJson();

      expect(json['startDate'], equals('2025-07-10T00:00:00.000'));
      expect(json['endDate'], equals('2025-07-12T00:00:00.000'));
      expect(json['leaveType'], equals('Annual Leave'));
      expect(json['reason'], equals('Family vacation'));
    });

    test('should format dates correctly', () {
      final startDate = DateTime(2025, 7, 10);
      final endDate = DateTime(2025, 7, 15);
      final requestData = LeaveRequestData(
        startDate: startDate,
        endDate: endDate,
        leaveType: 'Casual Leave',
        reason: 'Personal work',
      );

      expect(requestData.formattedStartDate, equals('10/07/2025'));
      expect(requestData.formattedEndDate, equals('15/07/2025'));
    });

    test('should calculate number of days correctly', () {
      final startDate = DateTime(2025, 7, 10);
      final endDate = DateTime(2025, 7, 12);
      final requestData = LeaveRequestData(
        startDate: startDate,
        endDate: endDate,
        leaveType: 'Sick Leave',
        reason: 'Medical appointment',
      );

      expect(requestData.numberOfDays, equals(3)); // 10, 11, 12 = 3 days
    });

    test('should handle single day leave', () {
      final date = DateTime(2025, 7, 10);
      final requestData = LeaveRequestData(
        startDate: date,
        endDate: date,
        leaveType: 'Casual Leave',
        reason: 'Personal work',
      );

      expect(requestData.numberOfDays, equals(1));
      expect(requestData.formattedStartDate, equals('10/07/2025'));
      expect(requestData.formattedEndDate, equals('10/07/2025'));
    });

    test('should handle different leave types', () {
      final startDate = DateTime(2025, 7, 10);
      final endDate = DateTime(2025, 7, 12);

      final sickLeave = LeaveRequestData(
        startDate: startDate,
        endDate: endDate,
        leaveType: 'Sick Leave',
        reason: 'Not feeling well',
      );

      final annualLeave = LeaveRequestData(
        startDate: startDate,
        endDate: endDate,
        leaveType: 'Annual Leave',
        reason: 'Vacation',
      );

      final maternityLeave = LeaveRequestData(
        startDate: startDate,
        endDate: endDate,
        leaveType: 'Maternity Leave',
        reason: 'Pregnancy',
      );

      expect(sickLeave.leaveType, equals('Sick Leave'));
      expect(annualLeave.leaveType, equals('Annual Leave'));
      expect(maternityLeave.leaveType, equals('Maternity Leave'));
    });

    test('should handle long reasons', () {
      final startDate = DateTime(2025, 7, 10);
      final endDate = DateTime(2025, 7, 12);
      final longReason = 'This is a very detailed reason explaining why I need this leave. '
          'It includes multiple sentences and provides comprehensive context for the request. '
          'The reason is long enough to meet the minimum character requirement.';

      final requestData = LeaveRequestData(
        startDate: startDate,
        endDate: endDate,
        leaveType: 'Other',
        reason: longReason,
      );

      expect(requestData.reason, equals(longReason));
      expect(requestData.reason.length, greaterThan(100));
    });
  });

  group('LeaveRequestData Edge Cases', () {
    test('should handle multi-day leave spanning months', () {
      final startDate = DateTime(2025, 7, 30);
      final endDate = DateTime(2025, 8, 5);
      final requestData = LeaveRequestData(
        startDate: startDate,
        endDate: endDate,
        leaveType: 'Annual Leave',
        reason: 'Long vacation',
      );

      expect(requestData.numberOfDays, equals(7)); // 30, 31, 1, 2, 3, 4, 5 = 7 days
      expect(requestData.formattedStartDate, equals('30/07/2025'));
      expect(requestData.formattedEndDate, equals('05/08/2025'));
    });

    test('should handle leap year dates', () {
      final startDate = DateTime(2024, 2, 28);
      final endDate = DateTime(2024, 3, 1);
      final requestData = LeaveRequestData(
        startDate: startDate,
        endDate: endDate,
        leaveType: 'Casual Leave',
        reason: 'Leap year leave',
      );

      expect(requestData.numberOfDays, equals(3)); // 28, 29, 1 = 3 days
    });

    test('should handle special characters in reason', () {
      final startDate = DateTime(2025, 7, 10);
      final endDate = DateTime(2025, 7, 12);
      final specialReason = 'Reason with special chars: @#\$%^&*()_+-=[]{}|;:,.<>?';

      final requestData = LeaveRequestData(
        startDate: startDate,
        endDate: endDate,
        leaveType: 'Other',
        reason: specialReason,
      );

      expect(requestData.reason, equals(specialReason));
    });
  });
} 