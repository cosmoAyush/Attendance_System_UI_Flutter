import 'package:dio/dio.dart';
import 'package:attendance_system_hris/core/config/app_config.dart';
import 'package:attendance_system_hris/core/network/dio_client.dart';
import 'package:attendance_system_hris/models/api/leave_models.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';

class LeaveApiService {
  static final Dio _dio = DioClient.instance;

  /// Create leave request
  /// Returns LeaveRequestResponse on success, throws ApiError on failure
  static Future<LeaveRequestResponse> createLeaveRequest(LeaveRequestData requestData) async {
    try {
      print('📅 LeaveApiService: Creating leave request');
      print('📅 LeaveApiService: API URL: ${AppConfig.apiBaseUrl}/leave-request/create');
      print('📅 LeaveApiService: Request data: ${requestData.toJson()}');

      final response = await _dio.post('/leave-request/create', data: requestData.toJson());

      print('📅 LeaveApiService: Raw response: ${response.data}');
      print('📅 LeaveApiService: Response status code: ${response.statusCode}');

      // Parse the response
      final leaveResponse = LeaveRequestResponse.fromJson(response.data);
      
      print('📅 LeaveApiService: Parsed Response Code: ${leaveResponse.code}');
      print('📅 LeaveApiService: Message: ${leaveResponse.message}');
      
      // Check if it's a successful response or specific error response
      if (leaveResponse.isSuccess || leaveResponse.isAttendanceExists) {
        print('✅ LeaveApiService: Leave request response processed successfully');
        return leaveResponse;
      } else {
        print('❌ LeaveApiService: Failed to process leave request - code is ${leaveResponse.code}');
        throw ApiError.fromJson(response.data);
      }
    } on DioException catch (e) {
      print('❌ LeaveApiService: DioException caught: ${e.type}');
      print('❌ LeaveApiService: DioException message: ${e.message}');
      print('❌ LeaveApiService: DioException error: ${e.error}');
      print('❌ LeaveApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ LeaveApiService: DioException response data: ${e.response?.data}');
      
      // Handle Dio-specific errors
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to create leave request',
        );
      }
    } catch (e) {
      print('❌ LeaveApiService: General exception caught: ${e.toString()}');
      print('❌ LeaveApiService: Exception type: ${e.runtimeType}');
      
      // Handle other errors
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Fetch leave policies
  /// Returns LeavePolicyResponse on success, throws ApiError on failure
  static Future<LeavePolicyResponse> getLeavePolicies() async {
    try {
      print('📋 LeaveApiService: Fetching leave policies');
      print('📋 LeaveApiService: API URL: ${AppConfig.apiBaseUrl}/leave-policy/get');

      final response = await _dio.post('/leave-policy/get');

      print('📋 LeaveApiService: Raw response: ${response.data}');
      print('📋 LeaveApiService: Response status code: ${response.statusCode}');

      // Parse the response
      final policyResponse = LeavePolicyResponse.fromJson(response.data);
      print('📋 LeaveApiService: Parsed Response Code: ${policyResponse.code}');
      print('📋 LeaveApiService: Message: ${policyResponse.message}');
      print('📋 LeaveApiService: Policies count: ${policyResponse.data.length}');

      if (policyResponse.code == 200) {
        print('✅ LeaveApiService: Leave policies fetched successfully');
        return policyResponse;
      } else {
        print('❌ LeaveApiService: Failed to fetch leave policies - code is ${policyResponse.code}');
        throw ApiError.fromJson(response.data);
      }
    } on DioException catch (e) {
      print('❌ LeaveApiService: DioException caught: ${e.type}');
      print('❌ LeaveApiService: DioException message: ${e.message}');
      print('❌ LeaveApiService: DioException error: ${e.error}');
      print('❌ LeaveApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ LeaveApiService: DioException response data: ${e.response?.data}');
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to fetch leave policies',
        );
      }
    } catch (e) {
      print('❌ LeaveApiService: General exception caught: ${e.toString()}');
      print('❌ LeaveApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Fetch available leave count for a leave type
  static Future<AvailableLeaveResponse> getAvailableLeave(String leaveType) async {
    try {
      print('📊 LeaveApiService: Fetching available leave for $leaveType');
      print('📊 LeaveApiService: API URL: ${AppConfig.apiBaseUrl}/leave-request/get-available-leave');
      final response = await _dio.post('/leave-request/get-available-leave', data: {'leaveType': leaveType});
      print('📊 LeaveApiService: Raw response: ${response.data}');
      print('📊 LeaveApiService: Response status code: ${response.statusCode}');
      final availableResponse = AvailableLeaveResponse.fromJson(response.data);
      print('📊 LeaveApiService: Available Leave: ${availableResponse.data?.availableLeaveCount}');
      return availableResponse;
    } on DioException catch (e) {
      print('❌ LeaveApiService: DioException caught: ${e.type}');
      print('❌ LeaveApiService: DioException message: ${e.message}');
      print('❌ LeaveApiService: DioException error: ${e.error}');
      print('❌ LeaveApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ LeaveApiService: DioException response data: ${e.response?.data}');
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to fetch available leave',
        );
      }
    } catch (e) {
      print('❌ LeaveApiService: General exception caught: ${e.toString()}');
      print('❌ LeaveApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Fetch user's own leave requests
  static Future<LeaveRequestListResponse> getOwnLeaveRequests() async {
    try {
      print('📋 LeaveApiService: Fetching own leave requests');
      print('📋 LeaveApiService: API URL: ${AppConfig.apiBaseUrl}/leave-request/get-own');
      final response = await _dio.post('/leave-request/get-own');
      print('📋 LeaveApiService: Raw response: ${response.data}');
      print('📋 LeaveApiService: Response status code: ${response.statusCode}');
      final listResponse = LeaveRequestListResponse.fromJson(response.data);
      print('📋 LeaveApiService: Requests count: ${listResponse.data.length}');
      return listResponse;
    } on DioException catch (e) {
      print('❌ LeaveApiService: DioException caught: ${e.type}');
      print('❌ LeaveApiService: DioException message: ${e.message}');
      print('❌ LeaveApiService: DioException error: ${e.error}');
      print('❌ LeaveApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ LeaveApiService: DioException response data: ${e.response?.data}');
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to fetch leave requests',
        );
      }
    } catch (e) {
      print('❌ LeaveApiService: General exception caught: ${e.toString()}');
      print('❌ LeaveApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Fetch leave policy types for leave balance
  static Future<LeavePolicyTypesResponse> getLeavePolicyTypes() async {
    try {
      print('📊 LeaveApiService: Fetching leave policy types');
      print('📊 LeaveApiService: API URL: ${AppConfig.apiBaseUrl}/leave-policy/get-types');
      final response = await _dio.post('/leave-policy/get-types');
      print('📊 LeaveApiService: Raw response: ${response.data}');
      print('📊 LeaveApiService: Response status code: ${response.statusCode}');
      final typesResponse = LeavePolicyTypesResponse.fromJson(response.data);
      print('📊 LeaveApiService: Policy types count: ${typesResponse.data.length}');
      return typesResponse;
    } on DioException catch (e) {
      print('❌ LeaveApiService: DioException caught: ${e.type}');
      print('❌ LeaveApiService: DioException message: ${e.message}');
      print('❌ LeaveApiService: DioException error: ${e.error}');
      print('❌ LeaveApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ LeaveApiService: DioException response data: ${e.response?.data}');
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to fetch leave policy types',
        );
      }
    } catch (e) {
      print('❌ LeaveApiService: General exception caught: ${e.toString()}');
      print('❌ LeaveApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
} 