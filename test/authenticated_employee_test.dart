import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/employee_models.dart';
import 'package:flutter/material.dart';

void main() {
  group('EmployeeResponse Tests', () {
    test('should parse valid JSON response', () {
      final json = {
        "httpStatus": "OK",
        "message": "Employee details fetched successfully.",
        "code": 200,
        "data": {
          "id": 2,
          "fullName": "Spriya Adhikari Demo",
          "email": "spriya@gmail.com",
          "phoneNumber": "1234567890",
          "address": "Jhapali",
          "dob": "2025-07-27T18:15:00.000+00:00",
          "dateOfJoining": "2025-07-11T18:15:00.000+00:00",
          "gender": "FEMALE",
          "status": "ACTIVE",
          "bloodGroup": "O+",
          "department": "IT",
          "position": "Intern",
          "imageUrl": "employee/b35d74db-693f-462e-8b5d-53667c08955a.jpg",
          "nationalId": null,
          "nationalIdImageUrl": null,
          "citizenshipNumber": null,
          "citizenshipImageUrl": null,
          "panNumber": null,
          "panImageUrl": null
        },
        "asyncRequest": false
      };

      final response = EmployeeResponse.fromJson(json);

      expect(response.httpStatus, equals('OK'));
      expect(response.message, equals('Employee details fetched successfully.'));
      expect(response.code, equals(200));
      expect(response.asyncRequest, isFalse);
      expect(response.data, isNotNull);
      expect(response.isSuccess, isTrue);
    });

    test('should handle missing optional fields', () {
      final json = {
        "code": 200,
        "data": {}
      };

      final response = EmployeeResponse.fromJson(json);

      expect(response.httpStatus, equals(''));
      expect(response.message, equals(''));
      expect(response.asyncRequest, isFalse);
    });
  });

  group('EmployeeData Tests', () {
    test('should parse valid employee data', () {
      final json = {
        "id": 2,
        "fullName": "Spriya Adhikari Demo",
        "email": "spriya@gmail.com",
        "phoneNumber": "1234567890",
        "address": "Jhapali",
        "dob": "2025-07-27T18:15:00.000+00:00",
        "dateOfJoining": "2025-07-11T18:15:00.000+00:00",
        "gender": "FEMALE",
        "status": "ACTIVE",
        "bloodGroup": "O+",
        "department": "IT",
        "position": "Intern",
        "imageUrl": "employee/b35d74db-693f-462e-8b5d-53667c08955a.jpg",
        "nationalId": null,
        "nationalIdImageUrl": null,
        "citizenshipNumber": null,
        "citizenshipImageUrl": null,
        "panNumber": null,
        "panImageUrl": null
      };

      final employee = EmployeeData.fromJson(json);

      expect(employee.id, equals(2));
      expect(employee.fullName, equals('Spriya Adhikari Demo'));
      expect(employee.email, equals('spriya@gmail.com'));
      expect(employee.phoneNumber, equals('1234567890'));
      expect(employee.address, equals('Jhapali'));
      expect(employee.dob, isA<DateTime?>());
      expect(employee.dateOfJoining, isA<DateTime?>());
      expect(employee.gender, equals('FEMALE'));
      expect(employee.status, equals('ACTIVE'));
      expect(employee.bloodGroup, equals('O+'));
      expect(employee.department, equals('IT'));
      expect(employee.position, equals('Intern'));
      expect(employee.imageUrl, equals('employee/b35d74db-693f-462e-8b5d-53667c08955a.jpg'));
      expect(employee.nationalId, isNull);
      expect(employee.citizenshipNumber, isNull);
      expect(employee.panNumber, isNull);
    });

    test('should format dates correctly', () {
      final json = {
        "id": 1,
        "fullName": "Test Employee",
        "email": "test@example.com",
        "phoneNumber": "1234567890",
        "address": "Test Address",
        "dob": "1990-05-15T00:00:00.000+00:00",
        "dateOfJoining": "2020-01-01T00:00:00.000+00:00",
        "gender": "MALE",
        "status": "ACTIVE",
        "bloodGroup": "A+",
        "department": "HR",
        "position": "Manager"
      };

      final employee = EmployeeData.fromJson(json);

      expect(employee.formattedDateOfBirth, equals('15/05/1990'));
      expect(employee.formattedDateOfJoining, equals('01/01/2020'));
    });

    test('should format gender correctly', () {
      final maleEmployee = EmployeeData.fromJson({
        "id": 1,
        "fullName": "Male Employee",
        "email": "male@example.com",
        "phoneNumber": "1234567890",
        "address": "Address",
        "dob": "1990-01-01T00:00:00.000+00:00",
        "dateOfJoining": "2020-01-01T00:00:00.000+00:00",
        "gender": "MALE",
        "status": "ACTIVE",
        "bloodGroup": "A+",
        "department": "IT",
        "position": "Developer"
      });

      final femaleEmployee = EmployeeData.fromJson({
        "id": 2,
        "fullName": "Female Employee",
        "email": "female@example.com",
        "phoneNumber": "1234567890",
        "address": "Address",
        "dob": "1990-01-01T00:00:00.000+00:00",
        "dateOfJoining": "2020-01-01T00:00:00.000+00:00",
        "gender": "FEMALE",
        "status": "ACTIVE",
        "bloodGroup": "A+",
        "department": "IT",
        "position": "Developer"
      });

      expect(maleEmployee.formattedGender, equals('Male'));
      expect(femaleEmployee.formattedGender, equals('Female'));
    });

    test('should format status correctly', () {
      final activeEmployee = EmployeeData.fromJson({
        "id": 1,
        "fullName": "Active Employee",
        "email": "active@example.com",
        "phoneNumber": "1234567890",
        "address": "Address",
        "dob": "1990-01-01T00:00:00.000+00:00",
        "dateOfJoining": "2020-01-01T00:00:00.000+00:00",
        "gender": "MALE",
        "status": "ACTIVE",
        "bloodGroup": "A+",
        "department": "IT",
        "position": "Developer"
      });

      final inactiveEmployee = EmployeeData.fromJson({
        "id": 2,
        "fullName": "Inactive Employee",
        "email": "inactive@example.com",
        "phoneNumber": "1234567890",
        "address": "Address",
        "dob": "1990-01-01T00:00:00.000+00:00",
        "dateOfJoining": "2020-01-01T00:00:00.000+00:00",
        "gender": "MALE",
        "status": "INACTIVE",
        "bloodGroup": "A+",
        "department": "IT",
        "position": "Developer"
      });

      expect(activeEmployee.formattedStatus, equals('Active'));
      expect(inactiveEmployee.formattedStatus, equals('Inactive'));
    });

    test('should return correct status colors', () {
      final activeEmployee = EmployeeData.fromJson({
        "id": 1,
        "fullName": "Active Employee",
        "email": "active@example.com",
        "phoneNumber": "1234567890",
        "address": "Address",
        "dob": "1990-01-01T00:00:00.000+00:00",
        "dateOfJoining": "2020-01-01T00:00:00.000+00:00",
        "gender": "MALE",
        "status": "ACTIVE",
        "bloodGroup": "A+",
        "department": "IT",
        "position": "Developer"
      });

      final inactiveEmployee = EmployeeData.fromJson({
        "id": 2,
        "fullName": "Inactive Employee",
        "email": "inactive@example.com",
        "phoneNumber": "1234567890",
        "address": "Address",
        "dob": "1990-01-01T00:00:00.000+00:00",
        "dateOfJoining": "2020-01-01T00:00:00.000+00:00",
        "gender": "MALE",
        "status": "INACTIVE",
        "bloodGroup": "A+",
        "department": "IT",
        "position": "Developer"
      });

      final suspendedEmployee = EmployeeData.fromJson({
        "id": 3,
        "fullName": "Suspended Employee",
        "email": "suspended@example.com",
        "phoneNumber": "1234567890",
        "address": "Address",
        "dob": "1990-01-01T00:00:00.000+00:00",
        "dateOfJoining": "2020-01-01T00:00:00.000+00:00",
        "gender": "MALE",
        "status": "SUSPENDED",
        "bloodGroup": "A+",
        "department": "IT",
        "position": "Developer"
      });

      expect(activeEmployee.statusColor, equals(Colors.green));
      expect(inactiveEmployee.statusColor, equals(Colors.red));
      expect(suspendedEmployee.statusColor, equals(Colors.orange));
    });

    test('should handle missing optional fields', () {
      final json = {
        "id": 1,
        "fullName": "Test Employee",
        "email": "test@example.com",
        "phoneNumber": "1234567890",
        "address": "Test Address",
        "dob": "1990-01-01T00:00:00.000+00:00",
        "dateOfJoining": "2020-01-01T00:00:00.000+00:00",
        "gender": "MALE",
        "status": "ACTIVE",
        "bloodGroup": "A+",
        "department": "IT",
        "position": "Developer"
      };

      final employee = EmployeeData.fromJson(json);

      expect(employee.id, equals(1));
      expect(employee.fullName, equals('Test Employee'));
      expect(employee.imageUrl, isNull);
      expect(employee.nationalId, isNull);
      expect(employee.citizenshipNumber, isNull);
      expect(employee.panNumber, isNull);
    });

    test('should handle invalid date strings', () {
      final json = {
        "id": 1,
        "fullName": "Test Employee",
        "email": "test@example.com",
        "phoneNumber": "1234567890",
        "address": "Test Address",
        "dob": "invalid-date",
        "dateOfJoining": "invalid-date",
        "gender": "MALE",
        "status": "ACTIVE",
        "bloodGroup": "A+",
        "department": "IT",
        "position": "Developer"
      };

      final employee = EmployeeData.fromJson(json);

      // Should not throw exception, should return null
      expect(employee.dob, isNull);
      expect(employee.dateOfJoining, isNull);
    });
  });

  group('Integration Tests', () {
    test('should parse complete API response', () {
      final json = {
        "httpStatus": "OK",
        "message": "Employee details fetched successfully.",
        "code": 200,
        "data": {
          "id": 2,
          "fullName": "Spriya Adhikari Demo",
          "email": "spriya@gmail.com",
          "phoneNumber": "1234567890",
          "address": "Jhapali",
          "dob": "2025-07-27T18:15:00.000+00:00",
          "dateOfJoining": "2025-07-11T18:15:00.000+00:00",
          "gender": "FEMALE",
          "status": "ACTIVE",
          "bloodGroup": "O+",
          "department": "IT",
          "position": "Intern",
          "imageUrl": "employee/b35d74db-693f-462e-8b5d-53667c08955a.jpg",
          "nationalId": "123456789",
          "nationalIdImageUrl": "documents/national-id.jpg",
          "citizenshipNumber": "987654321",
          "citizenshipImageUrl": "documents/citizenship.jpg",
          "panNumber": "ABCDE1234F",
          "panImageUrl": "documents/pan.jpg"
        },
        "asyncRequest": false
      };

      final response = EmployeeResponse.fromJson(json);

      expect(response.isSuccess, isTrue);
      expect(response.data, isNotNull);
      
      final employee = response.data!;
      expect(employee.fullName, equals('Spriya Adhikari Demo'));
      expect(employee.email, equals('spriya@gmail.com'));
      expect(employee.formattedGender, equals('Female'));
      expect(employee.formattedStatus, equals('Active'));
      expect(employee.statusColor, equals(Colors.green));
      expect(employee.nationalId, equals('123456789'));
      expect(employee.citizenshipNumber, equals('987654321'));
      expect(employee.panNumber, equals('ABCDE1234F'));
    });
  });
} 