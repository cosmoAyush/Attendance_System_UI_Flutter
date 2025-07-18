import 'package:flutter/material.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/services/api/attendance_api_service.dart';
import 'package:attendance_system_hris/models/api/attendance_models.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  List<AttendanceHistoryData> _attendanceRecords = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('📊 AttendanceList: Loading attendance history');
      final response = await AttendanceApiService.getAllAttendance();

      setState(() {
        _attendanceRecords = response.data;
        _isLoading = false;
      });

      print('✅ AttendanceList: Loaded ${_attendanceRecords.length} attendance records');
    } catch (e) {
      print('❌ AttendanceList: Failed to load attendance history: ${e.toString()}');
      setState(() {
        _errorMessage = 'Failed to load attendance history: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendanceHistory,
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _attendanceRecords.isEmpty
                  ? _buildEmptyWidget()
                  : _buildAttendanceList(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading History',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAttendanceHistory,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Attendance Records',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your attendance history will appear here',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return RefreshIndicator(
      onRefresh: _loadAttendanceHistory,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _attendanceRecords.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final record = _attendanceRecords[index];
          return _buildAttendanceCard(record, index);
        },
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceHistoryData record, int index) {
    final theme = Theme.of(context);
    
    // Determine status color
    Color statusColor = AppTheme.warningColor;
    if (record.isPresent) {
      statusColor = AppTheme.successColor;
    } else if (record.isAbsent) {
      statusColor = AppTheme.errorColor;
    } else if (record.isLeave) {
      statusColor = AppTheme.infoColor;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with date and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date and day
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.formattedDate,
                      style: AppTheme.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      record.dayName,
                      style: AppTheme.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    record.status,
                    style: AppTheme.labelMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Compact check-in and check-out times
            Row(
              children: [
                Expanded(
                  child: _buildCompactTimeItem(
                    icon: Icons.login,
                    title: 'Check In',
                    time: record.formattedCheckInTime,
                    color: record.isCheckedIn ? AppTheme.successColor : AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactTimeItem(
                    icon: Icons.logout,
                    title: 'Check Out',
                    time: record.formattedCheckOutTime,
                    color: record.isCheckedOut ? AppTheme.successColor : AppTheme.warningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTimeItem({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: AppTheme.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 