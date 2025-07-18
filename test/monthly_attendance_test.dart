import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/attendance_models.dart';
import 'package:flutter/material.dart';

void main() {
  group('MonthlyAttendanceRequest Tests', () {
    test('should convert to JSON correctly', () {
      final request = MonthlyAttendanceRequest(year: 2025, month: 7);
      final json = request.toJson();
      
      expect(json['year'], equals(2025));
      expect(json['month'], equals(7));
    });
  });

  group('MonthlyAttendanceResponse Tests', () {
    test('should parse valid JSON response', () {
      final json = {
        "httpStatus": "OK",
        "message": "Attendance fetched successful",
        "code": 200,
        "data": [
          {
            "id": 51,
            "status": "Present",
            "attendanceDate": "2025-07-12T18:15:00.000+00:00",
            "checkInTime": "2025-07-13T08:30:00",
            "checkOutTime": "2025-07-13T23:20:00",
            "createdAt": "2025-07-12T14:34:45.000+00:00",
            "updatedAt": "2025-07-12T14:46:12.000+00:00"
          }
        ],
        "asyncRequest": false
      };

      final response = MonthlyAttendanceResponse.fromJson(json);

      expect(response.httpStatus, equals('OK'));
      expect(response.message, equals('Attendance fetched successful'));
      expect(response.code, equals(200));
      expect(response.asyncRequest, isFalse);
      expect(response.data, hasLength(1));
      expect(response.isSuccess, isTrue);
    });

    test('should handle empty data array', () {
      final json = {
        "httpStatus": "OK",
        "message": "No records found",
        "code": 200,
        "data": [],
        "asyncRequest": false
      };

      final response = MonthlyAttendanceResponse.fromJson(json);

      expect(response.data, isEmpty);
      expect(response.isSuccess, isTrue);
    });

    test('should handle missing optional fields', () {
      final json = {
        "code": 200,
        "data": []
      };

      final response = MonthlyAttendanceResponse.fromJson(json);

      expect(response.httpStatus, equals(''));
      expect(response.message, equals(''));
      expect(response.asyncRequest, isFalse);
      expect(response.data, isEmpty);
    });
  });

  group('MonthlyAttendanceRecord Tests', () {
    test('should parse valid record data', () {
      final json = {
        "id": 51,
        "status": "Present",
        "attendanceDate": "2025-07-12T18:15:00.000+00:00",
        "checkInTime": "2025-07-13T08:30:00",
        "checkOutTime": "2025-07-13T23:20:00",
        "createdAt": "2025-07-12T14:34:45.000+00:00",
        "updatedAt": "2025-07-12T14:46:12.000+00:00"
      };

      final record = MonthlyAttendanceRecord.fromJson(json);

      expect(record.id, equals(51));
      expect(record.status, equals('Present'));
      expect(record.attendanceDate, equals('2025-07-12T18:15:00.000+00:00'));
      expect(record.checkInTime, equals('2025-07-13T08:30:00'));
      expect(record.checkOutTime, equals('2025-07-13T23:20:00'));
      expect(record.createdAt, equals('2025-07-12T14:34:45.000+00:00'));
      expect(record.updatedAt, equals('2025-07-12T14:46:12.000+00:00'));
    });

    test('should handle null check-in and check-out times', () {
      final json = {
        "id": 52,
        "status": "Absent",
        "attendanceDate": "2025-07-13T18:15:00.000+00:00",
        "checkInTime": null,
        "checkOutTime": null,
        "createdAt": "2025-07-13T14:34:45.000+00:00",
        "updatedAt": "2025-07-13T14:46:12.000+00:00"
      };

      final record = MonthlyAttendanceRecord.fromJson(json);

      expect(record.checkInTime, isNull);
      expect(record.checkOutTime, isNull);
      expect(record.formattedCheckInTime, equals('Not checked in'));
      expect(record.formattedCheckOutTime, equals('Not checked out'));
    });

    test('should format date and time correctly', () {
      final json = {
        "id": 51,
        "status": "Present",
        "attendanceDate": "2025-07-12T18:15:00.000+00:00",
        "checkInTime": "2025-07-13T08:30:00",
        "checkOutTime": "2025-07-13T23:20:00",
        "createdAt": "2025-07-12T14:34:45.000+00:00",
        "updatedAt": "2025-07-12T14:46:12.000+00:00"
      };

      final record = MonthlyAttendanceRecord.fromJson(json);

      expect(record.formattedDate, equals('12/07/2025'));
      expect(record.formattedCheckInTime, equals('08:30'));
      expect(record.formattedCheckOutTime, equals('23:20'));
      expect(record.dayName, equals('Sat')); // July 12, 2025 is a Saturday
    });

    test('should return correct status colors', () {
      final presentRecord = MonthlyAttendanceRecord.fromJson({
        "id": 1,
        "status": "Present",
        "attendanceDate": "2025-07-12T18:15:00.000+00:00",
        "createdAt": "2025-07-12T14:34:45.000+00:00",
        "updatedAt": "2025-07-12T14:46:12.000+00:00"
      });

      final absentRecord = MonthlyAttendanceRecord.fromJson({
        "id": 2,
        "status": "Absent",
        "attendanceDate": "2025-07-13T18:15:00.000+00:00",
        "createdAt": "2025-07-13T14:34:45.000+00:00",
        "updatedAt": "2025-07-13T14:46:12.000+00:00"
      });

      final lateRecord = MonthlyAttendanceRecord.fromJson({
        "id": 3,
        "status": "Late",
        "attendanceDate": "2025-07-14T18:15:00.000+00:00",
        "createdAt": "2025-07-14T14:34:45.000+00:00",
        "updatedAt": "2025-07-14T14:46:12.000+00:00"
      });

      expect(presentRecord.statusColor, equals(Colors.green));
      expect(absentRecord.statusColor, equals(Colors.red));
      expect(lateRecord.statusColor, equals(Colors.orange));
    });

    test('should handle missing optional fields', () {
      final json = {
        "id": 53,
        "status": "Present",
        "attendanceDate": "2025-07-14T18:15:00.000+00:00"
      };

      final record = MonthlyAttendanceRecord.fromJson(json);

      expect(record.id, equals(53));
      expect(record.status, equals('Present'));
      expect(record.checkInTime, isNull);
      expect(record.checkOutTime, isNull);
      expect(record.createdAt, equals(''));
      expect(record.updatedAt, equals(''));
    });
  });

  group('Integration Tests', () {
    test('should parse complete API response with multiple records', () {
      final json = {
        "httpStatus": "OK",
        "message": "Attendance fetched successful",
        "code": 200,
        "data": [
          {
            "id": 51,
            "status": "Present",
            "attendanceDate": "2025-07-12T18:15:00.000+00:00",
            "checkInTime": "2025-07-13T08:30:00",
            "checkOutTime": "2025-07-13T23:20:00",
            "createdAt": "2025-07-12T14:34:45.000+00:00",
            "updatedAt": "2025-07-12T14:46:12.000+00:00"
          },
          {
            "id": 50,
            "status": "Present",
            "attendanceDate": "2025-07-11T18:15:00.000+00:00",
            "checkInTime": "2025-07-12T20:18:58",
            "checkOutTime": "2025-07-12T23:24:00",
            "createdAt": "2025-07-12T14:33:58.000+00:00",
            "updatedAt": "2025-07-12T14:39:37.000+00:00"
          }
        ],
        "asyncRequest": false
      };

      final response = MonthlyAttendanceResponse.fromJson(json);

      expect(response.data, hasLength(2));
      
      final firstRecord = response.data[0];
      expect(firstRecord.status, equals('Present'));
      expect(firstRecord.formattedDate, equals('12/07/2025'));
      expect(firstRecord.formattedCheckInTime, equals('08:30'));
      expect(firstRecord.formattedCheckOutTime, equals('23:20'));
      
      final secondRecord = response.data[1];
      expect(secondRecord.status, equals('Present'));
      expect(secondRecord.formattedDate, equals('11/07/2025'));
      expect(secondRecord.formattedCheckInTime, equals('20:18'));
      expect(secondRecord.formattedCheckOutTime, equals('23:24'));
    });
  });
} 