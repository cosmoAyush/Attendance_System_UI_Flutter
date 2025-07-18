enum AttendanceStatus {
  present,
  absent,
  late,
  leave,
  holiday,
}

class AttendanceRecord {
  final String id;
  final DateTime date;
  final String? checkInTime;
  final String? checkOutTime;
  final AttendanceStatus status;
  final String location;
  final String notes;

  const AttendanceRecord({
    required this.id,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.location,
    required this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString() == 'AttendanceStatus.${json['status']}',
        orElse: () => AttendanceStatus.absent,
      ),
      location: json['location'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status.toString().split('.').last,
      'location': location,
      'notes': notes,
    };
  }

  AttendanceRecord copyWith({
    String? id,
    DateTime? date,
    String? checkInTime,
    String? checkOutTime,
    AttendanceStatus? status,
    String? location,
    String? notes,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }

  String get statusText {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.leave:
        return 'Leave';
      case AttendanceStatus.holiday:
        return 'Holiday';
    }
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get dayOfWeek {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  String toString() {
    return 'AttendanceRecord(id: $id, date: $date, checkInTime: $checkInTime, checkOutTime: $checkOutTime, status: $status, location: $location, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AttendanceRecord &&
      other.id == id &&
      other.date == date &&
      other.checkInTime == checkInTime &&
      other.checkOutTime == checkOutTime &&
      other.status == status &&
      other.location == location &&
      other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      date.hashCode ^
      checkInTime.hashCode ^
      checkOutTime.hashCode ^
      status.hashCode ^
      location.hashCode ^
      notes.hashCode;
  }
} 