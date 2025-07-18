import 'package:flutter/material.dart';

class LeaveRequestResponse {
  final String httpStatus;
  final String message;
  final int code;
  final bool asyncRequest;

  LeaveRequestResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.asyncRequest,
  });

  factory LeaveRequestResponse.fromJson(Map<String, dynamic> json) {
    return LeaveRequestResponse(
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
  bool get isAttendanceExists => code == 500 && message.contains('Attendance already exists');
}

class LeaveRequestData {
  final DateTime startDate;
  final DateTime endDate;
  final String leaveType;
  final String reason;

  LeaveRequestData({
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'leaveType': leaveType,
      'reason': reason,
    };
  }

  String get formattedStartDate {
    return '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
  }

  String get formattedEndDate {
    return '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
  }

  int get numberOfDays {
    return endDate.difference(startDate).inDays + 1;
  }
}

class LeavePolicyResponse {
  final String httpStatus;
  final String message;
  final int code;
  final List<LeavePolicy> data;
  final bool asyncRequest;

  LeavePolicyResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.data,
    required this.asyncRequest,
  });

  factory LeavePolicyResponse.fromJson(Map<String, dynamic> json) {
    return LeavePolicyResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: json['data'] != null
          ? List<LeavePolicy>.from(
              (json['data'] as List).map((x) => LeavePolicy.fromJson(x)))
          : [],
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }
}

class LeavePolicy {
  final int id;
  final String leaveType;
  final String maxDay;
  final LeavePolicyCategory leavePolicyCategory;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeavePolicy({
    required this.id,
    required this.leaveType,
    required this.maxDay,
    required this.leavePolicyCategory,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory LeavePolicy.fromJson(Map<String, dynamic> json) {
    return LeavePolicy(
      id: json['id'] ?? 0,
      leaveType: json['leaveType'] ?? '',
      maxDay: json['maxDay'] ?? '',
      leavePolicyCategory: LeavePolicyCategory.fromJson(json['leavePolicyCategory'] ?? {}),
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
}

class LeavePolicyCategory {
  final int id;
  final String name;

  LeavePolicyCategory({
    required this.id,
    required this.name,
  });

  factory LeavePolicyCategory.fromJson(Map<String, dynamic> json) {
    return LeavePolicyCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class AvailableLeaveResponse {
  final String httpStatus;
  final String message;
  final int code;
  final AvailableLeaveData? data;
  final bool asyncRequest;

  AvailableLeaveResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.data,
    required this.asyncRequest,
  });

  factory AvailableLeaveResponse.fromJson(Map<String, dynamic> json) {
    return AvailableLeaveResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: json['data'] != null ? AvailableLeaveData.fromJson(json['data']) : null,
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }
}

class AvailableLeaveData {
  final int availableLeaveCount;

  AvailableLeaveData({required this.availableLeaveCount});

  factory AvailableLeaveData.fromJson(Map<String, dynamic> json) {
    return AvailableLeaveData(
      availableLeaveCount: json['availableLeaveCount'] ?? 0,
    );
  }
}

class LeaveRequestListResponse {
  final String httpStatus;
  final String message;
  final int code;
  final List<LeaveRequestListItem> data;
  final bool asyncRequest;

  LeaveRequestListResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.data,
    required this.asyncRequest,
  });

  factory LeaveRequestListResponse.fromJson(Map<String, dynamic> json) {
    return LeaveRequestListResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: json['data'] != null
          ? List<LeaveRequestListItem>.from(
              (json['data'] as List).map((x) => LeaveRequestListItem.fromJson(x)))
          : [],
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }
}

class LeaveRequestListItem {
  final DateTime? startDate;
  final DateTime? endDate;
  final String reason;
  final LeaveRequestStatus status;
  final DateTime? createdAt;
  final LeaveRequestListPolicy leavePolicy;

  LeaveRequestListItem({
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.leavePolicy,
  });

  factory LeaveRequestListItem.fromJson(Map<String, dynamic> json) {
    return LeaveRequestListItem(
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      reason: json['reason'] ?? '',
      status: LeaveRequestStatus.fromJson(json['status'] ?? {}),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      leavePolicy: LeaveRequestListPolicy.fromJson(json['leavePolicy'] ?? {}),
    );
  }

  String get formattedStartDate {
    if (startDate == null) return 'N/A';
    return '${startDate!.day.toString().padLeft(2, '0')}/${startDate!.month.toString().padLeft(2, '0')}/${startDate!.year}';
  }

  String get formattedEndDate {
    if (endDate == null) return 'N/A';
    return '${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year}';
  }

  String get formattedCreatedAt {
    if (createdAt == null) return 'N/A';
    return '${createdAt!.day.toString().padLeft(2, '0')}/${createdAt!.month.toString().padLeft(2, '0')}/${createdAt!.year}';
  }

  int get numberOfDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }
}

class LeaveRequestStatus {
  final String status;

  LeaveRequestStatus({required this.status});

  factory LeaveRequestStatus.fromJson(Map<String, dynamic> json) {
    return LeaveRequestStatus(
      status: json['status'] ?? '',
    );
  }

  Color get color {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const Color(0xFF22C55E); // Green
      case 'REJECTED':
        return const Color(0xFFEF4444); // Red
      case 'PENDING':
      default:
        return const Color(0xFFF59E0B); // Orange
    }
  }
}

class LeaveRequestListPolicy {
  final String leaveType;
  final String maxDay;

  LeaveRequestListPolicy({required this.leaveType, required this.maxDay});

  factory LeaveRequestListPolicy.fromJson(Map<String, dynamic> json) {
    return LeaveRequestListPolicy(
      leaveType: json['leaveType'] ?? '',
      maxDay: json['maxDay'] ?? '',
    );
  }
}

// Leave Policy Types Response Models
class LeavePolicyTypesResponse {
  final String httpStatus;
  final String message;
  final int code;
  final List<LeavePolicyType> data;
  final bool asyncRequest;

  LeavePolicyTypesResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.data,
    required this.asyncRequest,
  });

  factory LeavePolicyTypesResponse.fromJson(Map<String, dynamic> json) {
    return LeavePolicyTypesResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => LeavePolicyType.fromJson(item))
              .toList() ??
          [],
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }

  bool get isSuccess => code == 200;
}

class LeavePolicyType {
  final int id;
  final String leaveType;
  final String maxDay;
  final LeavePolicyCategory leavePolicyCategory;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  LeavePolicyType({
    required this.id,
    required this.leaveType,
    required this.maxDay,
    required this.leavePolicyCategory,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeavePolicyType.fromJson(Map<String, dynamic> json) {
    return LeavePolicyType(
      id: json['id'] ?? 0,
      leaveType: json['leaveType'] ?? '',
      maxDay: json['maxDay'] ?? '0',
      leavePolicyCategory: LeavePolicyCategory.fromJson(json['leavePolicyCategory'] ?? {}),
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  int get maxDayInt => int.tryParse(maxDay) ?? 0;
} 