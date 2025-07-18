import 'package:flutter/material.dart';

class AttendanceStatusResponse {
  final String httpStatus;
  final String message;
  final int code;
  final AttendanceStatusData? data;
  final bool asyncRequest;

  AttendanceStatusResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    this.data,
    required this.asyncRequest,
  });

  factory AttendanceStatusResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceStatusResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: json['data'] != null ? AttendanceStatusData.fromJson(json['data']) : null,
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'httpStatus': httpStatus,
      'message': message,
      'code': code,
      'data': data?.toJson(),
      'asyncRequest': asyncRequest,
    };
  }

  bool get isSuccess => code == 200;
  bool get isNotMarkedToday => code == 500 && message.contains('Not marked checkin today yet');
}

class CheckInResponse {
  final String httpStatus;
  final String message;
  final int code;
  final bool asyncRequest;

  CheckInResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.asyncRequest,
  });

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
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
  bool get isAlreadyMarked => code == 500 && message.contains('already marked your attendance today');
}

class CheckOutResponse {
  final String httpStatus;
  final String message;
  final int code;
  final bool asyncRequest;

  CheckOutResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.asyncRequest,
  });

  factory CheckOutResponse.fromJson(Map<String, dynamic> json) {
    return CheckOutResponse(
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
  bool get isAlreadyCheckedOut => code == 500 && message.contains('already checked out today');
}

class AttendanceStatusData {
  final int id;
  final String status;
  final DateTime? attendanceDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AttendanceStatusData({
    required this.id,
    required this.status,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceStatusData.fromJson(Map<String, dynamic> json) {
    return AttendanceStatusData(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      attendanceDate: json['attendanceDate'] != null ? DateTime.tryParse(json['attendanceDate']) : null,
      checkInTime: json['checkInTime'] != null ? DateTime.tryParse(json['checkInTime']) : null,
      checkOutTime: json['checkOutTime'] != null ? DateTime.tryParse(json['checkOutTime']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'attendanceDate': attendanceDate?.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get formattedCheckInTime {
    if (checkInTime == null) return 'Not checked in';
    return '${checkInTime!.hour.toString().padLeft(2, '0')}:${checkInTime!.minute.toString().padLeft(2, '0')}';
  }

  String get formattedCheckOutTime {
    if (checkOutTime == null) return 'Not checked out';
    return '${checkOutTime!.hour.toString().padLeft(2, '0')}:${checkOutTime!.minute.toString().padLeft(2, '0')}';
  }

  bool get isCheckedIn => checkInTime != null;
  bool get isCheckedOut => checkOutTime != null;
  bool get isPresent => status.toLowerCase() == 'present';
}

class AttendanceHistoryResponse {
  final String httpStatus;
  final String message;
  final int code;
  final List<AttendanceHistoryData> data;
  final bool asyncRequest;

  AttendanceHistoryResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.data,
    required this.asyncRequest,
  });

  factory AttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: json['data'] != null 
          ? List<AttendanceHistoryData>.from(
              json['data'].map((x) => AttendanceHistoryData.fromJson(x)))
          : [],
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'httpStatus': httpStatus,
      'message': message,
      'code': code,
      'data': data.map((x) => x.toJson()).toList(),
      'asyncRequest': asyncRequest,
    };
  }

  bool get isSuccess => code == 200;
}

class AttendanceHistoryData {
  final int id;
  final String status;
  final DateTime? attendanceDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AttendanceHistoryData({
    required this.id,
    required this.status,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceHistoryData.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryData(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      attendanceDate: json['attendanceDate'] != null ? DateTime.tryParse(json['attendanceDate']) : null,
      checkInTime: json['checkInTime'] != null ? DateTime.tryParse(json['checkInTime']) : null,
      checkOutTime: json['checkOutTime'] != null ? DateTime.tryParse(json['checkOutTime']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'attendanceDate': attendanceDate?.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get formattedDate {
    if (attendanceDate == null) return 'N/A';
    return '${attendanceDate!.day}/${attendanceDate!.month}/${attendanceDate!.year}';
  }

  String get formattedCheckInTime {
    if (checkInTime == null) return 'Not checked in';
    return '${checkInTime!.hour.toString().padLeft(2, '0')}:${checkInTime!.minute.toString().padLeft(2, '0')}';
  }

  String get formattedCheckOutTime {
    if (checkOutTime == null) return 'Not checked out';
    return '${checkOutTime!.hour.toString().padLeft(2, '0')}:${checkOutTime!.minute.toString().padLeft(2, '0')}';
  }

  String get dayName {
    if (attendanceDate == null) return 'N/A';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[attendanceDate!.weekday - 1];
  }

  bool get isCheckedIn => checkInTime != null;
  bool get isCheckedOut => checkOutTime != null;
  bool get isPresent => status.toLowerCase() == 'present';
  bool get isAbsent => status.toLowerCase() == 'absent';
  bool get isLeave => status.toLowerCase() == 'leave';
}

class AttendanceRequestResponse {
  final String httpStatus;
  final String message;
  final int code;
  final bool asyncRequest;

  AttendanceRequestResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.asyncRequest,
  });

  factory AttendanceRequestResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceRequestResponse(
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

  bool get isSuccess => code == 201;
  bool get isOnLeave => code == 500 && message.contains('on Leave status');
}

class AttendanceRequestData {
  final String requestedType;
  final String requestedTime;
  final String reason;
  final DateTime attendanceDate;

  AttendanceRequestData({
    required this.requestedType,
    required this.requestedTime,
    required this.reason,
    required this.attendanceDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestedType': requestedType,
      'requestedTime': requestedTime,
      'reason': reason,
      'attendanceDate': attendanceDate.toIso8601String(),
    };
  }
} 

// Monthly Attendance Record Request
class MonthlyAttendanceRequest {
  final int year;
  final int month;

  MonthlyAttendanceRequest({
    required this.year,
    required this.month,
  });

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
    };
  }
}

// Monthly Attendance Record Response
class MonthlyAttendanceResponse {
  final String httpStatus;
  final String message;
  final int code;
  final List<MonthlyAttendanceRecord> data;
  final bool asyncRequest;

  MonthlyAttendanceResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.data,
    required this.asyncRequest,
  });

  factory MonthlyAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyAttendanceResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => MonthlyAttendanceRecord.fromJson(item))
              .toList() ??
          [],
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }

  bool get isSuccess => code == 200;
}

