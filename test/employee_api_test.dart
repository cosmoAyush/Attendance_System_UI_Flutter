import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/employee_models.dart';

void main() {
  group('Employee API Tests', () {
    test('EmployeeResponse fromJson should work correctly', () {
      final json = {
        'httpStatus': 'OK',
        'message': 'Employee details fetched successfully.',
        'code': 200,
        'data': {
          'id': 2,
          'fullName': 'Spriya Adhikari',
          'email': 'spriya@gmail.com',
          'phoneNumber': '1234567890',
          'address': 'Jhapali',
          'dob': '2025-07-31T18:15:00.000+00:00',
          'dateOfJoining': '2025-07-09T18:15:00.000+00:00',
          'gender': 'FEMALE',
          'status': 'ACTIVE',
          'bloodGroup': 'O+',
          'department': 'IT',
          'position': 'Intern',
          'imageUrl': 'uploads/employee/17d2eaed-6f53-47ab-8a3c-347eb8293fc8.png',
          'nationalId': null,
          'nationalIdImageUrl': null,
          'citizenshipNumber': null,
          'citizenshipImageUrl': null,
          'panNumber': null,
          'panImageUrl': null
        },
        'asyncRequest': false
      };

      final response = EmployeeResponse.fromJson(json);
      
      expect(response.code, 200);
      expect(response.message, 'Employee details fetched successfully.');
      expect(response.httpStatus, 'OK');
      expect(response.asyncRequest, false);
      expect(response.isSuccess, true);
      
      // Test employee data
      final employee = response.data;
      expect(employee.id, 2);
      expect(employee.fullName, 'Spriya Adhikari');
      expect(employee.email, 'spriya@gmail.com');
      expect(employee.phoneNumber, '1234567890');
      expect(employee.address, 'Jhapali');
      expect(employee.gender, 'FEMALE');
      expect(employee.status, 'ACTIVE');
      expect(employee.bloodGroup, 'O+');
      expect(employee.department, 'IT');
      expect(employee.position, 'Intern');
      expect(employee.imageUrl, 'uploads/employee/17d2eaed-6f53-47ab-8a3c-347eb8293fc8.png');
      expect(employee.displayName, 'Spriya Adhikari');
      expect(employee.shortName, 'Spriya Adhikari');
    });

    test('EmployeeData displayName should work correctly', () {
      final employee = EmployeeData(
        id: 1,
        fullName: 'John Doe Smith',
        email: 'john.doe@example.com',
        phoneNumber: '1234567890',
        address: 'Test Address',
        gender: 'MALE',
        status: 'ACTIVE',
        bloodGroup: 'A+',
        department: 'Engineering',
        position: 'Developer',
      );

      expect(employee.displayName, 'John Doe Smith');
      expect(employee.shortName, 'John Smith');
    });

    test('EmployeeData with empty fullName should use email', () {
      final employee = EmployeeData(
        id: 1,
        fullName: '',
        email: 'john.doe@example.com',
        phoneNumber: '1234567890',
        address: 'Test Address',
        gender: 'MALE',
        status: 'ACTIVE',
        bloodGroup: 'A+',
        department: 'Engineering',
        position: 'Developer',
      );

      expect(employee.displayName, 'john.doe@example.com');
      expect(employee.shortName, 'john.doe');
    });

    test('EmployeeData date parsing should work correctly', () {
      final json = {
        'id': 1,
        'fullName': 'Test User',
        'email': 'test@example.com',
        'phoneNumber': '1234567890',
        'address': 'Test Address',
        'dob': '1990-01-01T00:00:00.000+00:00',
        'dateOfJoining': '2020-01-01T00:00:00.000+00:00',
        'gender': 'MALE',
        'status': 'ACTIVE',
        'bloodGroup': 'A+',
        'department': 'IT',
        'position': 'Developer',
      };

      final employee = EmployeeData.fromJson(json);
      
      expect(employee.dob, isNotNull);
      expect(employee.dob!.year, 1990);
      expect(employee.dob!.month, 1);
      expect(employee.dob!.day, 1);
      
      expect(employee.dateOfJoining, isNotNull);
      expect(employee.dateOfJoining!.year, 2020);
      expect(employee.dateOfJoining!.month, 1);
      expect(employee.dateOfJoining!.day, 1);
    });
  });
} 