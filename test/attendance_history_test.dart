import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/attendance_models.dart';

void main() {
  group('AttendanceHistoryResponse Tests', () {
    test('should parse successful response correctly', () {
      final json = {
        "httpStatus": "OK",
        "message": "Attendance records fetched successfully",
        "code": 200,
        "data": [
          {
            "id": 42,
            "status": "Present",
            "attendanceDate": "2025-07-11T18:15:00.000+00:00",
            "checkInTime": "2025-07-12T18:44:57",
            "checkOutTime": "2025-07-12T18:45:05",
            "createdAt": "2025-07-12T12:59:57.000+00:00",
            "updatedAt": "2025-07-12T13:00:05.000+00:00"
          },
          {
            "id": 43,
            "status": "Present",
            "attendanceDate": "2025-07-10T18:15:00.000+00:00",
            "checkInTime": "2025-07-11T20:51:00",
            "checkOutTime": "2025-07-11T18:53:00",
            "createdAt": "2025-07-12T13:06:27.000+00:00",
            "updatedAt": "2025-07-12T13:07:02.000+00:00"
          }
        ],
        "asyncRequest": false
      };

      final response = AttendanceHistoryResponse.fromJson(json);

      expect(response.httpStatus, equals('OK'));
      expect(response.message, equals('Attendance records fetched successfully'));
      expect(response.code, equals(200));
      expect(response.asyncRequest, isFalse);
      expect(response.isSuccess, isTrue);
      expect(response.data, hasLength(2));
    });

    test('should handle empty data array', () {
      final json = {
        "httpStatus": "OK",
        "message": "No attendance records found",
        "code": 200,
        "data": [],
        "asyncRequest": false
      };

      final response = AttendanceHistoryResponse.fromJson(json);

      expect(response.data, isEmpty);
      expect(response.isSuccess, isTrue);
    });

    test('should handle null data gracefully', () {
      final json = {
        "httpStatus": "OK",
        "message": "No attendance records found",
        "code": 200,
        "data": null,
        "asyncRequest": false
      };

      final response = AttendanceHistoryResponse.fromJson(json);

      expect(response.data, isEmpty);
    });
  });

  group('AttendanceHistoryData Tests', () {
    test('should parse attendance record correctly', () {
      final json = {
        "id": 42,
        "status": "Present",
        "attendanceDate": "2025-07-11T18:15:00.000+00:00",
        "checkInTime": "2025-07-12T18:44:57",
        "checkOutTime": "2025-07-12T18:45:05",
        "createdAt": "2025-07-12T12:59:57.000+00:00",
        "updatedAt": "2025-07-12T13:00:05.000+00:00"
      };

      final record = AttendanceHistoryData.fromJson(json);

      expect(record.id, equals(42));
      expect(record.status, equals('Present'));
      expect(record.attendanceDate, isNotNull);
      expect(record.checkInTime, isNotNull);
      expect(record.checkOutTime, isNotNull);
      expect(record.createdAt, isNotNull);
      expect(record.updatedAt, isNotNull);
    });

    test('should format date correctly', () {
      final json = {
        "id": 42,
        "status": "Present",
        "attendanceDate": "2025-07-11T18:15:00.000+00:00",
        "checkInTime": "2025-07-12T18:44:57",
        "checkOutTime": "2025-07-12T18:45:05",
        "createdAt": "2025-07-12T12:59:57.000+00:00",
        "updatedAt": "2025-07-12T13:00:05.000+00:00"
      };

      final record = AttendanceHistoryData.fromJson(json);

      expect(record.formattedDate, equals('11/7/2025'));
      expect(record.dayName, equals('Fri')); // July 11, 2025 is a Friday
    });

    test('should format times correctly', () {
      final json = {
        "id": 42,
        "status": "Present",
        "attendanceDate": "2025-07-11T18:15:00.000+00:00",
        "checkInTime": "2025-07-12T18:44:57",
        "checkOutTime": "2025-07-12T18:45:05",
        "createdAt": "2025-07-12T12:59:57.000+00:00",
        "updatedAt": "2025-07-12T13:00:05.000+00:00"
      };

      final record = AttendanceHistoryData.fromJson(json);

      expect(record.formattedCheckInTime, equals('18:44'));
      expect(record.formattedCheckOutTime, equals('18:45'));
    });

    test('should handle null times gracefully', () {
      final json = {
        "id": 42,
        "status": "Absent",
        "attendanceDate": "2025-07-11T18:15:00.000+00:00",
        "checkInTime": null,
        "checkOutTime": null,
        "createdAt": "2025-07-12T12:59:57.000+00:00",
        "updatedAt": "2025-07-12T13:00:05.000+00:00"
      };

      final record = AttendanceHistoryData.fromJson(json);

      expect(record.formattedCheckInTime, equals('Not checked in'));
      expect(record.formattedCheckOutTime, equals('Not checked out'));
      expect(record.isCheckedIn, isFalse);
      expect(record.isCheckedOut, isFalse);
    });

    test('should identify status correctly', () {
      final presentRecord = AttendanceHistoryData.fromJson({
        "id": 42,
        "status": "Present",
        "attendanceDate": "2025-07-11T18:15:00.000+00:00",
        "checkInTime": "2025-07-12T18:44:57",
        "checkOutTime": "2025-07-12T18:45:05",
        "createdAt": "2025-07-12T12:59:57.000+00:00",
        "updatedAt": "2025-07-12T13:00:05.000+00:00"
      });

      final absentRecord = AttendanceHistoryData.fromJson({
        "id": 43,
        "status": "Absent",
        "attendanceDate": "2025-07-10T18:15:00.000+00:00",
        "checkInTime": null,
        "checkOutTime": null,
        "createdAt": "2025-07-12T13:06:27.000+00:00",
        "updatedAt": "2025-07-12T13:07:02.000+00:00"
      });

      final leaveRecord = AttendanceHistoryData.fromJson({
        "id": 44,
        "status": "Leave",
        "attendanceDate": "2025-07-09T18:15:00.000+00:00",
        "checkInTime": null,
        "checkOutTime": null,
        "createdAt": "2025-07-12T13:06:27.000+00:00",
        "updatedAt": "2025-07-12T13:07:02.000+00:00"
      });

      expect(presentRecord.isPresent, isTrue);
      expect(presentRecord.isAbsent, isFalse);
      expect(presentRecord.isLeave, isFalse);

      expect(absentRecord.isPresent, isFalse);
      expect(absentRecord.isAbsent, isTrue);
      expect(absentRecord.isLeave, isFalse);

      expect(leaveRecord.isPresent, isFalse);
      expect(leaveRecord.isAbsent, isFalse);
      expect(leaveRecord.isLeave, isTrue);
    });

    test('should handle case-insensitive status', () {
      final presentRecord = AttendanceHistoryData.fromJson({
        "id": 42,
        "status": "present",
        "attendanceDate": "2025-07-11T18:15:00.000+00:00",
        "checkInTime": "2025-07-12T18:44:57",
        "checkOutTime": "2025-07-12T18:45:05",
        "createdAt": "2025-07-12T12:59:57.000+00:00",
        "updatedAt": "2025-07-12T13:00:05.000+00:00"
      });

      expect(presentRecord.isPresent, isTrue);
    });
  });

  group('AttendanceHistoryData Edge Cases', () {
    test('should handle missing optional fields', () {
      final json = {
        "id": 42,
        "status": "Present",
      };

      final record = AttendanceHistoryData.fromJson(json);

      expect(record.id, equals(42));
      expect(record.status, equals('Present'));
      expect(record.attendanceDate, isNull);
      expect(record.checkInTime, isNull);
      expect(record.checkOutTime, isNull);
      expect(record.createdAt, isNull);
      expect(record.updatedAt, isNull);
    });

    test('should handle invalid date strings', () {
      final json = {
        "id": 42,
        "status": "Present",
        "attendanceDate": "invalid-date",
        "checkInTime": "invalid-time",
        "checkOutTime": "invalid-time",
        "createdAt": "invalid-date",
        "updatedAt": "invalid-date"
      };

      final record = AttendanceHistoryData.fromJson(json);

      expect(record.attendanceDate, isNull);
      expect(record.checkInTime, isNull);
      expect(record.checkOutTime, isNull);
      expect(record.createdAt, isNull);
      expect(record.updatedAt, isNull);
    });

    test('should format date with null attendanceDate', () {
      final record = AttendanceHistoryData(
        id: 42,
        status: 'Present',
        attendanceDate: null,
      );

      expect(record.formattedDate, equals('N/A'));
      expect(record.dayName, equals('N/A'));
    });
  });
} 