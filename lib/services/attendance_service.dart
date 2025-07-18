import 'package:attendance_system_hris/models/attendance_summary.dart';
import 'package:attendance_system_hris/models/attendance_record.dart';

class AttendanceService {
  // Mock data - replace with actual API calls
  static final List<AttendanceRecord> _mockRecords = [
    AttendanceRecord(
      id: '1',
      date: DateTime.now(),
      checkInTime: '09:00',
      checkOutTime: '17:00',
      status: AttendanceStatus.present,
      location: 'Office',
      notes: '',
    ),
    AttendanceRecord(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 1)),
      checkInTime: '08:45',
      checkOutTime: '17:30',
      status: AttendanceStatus.present,
      location: 'Office',
      notes: '',
    ),
    AttendanceRecord(
      id: '3',
      date: DateTime.now().subtract(const Duration(days: 2)),
      checkInTime: '09:15',
      checkOutTime: '17:00',
      status: AttendanceStatus.late,
      location: 'Office',
      notes: 'Traffic delay',
    ),
  ];

  // Get today's attendance summary
  static Future<AttendanceSummary> getTodaySummary() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
    
    final today = DateTime.now();
    final todayRecord = _mockRecords.firstWhere(
      (record) => record.date.day == today.day && 
                   record.date.month == today.month && 
                   record.date.year == today.year,
      orElse: () => AttendanceRecord(
        id: '0',
        date: today,
        checkInTime: null,
        checkOutTime: null,
        status: AttendanceStatus.absent,
        location: '',
        notes: '',
      ),
    );

    return AttendanceSummary(
      checkInTime: todayRecord.checkInTime,
      checkOutTime: todayRecord.checkOutTime,
      presentDays: 15,
      absentDays: 2,
      lateDays: 3,
      recentActivities: _mockRecords.take(5).toList(),
    );
  }

  // Check in
  static Future<bool> checkIn({
    required String location,
    String? notes,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
    
    final now = DateTime.now();
    final checkInTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Add new record
    _mockRecords.insert(0, AttendanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: now,
      checkInTime: checkInTime,
      checkOutTime: null,
      status: AttendanceStatus.present,
      location: location,
      notes: notes ?? '',
    ));
    
    return true;
  }

  // Check out
  static Future<bool> checkOut({
    String? notes,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
    
    final now = DateTime.now();
    final checkOutTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Update today's record
    final today = DateTime.now();
    final todayIndex = _mockRecords.indexWhere(
      (record) => record.date.day == today.day && 
                   record.date.month == today.month && 
                   record.date.year == today.year,
    );
    
    if (todayIndex != -1) {
      _mockRecords[todayIndex] = _mockRecords[todayIndex].copyWith(
        checkOutTime: checkOutTime,
        notes: notes ?? _mockRecords[todayIndex].notes,
      );
    }
    
    return true;
  }

  // Get attendance records for a date range
  static Future<List<AttendanceRecord>> getAttendanceRecords({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
    
    if (startDate == null && endDate == null) {
      return List.from(_mockRecords);
    }
    
    return _mockRecords.where((record) {
      if (startDate != null && record.date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && record.date.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  // Request attendance correction
  static Future<bool> requestAttendanceCorrection({
    required String date,
    required String reason,
    required String requestedTime,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay
    return true;
  }

  // Get monthly statistics
  static Future<Map<String, int>> getMonthlyStatistics(int year, int month) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
    
    return {
      'present': 15,
      'absent': 2,
      'late': 3,
      'leave': 1,
    };
  }
} 