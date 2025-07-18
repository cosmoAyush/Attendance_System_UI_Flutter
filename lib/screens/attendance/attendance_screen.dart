import 'package:flutter/material.dart';
import 'package:attendance_system_hris/components/common/app_card.dart';
import 'package:attendance_system_hris/components/common/app_button.dart';
import 'package:attendance_system_hris/components/common/app_bottom_navigation.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/core/routes/app_router.dart';
import 'package:attendance_system_hris/services/api/attendance_api_service.dart';
import 'package:attendance_system_hris/models/api/attendance_models.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  AttendanceStatusData? _todayStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayStatus();
  }

  Future<void> _loadTodayStatus() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      print('📅 Attendance: Loading today\'s attendance status');
      final response = await AttendanceApiService.getTodayStatus();
      
      setState(() {
        _todayStatus = response.data;
        _isLoading = false;
      });
      
      if (response.isSuccess && response.data != null) {
        print('✅ Attendance: Today\'s status loaded successfully');
        print('   Status: ${response.data!.status}');
        print('   Check In: ${response.data!.formattedCheckInTime}');
        print('   Check Out: ${response.data!.formattedCheckOutTime}');
      } else if (response.isNotMarkedToday) {
        print('ℹ️ Attendance: Not marked attendance for today yet');
      }
    } catch (e) {
      print('❌ Attendance: Failed to load today\'s status: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodayStatus,
            tooltip: 'Refresh Attendance Status',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => AppRouter.navigateTo(context, AppRouter.attendanceList),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTodayStatus,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    _buildQuickActions(context),
                    
                    const SizedBox(height: 24),
                    
                    // Today's Summary
                    _buildTodaySummary(context),
                    
                    const SizedBox(height: 24),
                    
                    // Attendance Options
                    _buildAttendanceOptions(context),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AppBottomNavigationWithRoutes(currentIndex: 1),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCardHeader(
            title: 'Quick Actions',
            subtitle: 'Manage your daily attendance',
          ),
          AppCardContent(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Check In',
                        onPressed: _todayStatus?.isCheckedIn != true 
                            ? () => AppRouter.navigateTo(context, AppRouter.checkIn)
                            : null,
                        variant: ButtonVariant.primary,
                        icon: Icons.login,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'Check Out',
                        onPressed: _todayStatus?.isCheckedIn == true && _todayStatus?.isCheckedOut == false
                            ? () => AppRouter.navigateTo(context, AppRouter.checkOut)
                            : null,
                        variant: ButtonVariant.outline,
                        icon: Icons.logout,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    
    // Determine status text and color based on API data
    String statusText = 'Not Marked';
    Color statusColor = AppTheme.warningColor;
    
    if (_todayStatus != null) {
      if (_todayStatus!.status.isNotEmpty) {
        statusText = _todayStatus!.status;
        statusColor = _todayStatus!.isPresent ? AppTheme.successColor : AppTheme.errorColor;
      }
    }
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCardHeader(
            title: "Today's Summary",
            subtitle: "${now.day} ${_getMonthName(now.month)} ${now.year}",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Status: ',
                  style: AppTheme.bodyLarge.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  statusText,
                  style: AppTheme.bodyLarge.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          AppCardContent(
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: Icons.login,
                    title: 'Check In',
                    time: _todayStatus?.formattedCheckInTime ?? 'Not checked in',
                    status: _todayStatus?.isCheckedIn == true ? 'Completed' : 'Pending',
                    color: _todayStatus?.isCheckedIn == true 
                        ? AppTheme.successColor 
                        : AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: Icons.logout,
                    title: 'Check Out',
                    time: _todayStatus?.formattedCheckOutTime ?? 'Not checked out',
                    status: _todayStatus?.isCheckedOut == true ? 'Completed' : 'Pending',
                    color: _todayStatus?.isCheckedOut == true 
                        ? AppTheme.successColor 
                        : AppTheme.warningColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String time,
    required String status,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTheme.labelMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: AppTheme.bodySmall.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceOptions(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCardHeader(
            title: 'Attendance Options',
            subtitle: 'Additional attendance features',
          ),
          AppCardContent(
            child: Column(
              children: [
                _buildOptionTile(
                  context,
                  icon: Icons.history,
                  title: 'Attendance History',
                  subtitle: 'View your past attendance records',
                  onTap: () => AppRouter.navigateTo(context, AppRouter.attendanceList),
                ),
                const Divider(),
                _buildOptionTile(
                  context,
                  icon: Icons.edit_note,
                  title: 'Request Correction',
                  subtitle: 'Request changes to attendance records',
                  onTap: () => AppRouter.navigateTo(context, AppRouter.attendanceRequest),
                ),
                const Divider(),
                _buildOptionTile(
                  context,
                  icon: Icons.location_on,
                  title: 'Location Settings',
                  subtitle: 'Configure attendance location',
                  onTap: () {
                    // TODO: Implement location settings
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodyMedium.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
} 