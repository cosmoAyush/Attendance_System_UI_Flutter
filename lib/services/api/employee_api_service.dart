import 'package:dio/dio.dart';
import 'package:attendance_system_hris/core/config/app_config.dart';
import 'package:attendance_system_hris/core/network/dio_client.dart';
import 'package:attendance_system_hris/models/api/employee_models.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';

class EmployeeApiService {
  static final Dio _dio = DioClient.instance;

  /// Fetch employee details
  static Future<EmployeeResponse> getEmployeeDetails() async {
    try {
      print('👤 EmployeeApiService: Fetching employee details');
      print('👤 EmployeeApiService: API URL: ${AppConfig.apiBaseUrl}/employee/get');
      final response = await _dio.post('/employee/get');
      print('👤 EmployeeApiService: Raw response: ${response.data}');
      print('👤 EmployeeApiService: Response status code: ${response.statusCode}');
      final employeeResponse = EmployeeResponse.fromJson(response.data);
      print('👤 EmployeeApiService: Employee data loaded successfully');
      return employeeResponse;
    } on DioException catch (e) {
      print('❌ EmployeeApiService: DioException caught: ${e.type}');
      print('❌ EmployeeApiService: DioException message: ${e.message}');
      print('❌ EmployeeApiService: DioException error: ${e.error}');
      print('❌ EmployeeApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ EmployeeApiService: DioException response data: ${e.response?.data}');
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to fetch employee details',
        );
      }
    } catch (e) {
      print('❌ EmployeeApiService: General exception caught: ${e.toString()}');
      print('❌ EmployeeApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Fetch authenticated employee profile details
  static Future<EmployeeResponse> getAuthenticatedEmployee() async {
    try {
      print('👤 EmployeeApiService: Fetching authenticated employee profile');
      print('👤 EmployeeApiService: API URL: ${AppConfig.apiBaseUrl}/employee/getAuthenticatedEmployee');
      final response = await _dio.get('/employee/getAuthenticatedEmployee');
      print('👤 EmployeeApiService: Raw response: ${response.data}');
      print('👤 EmployeeApiService: Response status code: ${response.statusCode}');
      final employeeResponse = EmployeeResponse.fromJson(response.data);
      print('👤 EmployeeApiService: Authenticated employee profile loaded successfully');
      return employeeResponse;
    } on DioException catch (e) {
      print('❌ EmployeeApiService: DioException caught: ${e.type}');
      print('❌ EmployeeApiService: DioException message: ${e.message}');
      print('❌ EmployeeApiService: DioException error: ${e.error}');
      print('❌ EmployeeApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ EmployeeApiService: DioException response data: ${e.response?.data}');
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to fetch authenticated employee profile',
        );
      }
    } catch (e) {
      print('❌ EmployeeApiService: General exception caught: ${e.toString()}');
      print('❌ EmployeeApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Change employee password
  static Future<ChangePasswordResponse> changePassword(ChangePasswordRequest request) async {
    try {
      print('🔐 EmployeeApiService: Changing password');
      print('🔐 EmployeeApiService: API URL: ${AppConfig.apiBaseUrl}/employee/change-password');
      print('🔐 EmployeeApiService: Request data: ${request.toJson()}');
      
      final response = await _dio.post('/employee/change-password', data: request.toJson());
      print('🔐 EmployeeApiService: Raw response: ${response.data}');
      print('🔐 EmployeeApiService: Response status code: ${response.statusCode}');
      
      final changePasswordResponse = ChangePasswordResponse.fromJson(response.data);
      print('🔐 EmployeeApiService: Password change response processed');
      return changePasswordResponse;
    } on DioException catch (e) {
      print('❌ EmployeeApiService: DioException caught: ${e.type}');
      print('❌ EmployeeApiService: DioException message: ${e.message}');
      print('❌ EmployeeApiService: DioException error: ${e.error}');
      print('❌ EmployeeApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ EmployeeApiService: DioException response data: ${e.response?.data}');
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        // Handle the specific error response format
        final errorData = e.response!.data;
        if (errorData['code'] == 500) {
          // This is the expected error response for incorrect current password
          return ChangePasswordResponse.fromJson(errorData);
        } else {
          throw ApiError.fromJson(errorData);
        }
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to change password',
        );
      }
    } catch (e) {
      print('❌ EmployeeApiService: General exception caught: ${e.toString()}');
      print('❌ EmployeeApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
} 