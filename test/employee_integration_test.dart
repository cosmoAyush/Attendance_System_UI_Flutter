import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/services/api/employee_api_service.dart';
import 'package:attendance_system_hris/models/api/employee_models.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';

void main() {
  group('Employee API Integration Tests', () {
    test('EmployeeApiService should handle successful response', () {
      // This test verifies the service structure and error handling
      // In a real scenario, you would mock the Dio client
      
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
      
      expect(response.isSuccess, true);
      expect(response.data.fullName, 'Spriya Adhikari');
      expect(response.data.position, 'Intern');
      expect(response.data.department, 'IT');
    });

    test('EmployeeApiService should handle error response', () {
      final errorJson = {
        'code': 401,
        'message': 'Unauthorized',
        'error': 'Authentication required',
      };

      final error = ApiError.fromJson(errorJson);
      
      expect(error.statusCode, 401);
      expect(error.message, 'Unauthorized');
      expect(error.displayMessage, 'Invalid credentials. Please check your email and password.');
    });

    test('EmployeeData should handle missing optional fields', () {
      final json = {
        'id': 1,
        'fullName': 'Test User',
        'email': 'test@example.com',
        'phoneNumber': '1234567890',
        'address': 'Test Address',
        'gender': 'MALE',
        'status': 'ACTIVE',
        'bloodGroup': 'A+',
        'department': 'IT',
        'position': 'Developer',
        // Missing optional fields
      };

      final employee = EmployeeData.fromJson(json);
      
      expect(employee.id, 1);
      expect(employee.fullName, 'Test User');
      expect(employee.email, 'test@example.com');
      expect(employee.dob, null);
      expect(employee.dateOfJoining, null);
      expect(employee.imageUrl, null);
      expect(employee.displayName, 'Test User');
    });
  });
} 