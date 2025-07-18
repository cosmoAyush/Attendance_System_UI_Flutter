import 'package:attendance_system_hris/services/api/auth_api_service.dart';
import 'package:attendance_system_hris/services/api/employee_api_service.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';
import 'package:attendance_system_hris/models/api/employee_models.dart';
import 'package:attendance_system_hris/core/network/dio_client.dart';
import 'package:attendance_system_hris/core/config/app_config.dart';
import 'package:attendance_system_hris/services/biometric_auth_helper.dart';
import 'package:dio/dio.dart';

class AuthService {
  static bool _isLoggedIn = false;
  static String? _currentUser;
  static LoginResponse? _lastLoginResponse;
  static EmployeeData? _currentEmployee;

  // Login with API integration
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 AuthService: Starting login process');
      
      // Clear any existing JWT token before login
      DioClient.clearJwtToken();
      
      final response = await AuthApiService.authenticate(
        email: email,
        password: password,
      );

      print('🔐 AuthService: API call completed successfully');
      print('🔐 AuthService: Response code: ${response.code}');

      // Check the code field from response body
      if (response.code == 200) {
        _isLoggedIn = true;
        _currentUser = email;
        _lastLoginResponse = response;
        
        // Check if JWT token was set by the interceptor
        if (!DioClient.hasJwtToken()) {
          print('⚠️ JWT token not automatically set by interceptor');
        } else {
          print('✅ JWT token is available after login');
        }
        
        // Fetch employee details after successful login
        try {
          await fetchEmployeeDetails();
        } catch (e) {
          print('⚠️ AuthService: Failed to fetch employee details: ${e.toString()}');
          // Don't fail login if employee details fetch fails
        }
        
        print('✅ AuthService: Login successful, user logged in');
        return true;
      } else {
        print('❌ AuthService: Login failed - response code is ${response.code}');
        return false;
      }
    } on ApiError catch (e) {
      print('❌ AuthService: ApiError caught: ${e.displayMessage}');
      print('❌ AuthService: ApiError code: ${e.statusCode}');
      print('❌ AuthService: ApiError message: ${e.message}');
      return false;
    } on DioException catch (e) {
      print('❌ AuthService: DioException caught: ${e.type}');
      print('❌ AuthService: DioException message: ${e.message}');
      print('❌ AuthService: DioException error: ${e.error}');
      return false;
    } catch (e) {
      print('❌ AuthService: General exception caught: ${e.toString()}');
      print('❌ AuthService: Exception type: ${e.runtimeType}');
      return false;
    }
  }

  // Fetch employee details
  static Future<EmployeeData?> fetchEmployeeDetails() async {
    try {
      print('👤 AuthService: Fetching employee details');
      
      // Debug: Check JWT token before making the request
      if (DioClient.hasJwtToken()) {
        final token = DioClient.getJwtToken();
        final displayLength = token!.length > 20 ? 20 : token.length;
        print('🍪 AuthService: JWT token available: ${token.substring(0, displayLength)}...');
      } else {
        print('⚠️ AuthService: No JWT token available for employee request');
      }
      
      final response = await EmployeeApiService.getAuthenticatedEmployee();
      if (response.code == 200) {
        _currentEmployee = response.data;
        print('✅ AuthService: Employee details fetched successfully');
        return _currentEmployee;
      } else {
        print('❌ AuthService: Failed to fetch employee details - response code is ${response.code}');
        return null;
      }
    } catch (e) {
      print('❌ AuthService: Failed to fetch employee details: ${e.toString()}');
      return null;
    }
  }

  // Logout with API integration and improved timeout handling
  static Future<LogoutResponse> logout() async {
    try {
      print('🔐 AuthService: Starting logout process');
      
      // Call logout API first with timeout
      final logoutResponse = await AuthApiService.logout().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          print('⚠️ AuthService: Logout API timeout, continuing with cleanup');
          throw Exception('Logout API timeout');
        },
      );
      print('✅ AuthService: Logout API call successful');
      
      // Clear local data after successful API call
      await _clearLocalData();
      
      return logoutResponse;
      
    } catch (e) {
      print('⚠️ AuthService: Logout API error: ${e.toString()}');
      // Continue with local cleanup even if API fails
      await _clearLocalData();
      
      // Return a default response indicating local cleanup completed
      return LogoutResponse(
        httpStatus: 'OK',
        message: 'Local session cleared',
        code: 200,
        asyncRequest: false,
      );
    }
  }

  // Helper method to clear local data (preserving biometric)
  static Future<void> _clearLocalData() async {
    print('🧹 AuthService: Clearing local session data (preserving biometric)');
    
    // Note: Biometric data is NOT cleared - user can still use biometric login
    print('🔐 AuthService: Biometric authentication preserved for next login');
    
    // Clear all local data immediately
    _isLoggedIn = false;
    _currentUser = null;
    _lastLoginResponse = null;
    _currentEmployee = null;
    
    // Clear JWT token
    DioClient.clearJwtToken();
    
    // Clear any cached data
    clearSession();
    
    print('✅ AuthService: Session and JWT token cleared successfully (biometric preserved)');
  }

  // Check authentication status
  static Future<bool> checkAuthentication() async {
    try {
      final isAuth = await AuthApiService.isAuthenticated();
      _isLoggedIn = isAuth;
      if (isAuth && _currentEmployee == null) {
        // Fetch employee details if authenticated but not loaded
        await fetchEmployeeDetails();
      }
      return isAuth;
    } catch (e) {
      _isLoggedIn = false;
      return false;
    }
  }

  // Refresh token
  static Future<bool> refreshToken() async {
    try {
      final success = await AuthApiService.refreshToken();
      if (!success) {
        _isLoggedIn = false;
        _currentUser = null;
        _currentEmployee = null;
      }
      return success;
    } catch (e) {
      _isLoggedIn = false;
      _currentUser = null;
      _currentEmployee = null;
      return false;
    }
  }

  // Getters
  static bool get isLoggedIn => _isLoggedIn;
  static String? get currentUser => _currentUser;
  static LoginResponse? get lastLoginResponse => _lastLoginResponse;
  static EmployeeData? get currentEmployee => _currentEmployee;

  // Setters
  static set currentEmployee(EmployeeData? employee) {
    _currentEmployee = employee;
  }

  // Mock user data - replace with actual user model
  static Map<String, dynamic> getCurrentUserData() {
    if (_currentEmployee != null) {
      return {
        'id': _currentEmployee!.id.toString(),
        'name': _currentEmployee!.fullName,
        'email': _currentEmployee!.email,
        'role': _currentEmployee!.position,
        'department': _currentEmployee!.department,
        'employeeId': _currentEmployee!.id.toString(),
        'avatar': _currentEmployee!.imageUrl,
      };
    }
    
    return {
      'id': '1',
      'name': 'John Doe',
      'email': _currentUser ?? 'admin@example.com',
      'role': 'Software Developer',
      'department': 'Engineering',
      'employeeId': 'EMP001',
      'avatar': null,
    };
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return _isLoggedIn && _currentUser != null;
  }

  // Get user token - for cookie-based auth, this might not be needed
  static String? getToken() {
    return _isLoggedIn ? 'cookie_based_auth' : null;
  }

  // Clear session data
  static void clearSession() {
    _isLoggedIn = false;
    _currentUser = null;
    _lastLoginResponse = null;
    _currentEmployee = null;
  }
} 