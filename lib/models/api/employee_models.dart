import 'package:flutter/material.dart';

class EmployeeResponse {
  final String httpStatus;
  final String message;
  final int code;
  final EmployeeData data;
  final bool asyncRequest;

  EmployeeResponse({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.data,
    required this.asyncRequest,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeResponse(
      httpStatus: json['httpStatus'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: EmployeeData.fromJson(json['data'] ?? {}),
      asyncRequest: json['asyncRequest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'httpStatus': httpStatus,
      'message': message,
      'code': code,
      'data': data.toJson(),
      'asyncRequest': asyncRequest,
    };
  }

  bool get isSuccess => code == 200;
}

class EmployeeData {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final DateTime? dob;
  final DateTime? dateOfJoining;
  final String gender;
  final String status;
  final String bloodGroup;
  final String department;
  final String position;
  final String? imageUrl;
  final String? nationalId;
  final String? nationalIdImageUrl;
  final String? citizenshipNumber;
  final String? citizenshipImageUrl;
  final String? panNumber;
  final String? panImageUrl;

  EmployeeData({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.dob,
    this.dateOfJoining,
    required this.gender,
    required this.status,
    required this.bloodGroup,
    required this.department,
    required this.position,
    this.imageUrl,
    this.nationalId,
    this.nationalIdImageUrl,
    this.citizenshipNumber,
    this.citizenshipImageUrl,
    this.panNumber,
    this.panImageUrl,
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    return EmployeeData(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      dateOfJoining: json['dateOfJoining'] != null ? DateTime.tryParse(json['dateOfJoining']) : null,
      gender: json['gender'] ?? '',
      status: json['status'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      department: json['department'] ?? '',
      position: json['position'] ?? '',
      imageUrl: json['imageUrl'],
      nationalId: json['nationalId'],
      nationalIdImageUrl: json['nationalIdImageUrl'],
      citizenshipNumber: json['citizenshipNumber'],
      citizenshipImageUrl: json['citizenshipImageUrl'],
      panNumber: json['panNumber'],
      panImageUrl: json['panImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'dob': dob?.toIso8601String(),
      'dateOfJoining': dateOfJoining?.toIso8601String(),
      'gender': gender,
      'status': status,
      'bloodGroup': bloodGroup,
      'department': department,
      'position': position,
      'imageUrl': imageUrl,
      'nationalId': nationalId,
      'nationalIdImageUrl': nationalIdImageUrl,
      'citizenshipNumber': citizenshipNumber,
      'citizenshipImageUrl': citizenshipImageUrl,
      'panNumber': panNumber,
      'panImageUrl': panImageUrl,
    };
  }

  String get displayName => fullName.isNotEmpty ? fullName : email;
  String get shortName {
    if (fullName.isEmpty) return email.split('@').first;
    final names = fullName.split(' ');
    return names.length > 1 ? '${names.first} ${names.last}' : fullName;
  }

  String get formattedDateOfBirth {
    if (dob == null) return '';
    return '${dob!.day.toString().padLeft(2, '0')}/${dob!.month.toString().padLeft(2, '0')}/${dob!.year}';
  }

  String get formattedDateOfJoining {
    if (dateOfJoining == null) return '';
    return '${dateOfJoining!.day.toString().padLeft(2, '0')}/${dateOfJoining!.month.toString().padLeft(2, '0')}/${dateOfJoining!.year}';
  }

  String get formattedGender {
    switch (gender.toUpperCase()) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      case 'OTHER':
        return 'Other';
      default:
        return gender;
    }
  }

  String get formattedStatus {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Active';
      case 'INACTIVE':
        return 'Inactive';
      case 'SUSPENDED':
        return 'Suspended';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.red;
      case 'SUSPENDED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
} 