class AppConfig {
  // static const String baseUrl = "https://ad071c93e320.ngrok-free.app";
  static const String baseUrl = "https://api.cosmotechintl.com/COSMO_HRIS";

  static const String apiVersion = "/api/v1";
  static const String apiBaseUrl = "$baseUrl$apiVersion";
  
  // API Endpoints
  static const String authEndpoint = "/auth/authenticate";
  static const String isAuthenticatedEndpoint = "/auth/isAuthenticated";
  static const String quickAttendanceEndpoint = "/auth/quick-action";
  static const String forgotPasswordEndpoint = "/auth/forget-password";
  static const String verifyOtpEndpoint = "/auth/verify-otp";
  static const String attendanceEndpoint = "/attendance";
  static const String leaveEndpoint = "/leave";
  static const String userEndpoint = "/user";
  static const String reportEndpoint = "/report";
  static const String employeeEndpoint = "/employee/getAuthenticatedEmployee";
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Cookie Configuration
  static const String cookieName = 'jwt';
} 