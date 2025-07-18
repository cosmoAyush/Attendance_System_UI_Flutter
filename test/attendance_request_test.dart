import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/attendance_models.dart';

void main() {
  group('AttendanceRequestResponse Tests', () {
    test('should parse successful response correctly', () {
      final json = {
        "httpStatus": "OK",
        "message": "Attendance request created successfully.",
        "code": 201,
        "asyncRequest": false
      };

      final response = AttendanceRequestResponse.fromJson(json);

      expect(response.httpStatus, equals('OK'));
      expect(response.message, equals('Attendance request created successfully.'));
      expect(response.code, equals(201));
      expect(response.asyncRequest, isFalse);
      expect(response.isSuccess, isTrue);
      expect(response.isOnLeave, isFalse);
    });

    test('should parse on leave error response correctly', () {
      final json = {
        "httpStatus": "OK",
        "message": "You are on Leave status. You cannot request attendance.",
        "code": 500,
        "asyncRequest": false
      };

      final response = AttendanceRequestResponse.fromJson(json);

      expect(response.httpStatus, equals('OK'));
      expect(response.message, equals('You are on Leave status. You cannot request attendance.'));
      expect(response.code, equals(500));
      expect(response.asyncRequest, isFalse);
      expect(response.isSuccess, isFalse);
      expect(response.isOnLeave, isTrue);
    });

    test('should parse other error response correctly', () {
      final json = {
        "httpStatus": "OK",
        "message": "Some other error occurred.",
        "code": 400,
        "asyncRequest": false
      };

      final response = AttendanceRequestResponse.fromJson(json);

      expect(response.httpStatus, equals('OK'));
      expect(response.message, equals('Some other error occurred.'));
      expect(response.code, equals(400));
      expect(response.asyncRequest, isFalse);
      expect(response.isSuccess, isFalse);
      expect(response.isOnLeave, isFalse);
    });
  });

  group('AttendanceRequestData Tests', () {
    test('should create request data correctly', () {
      final date = DateTime(2025, 7, 12, 13, 40, 43);
      final requestData = AttendanceRequestData(
        requestedType: 'Check In',
        requestedTime: '10:40',
        reason: 'Forgot to check in on time',
        attendanceDate: date,
      );

      expect(requestData.requestedType, equals('Check In'));
      expect(requestData.requestedTime, equals('10:40'));
      expect(requestData.reason, equals('Forgot to check in on time'));
      expect(requestData.attendanceDate, equals(date));
    });

    test('should convert to JSON correctly', () {
      final date = DateTime(2025, 7, 12, 13, 40, 43);
      final requestData = AttendanceRequestData(
        requestedType: 'Check Out',
        requestedTime: '18:30',
        reason: 'Left office early due to emergency',
        attendanceDate: date,
      );

      final json = requestData.toJson();

      expect(json['requestedType'], equals('Check Out'));
      expect(json['requestedTime'], equals('18:30'));
      expect(json['reason'], equals('Left office early due to emergency'));
      expect(json['attendanceDate'], equals('2025-07-12T13:40:43.000Z'));
    });

    test('should handle different request types', () {
      final date = DateTime.now();
      
      final checkInRequest = AttendanceRequestData(
        requestedType: 'Check In',
        requestedTime: '09:00',
        reason: 'Late arrival',
        attendanceDate: date,
      );

      final checkOutRequest = AttendanceRequestData(
        requestedType: 'Check Out',
        requestedTime: '17:00',
        reason: 'Early departure',
        attendanceDate: date,
      );

      final bothRequest = AttendanceRequestData(
        requestedType: 'Both',
        requestedTime: '09:00',
        reason: 'System error',
        attendanceDate: date,
      );

      expect(checkInRequest.requestedType, equals('Check In'));
      expect(checkOutRequest.requestedType, equals('Check Out'));
      expect(bothRequest.requestedType, equals('Both'));
    });

    test('should handle time formats correctly', () {
      final date = DateTime.now();
      
      final morningRequest = AttendanceRequestData(
        requestedType: 'Check In',
        requestedTime: '09:15',
        reason: 'Morning correction',
        attendanceDate: date,
      );

      final afternoonRequest = AttendanceRequestData(
        requestedType: 'Check Out',
        requestedTime: '17:45',
        reason: 'Afternoon correction',
        attendanceDate: date,
      );

      expect(morningRequest.requestedTime, equals('09:15'));
      expect(afternoonRequest.requestedTime, equals('17:45'));
    });

    test('should handle long reasons', () {
      final date = DateTime.now();
      final longReason = 'This is a very detailed reason explaining why I need this attendance correction. '
          'It includes multiple sentences and provides comprehensive context for the request. '
          'The reason is long enough to meet the minimum character requirement.';

      final requestData = AttendanceRequestData(
        requestedType: 'Check In',
        requestedTime: '10:00',
        reason: longReason,
        attendanceDate: date,
      );

      expect(requestData.reason, equals(longReason));
      expect(requestData.reason.length, greaterThan(100));
    });
  });

  group('AttendanceRequestData Edge Cases', () {
    test('should handle empty reason', () {
      final date = DateTime.now();
      final requestData = AttendanceRequestData(
        requestedType: 'Check In',
        requestedTime: '09:00',
        reason: '',
        attendanceDate: date,
      );

      expect(requestData.reason, equals(''));
    });

    test('should handle special characters in reason', () {
      final date = DateTime.now();
      final specialReason = 'Reason with special chars: @#\$%^&*()_+-=[]{}|;:,.<>?';

      final requestData = AttendanceRequestData(
        requestedType: 'Check Out',
        requestedTime: '18:00',
        reason: specialReason,
        attendanceDate: date,
      );

      expect(requestData.reason, equals(specialReason));
    });

    test('should handle different date formats', () {
      final pastDate = DateTime(2025, 1, 1, 12, 0, 0);
      final futureDate = DateTime(2025, 12, 31, 23, 59, 59);
      final currentDate = DateTime.now();

      final pastRequest = AttendanceRequestData(
        requestedType: 'Check In',
        requestedTime: '09:00',
        reason: 'Past correction',
        attendanceDate: pastDate,
      );

      final futureRequest = AttendanceRequestData(
        requestedType: 'Check Out',
        requestedTime: '18:00',
        reason: 'Future correction',
        attendanceDate: futureDate,
      );

      final currentRequest = AttendanceRequestData(
        requestedType: 'Both',
        requestedTime: '12:00',
        reason: 'Current correction',
        attendanceDate: currentDate,
      );

      expect(pastRequest.attendanceDate, equals(pastDate));
      expect(futureRequest.attendanceDate, equals(futureDate));
      expect(currentRequest.attendanceDate, equals(currentDate));
    });
  });
} 