class MonthlyAttendanceRecord {
  final int id;
  final String status;
  final String attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final String createdAt;
  final String updatedAt;

  MonthlyAttendanceRecord({
    required this.id,
    required this.status,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MonthlyAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return MonthlyAttendanceRecord(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      attendanceDate: json['attendanceDate'] ?? '',
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  DateTime get attendanceDateTime {
    try {
      return DateTime.parse(attendanceDate);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime? get checkInDateTime {
    if (checkInTime == null) return null;
    try {
      return DateTime.parse(checkInTime!);
    } catch (e) {
      return null;
    }
  }

  DateTime? get checkOutDateTime {
    if (checkOutTime == null) return null;
    try {
      return DateTime.parse(checkOutTime!);
    } catch (e) {
      return null;
    }
  }

  String get formattedDate {
    final date = attendanceDateTime;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get formattedCheckInTime {
    final time = checkInDateTime;
    if (time == null) return 'Not checked in';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get formattedCheckOutTime {
    final time = checkOutDateTime;
    if (time == null) return 'Not checked out';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get dayName {
    final date = attendanceDateTime;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'half day':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

// Monthly Overview Response
class MonthlyOverviewResponse {
  final String httpStatus;
  final String message;
  final int code;
  final MonthlyOverviewData? data;
  final bool asyncRequest;

  MonthlyOverviewResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    this.data,
    required this.asyncRequest,
  });

  factory MonthlyOverviewResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyOverviewResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: json['data'] != null ? MonthlyOverviewData.fromJson(json['data']) : null,
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'httpStatus': httpStatus,
      'message': message,
      'code': code,
      'data': data?.toJson(),
      'asyncRequest': asyncRequest,
    };
  }

  bool get isSuccess => code == 200;
}

// Monthly Overview Data
class MonthlyOverviewData {
  final int presentDay;
  final int absentDay;
  final int leaveDay;

  MonthlyOverviewData({
    required this.presentDay,
    required this.absentDay,
    required this.leaveDay,
  });

  factory MonthlyOverviewData.fromJson(Map<String, dynamic> json) {
    return MonthlyOverviewData(
      presentDay: json['presentDay'] ?? 0,
      absentDay: json['absentDay'] ?? 0,
      leaveDay: json['leaveDay'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'presentDay': presentDay,
      'absentDay': absentDay,
      'leaveDay': leaveDay,
    };
  }

  int get totalDays => presentDay + absentDay + leaveDay;
} 