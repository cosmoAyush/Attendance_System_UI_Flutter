class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}

class LoginResponse {
  final String httpStatus;
  final String message;
  final int code;
  final bool asyncRequest;

  LoginResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.asyncRequest,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'httpStatus': httpStatus,
      'message': message,
      'code': code,
      'asyncRequest': asyncRequest,
    };
  }

  bool get isSuccess => code == 200;
}

class ApiError {
  final int statusCode;
  final String message;
  final String? error;

  ApiError({
    required this.statusCode,
    required this.message,
    this.error,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      statusCode: json['code'] ?? json['statusCode'] ?? 500,
      message: json['message'] ?? 'An error occurred',
      error: json['error'],
    );
  }

  factory ApiError.fromStatusCode(int statusCode, String message) {
    return ApiError(
      statusCode: statusCode,
      message: message,
    );
  }

  String get displayMessage {
    switch (statusCode) {
      case 401:
        return 'Invalid credentials. Please check your email and password.';
      case 404:
        return 'Service not found. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return message;
    }
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

class ChangePasswordResponse {
  final String httpStatus;
  final String message;
  final int code;
  final bool asyncRequest;

  ChangePasswordResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.asyncRequest,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }

  bool get isSuccess => code == 201;
}

class QuickAttendanceRequest {
  final String email;
  final String password;
  final String action;

  QuickAttendanceRequest({
    required this.email,
    required this.password,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'action': action,
    };
  }

  factory QuickAttendanceRequest.fromJson(Map<String, dynamic> json) {
    return QuickAttendanceRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      action: json['action'] ?? '',
    );
  }
}

class QuickAttendanceResponse {
  final String httpStatus;
  final String message;
  final int code;
  final bool asyncRequest;

  QuickAttendanceResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.asyncRequest,
  });

  factory QuickAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return QuickAttendanceResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'httpStatus': httpStatus,
      'message': message,
      'code': code,
      'asyncRequest': asyncRequest,
    };
  }

  bool get isSuccess => code == 200;
}

class LogoutResponse {
  final String httpStatus;
  final String message;
  final int code;
  final bool asyncRequest;

  LogoutResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.asyncRequest,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'httpStatus': httpStatus,
      'message': message,
      'code': code,
      'asyncRequest': asyncRequest,
    };
  }

  bool get isSuccess => code == 200;
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequest(
      email: json['email'] ?? '',
    );
  }
}

class ForgotPasswordResponse {
  final String httpStatus;
  final String message;
  final int code;
  final bool asyncRequest;

  ForgotPasswordResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.asyncRequest,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'httpStatus': httpStatus,
      'message': message,
      'code': code,
      'asyncRequest': asyncRequest,
    };
  }

  bool get isSuccess => code == 200;
}

class VerifyOtpRequest {
  final String email;
  final int otp;
  final String password;
  final String confirmPassword;

  VerifyOtpRequest({
    required this.email,
    required this.otp,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) {
    return VerifyOtpRequest(
      email: json['email'] ?? '',
      otp: json['otp'] ?? 0,
      password: json['password'] ?? '',
      confirmPassword: json['confirmPassword'] ?? '',
    );
  }
}

class VerifyOtpResponse {
  final String httpStatus;
  final String message;
  final int code;
  final bool asyncRequest;

  VerifyOtpResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.asyncRequest,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'httpStatus': httpStatus,
      'message': message,
      'code': code,
      'asyncRequest': asyncRequest,
    };
  }

  bool get isSuccess => code == 200;
} 