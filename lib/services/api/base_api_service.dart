import 'package:dio/dio.dart';
import 'package:attendance_system_hris/core/network/dio_client.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';

abstract class BaseApiService {
  static final Dio _dio = DioClient.instance;

  /// Make a GET request
  static Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Make a POST request
  static Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Make a PUT request
  static Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Make a DELETE request
  static Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to ApiError
  static ApiError _handleDioError(DioException e) {
    if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
      try {
        return ApiError.fromJson(e.response!.data);
      } catch (parseError) {
        return ApiError.fromStatusCode(
          e.response?.statusCode ?? 500,
          e.error?.toString() ?? 'Request failed',
        );
      }
    } else {
      return ApiError.fromStatusCode(
        e.response?.statusCode ?? 500,
        e.error?.toString() ?? 'Request failed',
      );
    }
  }

  /// Check if response is successful
  static bool isSuccess(Response response) {
    return response.statusCode != null && 
           response.statusCode! >= 200 && 
           response.statusCode! < 300;
  }

  /// Parse response data safely
  static T? parseResponse<T>(
    Response response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    try {
      if (response.data is Map<String, dynamic>) {
        return fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error parsing response: $e');
      return null;
    }
  }

  /// Parse response data list safely
  static List<T> parseResponseList<T>(
    Response response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    try {
      if (response.data is List) {
        return (response.data as List)
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error parsing response list: $e');
      return [];
    }
  }
} 