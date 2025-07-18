import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/attendance_models.dart';

void main() {
  group('Attendance Status API Tests', () {
    test('should parse successful attendance status response', () {
      final json = {
        "httpStatus": "OK",
        "message": "Today's attendance status fetched successfully",
        "code": 200,
        "data": {
          "id": 35,
          "status": "Present",
          "attendanceDate": "2025-07-11T18:15:00.000+00:00",
          "checkInTime": "2025-07-12T18:19:05",
          "checkOutTime": null,
          "createdAt": "2025-07-12T12:34:05.000+00:00",
          "updatedAt": null
        },
        "asyncRequest": false
      };

      final response = AttendanceStatusResponse.fromJson(json);
      
      expect(response.httpStatus, 'OK');
      expect(response.message, 'Today\'s attendance status fetched successfully');
      expect(response.code, 200);
      expect(response.asyncRequest, false);
      expect(response.isSuccess, true);
      expect(response.isNotMarkedToday, false);
      expect(response.data, isNotNull);
      
      final data = response.data!;
      expect(data.id, 35);
      expect(data.status, 'Present');
      expect(data.isCheckedIn, true);
      expect(data.isCheckedOut, false);
      expect(data.isPresent, true);
      expect(data.formattedCheckInTime, '18:19');
      expect(data.formattedCheckOutTime, 'Not checked out');
    });

    test('should parse not marked today response', () {
      final json = {
        "httpStatus": "OK",
        "message": "Not marked checkin today yet",
        "code": 500,
        "asyncRequest": false
      };

      final response = AttendanceStatusResponse.fromJson(json);
      
      expect(response.httpStatus, 'OK');
      expect(response.message, 'Not marked checkin today yet');
      expect(response.code, 500);
      expect(response.asyncRequest, false);
      expect(response.isSuccess, false);
      expect(response.isNotMarkedToday, true);
      expect(response.data, isNull);
    });

    test('should handle checked out status', () {
      final json = {
        "httpStatus": "OK",
        "message": "Today's attendance status fetched successfully",
        "code": 200,
        "data": {
          "id": 35,
          "status": "Present",
          "attendanceDate": "2025-07-11T18:15:00.000+00:00",
          "checkInTime": "2025-07-12T09:00:00",
          "checkOutTime": "2025-07-12T17:00:00",
          "createdAt": "2025-07-12T12:34:05.000+00:00",
          "updatedAt": null
        },
        "asyncRequest": false
      };

      final response = AttendanceStatusResponse.fromJson(json);
      final data = response.data!;
      
      expect(data.isCheckedIn, true);
      expect(data.isCheckedOut, true);
      expect(data.isPresent, true);
      expect(data.formattedCheckInTime, '09:00');
      expect(data.formattedCheckOutTime, '17:00');
    });

    test('should handle null check in time', () {
      final json = {
        "httpStatus": "OK",
        "message": "Today's attendance status fetched successfully",
        "code": 200,
        "data": {
          "id": 35,
          "status": "Absent",
          "attendanceDate": "2025-07-11T18:15:00.000+00:00",
          "checkInTime": null,
          "checkOutTime": null,
          "createdAt": "2025-07-12T12:34:05.000+00:00",
          "updatedAt": null
        },
        "asyncRequest": false
      };

      final response = AttendanceStatusResponse.fromJson(json);
      final data = response.data!;
      
      expect(data.isCheckedIn, false);
      expect(data.isCheckedOut, false);
      expect(data.isPresent, false);
      expect(data.formattedCheckInTime, 'Not checked in');
      expect(data.formattedCheckOutTime, 'Not checked out');
    });
  });
} 