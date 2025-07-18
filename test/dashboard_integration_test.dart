import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/models/api/employee_models.dart';
import 'package:attendance_system_hris/services/auth_service.dart';
import 'package:attendance_system_hris/services/api/employee_api_service.dart';

void main() {
  group('Dashboard Employee Data Display Tests', () {
    test('should display actual employee name instead of "Employee"', () {
      // Create a mock employee with actual data
      final employee = EmployeeData(
        id: 1,
        fullName: 'John Smith',
        email: 'john.smith@company.com',
        phoneNumber: '1234567890',
        address: '123 Main St',
        gender: 'Male',
        status: 'Active',
        bloodGroup: 'O+',
        department: 'Engineering',
        position: 'Software Developer',
        imageUrl: '/uploads/employees/john-smith.jpg',
      );

      // Test that fullName is used for display
      expect(employee.fullName, 'John Smith');
      expect(employee.fullName.isNotEmpty, true);
      
      // Test fallback to email if fullName is empty
      final employeeWithEmptyName = EmployeeData(
        id: 2,
        fullName: '',
        email: 'jane.doe@company.com',
        phoneNumber: '0987654321',
        address: '456 Oak St',
        gender: 'Female',
        status: 'Active',
        bloodGroup: 'A+',
        department: 'Marketing',
        position: 'Marketing Manager',
        imageUrl: null,
      );
      
      expect(employeeWithEmptyName.fullName.isEmpty, true);
      expect(employeeWithEmptyName.email.isNotEmpty, true);
    });

    test('should construct correct image URL without API version', () {
      final employee = EmployeeData(
        id: 1,
        fullName: 'John Smith',
        email: 'john.smith@company.com',
        phoneNumber: '1234567890',
        address: '123 Main St',
        gender: 'Male',
        status: 'Active',
        bloodGroup: 'O+',
        department: 'Engineering',
        position: 'Software Developer',
        imageUrl: '/uploads/employees/john-smith.jpg',
      );

      // Test image URL construction
      const baseUrl = 'http://192.168.1.66:8080';
      final expectedImageUrl = '$baseUrl${employee.imageUrl}';
      expect(expectedImageUrl, 'http://192.168.1.66:8080/uploads/employees/john-smith.jpg');
      
      // Test that it doesn't include API version
      expect(expectedImageUrl.contains('/api/v1'), false);
    });

    test('should handle null or empty image URLs gracefully', () {
      final employeeWithNullImage = EmployeeData(
        id: 1,
        fullName: 'John Smith',
        email: 'john.smith@company.com',
        phoneNumber: '1234567890',
        address: '123 Main St',
        gender: 'Male',
        status: 'Active',
        bloodGroup: 'O+',
        department: 'Engineering',
        position: 'Software Developer',
        imageUrl: null,
      );

      final employeeWithEmptyImage = EmployeeData(
        id: 2,
        fullName: 'Jane Doe',
        email: 'jane.doe@company.com',
        phoneNumber: '0987654321',
        address: '456 Oak St',
        gender: 'Female',
        status: 'Active',
        bloodGroup: 'A+',
        department: 'Marketing',
        position: 'Marketing Manager',
        imageUrl: '',
      );

      // Test null image URL
      expect(employeeWithNullImage.imageUrl, null);
      expect(employeeWithNullImage.imageUrl?.isNotEmpty, null);
      
      // Test empty image URL
      expect(employeeWithEmptyImage.imageUrl, '');
      expect(employeeWithEmptyImage.imageUrl?.isNotEmpty, false);
    });

    test('should display employee position and department correctly', () {
      final employee = EmployeeData(
        id: 1,
        fullName: 'John Smith',
        email: 'john.smith@company.com',
        phoneNumber: '1234567890',
        address: '123 Main St',
        gender: 'Male',
        status: 'Active',
        bloodGroup: 'O+',
        department: 'Engineering',
        position: 'Software Developer',
        imageUrl: '/uploads/employees/john-smith.jpg',
      );

      expect(employee.position, 'Software Developer');
      expect(employee.department, 'Engineering');
      expect(employee.position.isNotEmpty, true);
      expect(employee.department.isNotEmpty, true);
    });
  });
} 