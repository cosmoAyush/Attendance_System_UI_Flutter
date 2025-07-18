import 'package:attendance_system_hris/models/attendance_record.dart';

class AttendanceSummary {
  final String? checkInTime;
  final String? checkOutTime;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final List<AttendanceRecord>? recentActivities;

  const AttendanceSummary({
    this.checkInTime,
    this.checkOutTime,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    this.recentActivities,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      presentDays: json['presentDays'] ?? 0,
      absentDays: json['absentDays'] ?? 0,
      lateDays: json['lateDays'] ?? 0,
      recentActivities: json['recentActivities'] != null
          ? (json['recentActivities'] as List)
              .map((activity) => AttendanceRecord.fromJson(activity))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'lateDays': lateDays,
      'recentActivities': recentActivities?.map((activity) => activity.toJson()).toList(),
    };
  }

  AttendanceSummary copyWith({
    String? checkInTime,
    String? checkOutTime,
    int? presentDays,
    int? absentDays,
    int? lateDays,
    List<AttendanceRecord>? recentActivities,
  }) {
    return AttendanceSummary(
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      presentDays: presentDays ?? this.presentDays,
      absentDays: absentDays ?? this.absentDays,
      lateDays: lateDays ?? this.lateDays,
      recentActivities: recentActivities ?? this.recentActivities,
    );
  }

  @override
  String toString() {
    return 'AttendanceSummary(checkInTime: $checkInTime, checkOutTime: $checkOutTime, presentDays: $presentDays, absentDays: $absentDays, lateDays: $lateDays, recentActivities: $recentActivities)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AttendanceSummary &&
      other.checkInTime == checkInTime &&
      other.checkOutTime == checkOutTime &&
      other.presentDays == presentDays &&
      other.absentDays == absentDays &&
      other.lateDays == lateDays &&
      other.recentActivities == recentActivities;
  }

  @override
  int get hashCode {
    return checkInTime.hashCode ^
      checkOutTime.hashCode ^
      presentDays.hashCode ^
      absentDays.hashCode ^
      lateDays.hashCode ^
      recentActivities.hashCode;
  }
} 