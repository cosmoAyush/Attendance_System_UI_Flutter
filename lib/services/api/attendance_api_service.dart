import 'package:dio/dio.dart';
import 'package:attendance_system_hris/core/config/app_config.dart';
import 'package:attendance_system_hris/core/network/dio_client.dart';
import 'package:attendance_system_hris/models/api/attendance_models.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';

class AttendanceApiService {
  static final Dio _dio = DioClient.instance;

  /// Get today's attendance status
  /// Returns AttendanceStatusResponse on success, throws ApiError on failure
  static Future<AttendanceStatusResponse> getTodayStatus() async {
    try {
      print('📅 AttendanceApiService: Fetching today\'s attendance status');
      print('📅 AttendanceApiService: API URL: ${AppConfig.apiBaseUrl}/attendance/getTodayStatus');

      final response = await _dio.get('/attendance/getTodayStatus');

      print('📅 AttendanceApiService: Raw response: ${response.data}');
      print('📅 AttendanceApiService: Response status code: ${response.statusCode}');

      // Parse the response
      final attendanceResponse = AttendanceStatusResponse.fromJson(response.data);
      
      print('📅 AttendanceApiService: Parsed Response Code: ${attendanceResponse.code}');
      print('📅 AttendanceApiService: Message: ${attendanceResponse.message}');
      
      // Check if it's a successful response or "not marked today" response
      if (attendanceResponse.isSuccess || attendanceResponse.isNotMarkedToday) {
        print('✅ AttendanceApiService: Today\'s status fetched successfully');
        return attendanceResponse;
      } else {
        print('❌ AttendanceApiService: Failed to fetch today\'s status - code is ${attendanceResponse.code}');
        throw ApiError.fromJson(response.data);
      }
    } on DioException catch (e) {
      print('❌ AttendanceApiService: DioException caught: ${e.type}');
      print('❌ AttendanceApiService: DioException message: ${e.message}');
      print('❌ AttendanceApiService: DioException error: ${e.error}');
      print('❌ AttendanceApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AttendanceApiService: DioException response data: ${e.response?.data}');
      
      // Handle Dio-specific errors
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to fetch today\'s attendance status',
        );
      }
    } catch (e) {
      print('❌ AttendanceApiService: General exception caught: ${e.toString()}');
      print('❌ AttendanceApiService: Exception type: ${e.runtimeType}');
      
      // Handle other errors
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Check in for today
  /// Returns CheckInResponse on success, throws ApiError on failure
  static Future<CheckInResponse> checkIn() async {
    try {
      print('✅ AttendanceApiService: Starting check-in process');
      print('✅ AttendanceApiService: API URL: ${AppConfig.apiBaseUrl}/attendance/check-in');

      final response = await _dio.post('/attendance/check-in');

      print('✅ AttendanceApiService: Raw response: ${response.data}');
      print('✅ AttendanceApiService: Response status code: ${response.statusCode}');

      // Parse the response
      final checkInResponse = CheckInResponse.fromJson(response.data);
      
      print('✅ AttendanceApiService: Parsed Response Code: ${checkInResponse.code}');
      print('✅ AttendanceApiService: Message: ${checkInResponse.message}');
      
      // Check if it's a successful response or "already marked" response
      if (checkInResponse.isSuccess || checkInResponse.isAlreadyMarked) {
        print('✅ AttendanceApiService: Check-in response processed successfully');
        return checkInResponse;
      } else {
        print('❌ AttendanceApiService: Failed to process check-in - code is ${checkInResponse.code}');
        throw ApiError.fromJson(response.data);
      }
    } on DioException catch (e) {
      print('❌ AttendanceApiService: DioException caught: ${e.type}');
      print('❌ AttendanceApiService: DioException message: ${e.message}');
      print('❌ AttendanceApiService: DioException error: ${e.error}');
      print('❌ AttendanceApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AttendanceApiService: DioException response data: ${e.response?.data}');
      
      // Handle Dio-specific errors
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to check in',
        );
      }
    } catch (e) {
      print('❌ AttendanceApiService: General exception caught: ${e.toString()}');
      print('❌ AttendanceApiService: Exception type: ${e.runtimeType}');
      
      // Handle other errors
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Check out for today
  /// Returns CheckOutResponse on success, throws ApiError on failure
  static Future<CheckOutResponse> checkOut() async {
    try {
      print('🚪 AttendanceApiService: Starting check-out process');
      print('🚪 AttendanceApiService: API URL: ${AppConfig.apiBaseUrl}/attendance/checkout');

      final response = await _dio.post('/attendance/checkout');

      print('🚪 AttendanceApiService: Raw response: ${response.data}');
      print('🚪 AttendanceApiService: Response status code: ${response.statusCode}');

      // Parse the response
      final checkOutResponse = CheckOutResponse.fromJson(response.data);
      
      print('🚪 AttendanceApiService: Parsed Response Code: ${checkOutResponse.code}');
      print('🚪 AttendanceApiService: Message: ${checkOutResponse.message}');
      
      // Check if it's a successful response or "already checked out" response
      if (checkOutResponse.isSuccess || checkOutResponse.isAlreadyCheckedOut) {
        print('✅ AttendanceApiService: Check-out response processed successfully');
        return checkOutResponse;
      } else {
        print('❌ AttendanceApiService: Failed to process check-out - code is ${checkOutResponse.code}');
        throw ApiError.fromJson(response.data);
      }
    } on DioException catch (e) {
      print('❌ AttendanceApiService: DioException caught: ${e.type}');
      print('❌ AttendanceApiService: DioException message: ${e.message}');
      print('❌ AttendanceApiService: DioException error: ${e.error}');
      print('❌ AttendanceApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AttendanceApiService: DioException response data: ${e.response?.data}');
      
      // Handle Dio-specific errors
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to check out',
        );
      }
    } catch (e) {
      print('❌ AttendanceApiService: General exception caught: ${e.toString()}');
      print('❌ AttendanceApiService: Exception type: ${e.runtimeType}');
      
      // Handle other errors
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get all attendance records
  /// Returns AttendanceHistoryResponse on success, throws ApiError on failure
  static Future<AttendanceHistoryResponse> getAllAttendance() async {
    try {
      print('📊 AttendanceApiService: Fetching all attendance records');
      print('📊 AttendanceApiService: API URL: ${AppConfig.apiBaseUrl}/attendance/getAll');

      final response = await _dio.get('/attendance/getAll');

      print('📊 AttendanceApiService: Raw response: ${response.data}');
      print('📊 AttendanceApiService: Response status code: ${response.statusCode}');

      // Parse the response
      final historyResponse = AttendanceHistoryResponse.fromJson(response.data);
      
      print('📊 AttendanceApiService: Parsed Response Code: ${historyResponse.code}');
      print('📊 AttendanceApiService: Message: ${historyResponse.message}');
      print('📊 AttendanceApiService: Records count: ${historyResponse.data.length}');
      
      if (historyResponse.isSuccess) {
        print('✅ AttendanceApiService: Attendance history fetched successfully');
        return historyResponse;
      } else {
        print('❌ AttendanceApiService: Failed to fetch attendance history - code is ${historyResponse.code}');
        throw ApiError.fromJson(response.data);
      }
    } on DioException catch (e) {
      print('❌ AttendanceApiService: DioException caught: ${e.type}');
      print('❌ AttendanceApiService: DioException message: ${e.message}');
      print('❌ AttendanceApiService: DioException error: ${e.error}');
      print('❌ AttendanceApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AttendanceApiService: DioException response data: ${e.response?.data}');
      
      // Handle Dio-specific errors
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to fetch attendance history',
        );
      }
    } catch (e) {
      print('❌ AttendanceApiService: General exception caught: ${e.toString()}');
      print('❌ AttendanceApiService: Exception type: ${e.runtimeType}');
      
      // Handle other errors
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Create attendance correction request
  /// Returns AttendanceRequestResponse on success, throws ApiError on failure
  static Future<AttendanceRequestResponse> createAttendanceRequest(AttendanceRequestData requestData) async {
    try {
      print('📝 AttendanceApiService: Creating attendance correction request');
      print('📝 AttendanceApiService: API URL: ${AppConfig.apiBaseUrl}/attendance-request/create');
      print('📝 AttendanceApiService: Request data: ${requestData.toJson()}');

      final response = await _dio.post('/attendance-request/create', data: requestData.toJson());

      print('📝 AttendanceApiService: Raw response: ${response.data}');
      print('📝 AttendanceApiService: Response status code: ${response.statusCode}');

      // Parse the response
      final requestResponse = AttendanceRequestResponse.fromJson(response.data);
      
      print('📝 AttendanceApiService: Parsed Response Code: ${requestResponse.code}');
      print('📝 AttendanceApiService: Message: ${requestResponse.message}');
      
      // Check if it's a successful response or specific error response
      if (requestResponse.isSuccess || requestResponse.isOnLeave) {
        print('✅ AttendanceApiService: Attendance request response processed successfully');
        return requestResponse;
      } else {
        print('❌ AttendanceApiService: Failed to process attendance request - code is ${requestResponse.code}');
        throw ApiError.fromJson(response.data);
      }
    } on DioException catch (e) {
      print('❌ AttendanceApiService: DioException caught: ${e.type}');
      print('❌ AttendanceApiService: DioException message: ${e.message}');
      print('❌ AttendanceApiService: DioException error: ${e.error}');
      print('❌ AttendanceApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AttendanceApiService: DioException response data: ${e.response?.data}');
      
      // Handle Dio-specific errors
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to create attendance request',
        );
      }
    } catch (e) {
      print('❌ AttendanceApiService: General exception caught: ${e.toString()}');
      print('❌ AttendanceApiService: Exception type: ${e.runtimeType}');
      
      // Handle other errors
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Fetch attendance history
  static Future<AttendanceHistoryResponse> getAttendanceHistory() async {
    try {
      print('📊 AttendanceApiService: Fetching attendance history');
      print('📊 AttendanceApiService: API URL: ${AppConfig.apiBaseUrl}/attendance/get-history');
      final response = await _dio.post('/attendance/get-history');
      print('📊 AttendanceApiService: Raw response: ${response.data}');
      print('📊 AttendanceApiService: Response status code: ${response.statusCode}');
      final historyResponse = AttendanceHistoryResponse.fromJson(response.data);
      print('📊 AttendanceApiService: History count: ${historyResponse.data.length}');
      return historyResponse;
    } on DioException catch (e) {
      print('❌ AttendanceApiService: DioException caught: ${e.type}');
      print('❌ AttendanceApiService: DioException message: ${e.message}');
      print('❌ AttendanceApiService: DioException error: ${e.error}');
      print('❌ AttendanceApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AttendanceApiService: DioException response data: ${e.response?.data}');
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to fetch attendance history',
        );
      }
    } catch (e) {
      print('❌ AttendanceApiService: General exception caught: ${e.toString()}');
      print('❌ AttendanceApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Fetch monthly attendance records
  static Future<MonthlyAttendanceResponse> getMonthlyAttendance(MonthlyAttendanceRequest request) async {
    try {
      print('📊 AttendanceApiService: Fetching monthly attendance records');
      print('📊 AttendanceApiService: API URL: ${AppConfig.apiBaseUrl}/attendance/getMonthlyRecord');
      print('📊 AttendanceApiService: Request data: ${request.toJson()}');
      final response = await _dio.post('/attendance/getMonthlyRecord', data: request.toJson());
      print('📊 AttendanceApiService: Raw response: ${response.data}');
      print('📊 AttendanceApiService: Response status code: ${response.statusCode}');
      final monthlyResponse = MonthlyAttendanceResponse.fromJson(response.data);
      print('📊 AttendanceApiService: Monthly records count: ${monthlyResponse.data.length}');
      return monthlyResponse;
    } on DioException catch (e) {
      print('❌ AttendanceApiService: DioException caught: ${e.type}');
      print('❌ AttendanceApiService: DioException message: ${e.message}');
      print('❌ AttendanceApiService: DioException error: ${e.error}');
      print('❌ AttendanceApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AttendanceApiService: DioException response data: ${e.response?.data}');
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to fetch monthly attendance records',
        );
      }
    } catch (e) {
      print('❌ AttendanceApiService: General exception caught: ${e.toString()}');
      print('❌ AttendanceApiService: Exception type: ${e.runtimeType}');
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get monthly overview of employee
  /// Returns MonthlyOverviewResponse on success, throws ApiError on failure
  static Future<MonthlyOverviewResponse> getMonthlyOverview() async {
    try {
      print('📊 AttendanceApiService: Fetching monthly overview');
      print('📊 AttendanceApiService: API URL: ${AppConfig.apiBaseUrl}/attendance/get-monthly-overview-of-employee');

      final response = await _dio.post('/attendance/get-monthly-overview-of-employee');

      print('📊 AttendanceApiService: Raw response: ${response.data}');
      print('📊 AttendanceApiService: Response status code: ${response.statusCode}');

      // Parse the response
      final overviewResponse = MonthlyOverviewResponse.fromJson(response.data);
      
      print('📊 AttendanceApiService: Parsed Response Code: ${overviewResponse.code}');
      print('📊 AttendanceApiService: Message: ${overviewResponse.message}');
      
      if (overviewResponse.isSuccess && overviewResponse.data != null) {
        print('✅ AttendanceApiService: Monthly overview fetched successfully');
        print('   Present Days: ${overviewResponse.data!.presentDay}');
        print('   Absent Days: ${overviewResponse.data!.absentDay}');
        print('   Leave Days: ${overviewResponse.data!.leaveDay}');
        return overviewResponse;
      } else {
        print('❌ AttendanceApiService: Failed to fetch monthly overview - code is ${overviewResponse.code}');
        throw ApiError.fromJson(response.data);
      }
    } on DioException catch (e) {
      print('❌ AttendanceApiService: DioException caught: ${e.type}');
      print('❌ AttendanceApiService: DioException message: ${e.message}');
      print('❌ AttendanceApiService: DioException error: ${e.error}');
      print('❌ AttendanceApiService: DioException response status: ${e.response?.statusCode}');
      print('❌ AttendanceApiService: DioException response data: ${e.response?.data}');
      
      // Handle Dio-specific errors
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Failed to fetch monthly overview',
        );
      }
    } catch (e) {
      print('❌ AttendanceApiService: General exception caught: ${e.toString()}');
      print('❌ AttendanceApiService: Exception type: ${e.runtimeType}');
      
      // Handle other errors
      throw ApiError.fromStatusCode(
        500,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
} 