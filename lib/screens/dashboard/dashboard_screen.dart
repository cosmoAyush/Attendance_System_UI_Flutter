import 'package:flutter/material.dart';
import 'package:attendance_system_hris/components/common/app_card.dart';
import 'package:attendance_system_hris/components/common/app_button.dart';
import 'package:attendance_system_hris/components/common/app_bottom_navigation.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/core/routes/app_router.dart';
import 'package:attendance_system_hris/services/attendance_service.dart';
import 'package:attendance_system_hris/services/auth_service.dart';
import 'package:attendance_system_hris/services/api/attendance_api_service.dart';
import 'package:attendance_system_hris/services/api/employee_api_service.dart';
import 'package:attendance_system_hris/models/attendance_summary.dart';
import 'package:attendance_system_hris/models/api/employee_models.dart';
import 'package:attendance_system_hris/models/api/attendance_models.dart';
import 'package:attendance_system_hris/core/config/app_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  AttendanceSummary? _summary;
  EmployeeData? _employee;
  AttendanceStatusData? _todayStatus;
  MonthlyOverviewData? _monthlyOverview;
  bool _isLoading = true;
  String? _monthlyOverviewError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _refreshEmployeeData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh employee data when screen comes into focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _forceRefreshDashboard();
      }
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _monthlyOverviewError = null;
      });
      
      // Always fetch fresh employee data from API
      await _loadEmployeeData();
      
      // Load today's attendance status
      await _loadTodayStatus();
      
      // Load monthly overview from API
      await _loadMonthlyOverview();
      
      // Then load attendance summary (if needed)
      final summary = await AttendanceService.getTodaySummary();
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Dashboard: Failed to load dashboard data: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Force refresh all dashboard data including employee details
  Future<void> _forceRefreshDashboard() async {
    try {
      print('🔄 Dashboard: Force refreshing all dashboard data');
      setState(() {
        _isLoading = true;
        _monthlyOverviewError = null;
      });
      
      // Clear any cached data and force fresh API calls
      _employee = null;
      _todayStatus = null;
      _summary = null;
      _monthlyOverview = null;
      
      // Fetch fresh employee data
      await _loadEmployeeData();
      
      // Load today's attendance status
      await _loadTodayStatus();
      
      // Load monthly overview from API
      await _loadMonthlyOverview();
      
      // Load attendance summary
      final summary = await AttendanceService.getTodaySummary();
      
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
      
      print('✅ Dashboard: Force refresh completed successfully');
    } catch (e) {
      print('❌ Dashboard: Failed to force refresh dashboard data: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEmployeeData() async {
    try {
      print('🔄 Dashboard: Fetching fresh employee data from API');
      
      // Use getAuthenticatedEmployee endpoint for fresh data
      final response = await EmployeeApiService.getAuthenticatedEmployee();
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _employee = response.data;
        });
        
        // Update the cached data in AuthService as well
        AuthService.currentEmployee = response.data;
        
        print('✅ Dashboard: Fresh employee data loaded successfully');
        print('   Name: ${response.data!.fullName}');
        print('   Email: ${response.data!.email}');
        print('   Position: ${response.data!.position}');
        print('   Department: ${response.data!.department}');
        print('   Image URL: ${response.data!.imageUrl}');
      } else {
        print('⚠️ Dashboard: Failed to get employee data from API');
        // Fallback to cached data if API fails
        final cachedEmployee = AuthService.currentEmployee;
        if (cachedEmployee != null) {
          setState(() {
            _employee = cachedEmployee;
          });
          print('⚠️ Dashboard: Using cached employee data as fallback');
        }
      }
    } catch (e) {
      print('❌ Dashboard: Failed to load employee data: ${e.toString()}');
      // Fallback to cached data if API fails
      final cachedEmployee = AuthService.currentEmployee;
      if (cachedEmployee != null) {
        setState(() {
          _employee = cachedEmployee;
        });
        print('⚠️ Dashboard: Using cached employee data as fallback');
      }
    }
  }

  Future<void> _loadTodayStatus() async {
    try {
      print('📅 Dashboard: Loading today\'s attendance status');
      final response = await AttendanceApiService.getTodayStatus();
      
      setState(() {
        _todayStatus = response.data;
      });
      
      if (response.isSuccess && response.data != null) {
        print('✅ Dashboard: Today\'s status loaded successfully');
        print('   Status: ${response.data!.status}');
        print('   Check In: ${response.data!.formattedCheckInTime}');
        print('   Check Out: ${response.data!.formattedCheckOutTime}');
      } else if (response.isNotMarkedToday) {
        print('ℹ️ Dashboard: Not marked attendance for today yet');
      }
    } catch (e) {
      print('❌ Dashboard: Failed to load today\'s status: ${e.toString()}');
    }
  }

  Future<void> _loadMonthlyOverview() async {
    try {
      print('📊 Dashboard: Loading monthly overview from API');
      final response = await AttendanceApiService.getMonthlyOverview();
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _monthlyOverview = response.data;
          _monthlyOverviewError = null;
        });
        
        print('✅ Dashboard: Monthly overview loaded successfully');
        print('   Present Days: ${response.data!.presentDay}');
        print('   Absent Days: ${response.data!.absentDay}');
        print('   Leave Days: ${response.data!.leaveDay}');
      } else {
        print('❌ Dashboard: Failed to load monthly overview - API returned error');
        setState(() {
          _monthlyOverviewError = response.message;
        });
      }
    } catch (e) {
      print('❌ Dashboard: Failed to load monthly overview: ${e.toString()}');
      setState(() {
        _monthlyOverviewError = 'Failed to load monthly data';
      });
    }
  }

  Future<void> _refreshEmployeeData() async {
    try {
      print('🔄 Dashboard: Refreshing employee data from API');
      final response = await EmployeeApiService.getAuthenticatedEmployee();
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _employee = response.data;
        });
        
        // Update the cached data in AuthService as well
        AuthService.currentEmployee = response.data;
        
        print('✅ Dashboard: Employee data refreshed successfully');
        print('   Name: ${response.data!.fullName}');
        print('   Image URL: ${response.data!.imageUrl}');
      } else {
        print('⚠️ Dashboard: Failed to refresh employee data from API');
      }
    } catch (e) {
      print('❌ Dashboard: Failed to refresh employee data: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _forceRefreshDashboard,
            tooltip: 'Refresh Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _forceRefreshDashboard,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Today's Status
                    _buildTodayStatus(),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    _buildQuickActions(),
                    
                    const SizedBox(height: 24),
                    
                    // Statistics
                    _buildStatistics(),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Activity
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AppBottomNavigationWithRoutes(currentIndex: 0),
    );
  }

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    
    // Get employee data - use fullName for actual name display
    final employeeName = _employee?.fullName.isNotEmpty == true 
        ? _employee!.fullName 
        : (_employee?.email.isNotEmpty == true ? _employee!.email : 'Employee');
    final employeePosition = _employee?.position.isNotEmpty == true 
        ? _employee!.position 
        : 'Employee';
    final employeeDepartment = _employee?.department ?? '';
    final employeeImageUrl = _employee?.imageUrl;
    
    final hasImage = employeeImageUrl != null && employeeImageUrl.isNotEmpty;
    final imageProvider = hasImage 
        ? NetworkImage('${AppConfig.baseUrl}${employeeImageUrl!.startsWith('/') ? '' : '/'}$employeeImageUrl')
        : null;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Employee Avatar with correct error handling
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: imageProvider,
                onBackgroundImageError: hasImage
                    ? (exception, stackTrace) {
                        print('❌ Dashboard: Failed to load employee image: $exception');
                      }
                    : null,
                child: !hasImage
                    ? const Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                        size: 30,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: AppTheme.headingSmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employeeName,
                      style: AppTheme.bodyLarge.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      employeePosition,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (employeeDepartment.isNotEmpty)
                      Text(
                        employeeDepartment,
                        style: AppTheme.bodySmall.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Today is ${_formatDate(now)}',
            style: AppTheme.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatus() {
    final theme = Theme.of(context);
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
            title: "Today's Status",
            subtitle: "Your attendance for today",
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
                  child: _buildStatusItem(
                    icon: Icons.login,
                    title: 'Check In',
                    time: _todayStatus?.formattedCheckInTime ?? 'Not checked in',
                    color: _todayStatus?.isCheckedIn == true 
                        ? AppTheme.successColor 
                        : AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.logout,
                    title: 'Check Out',
                    time: _todayStatus?.formattedCheckOutTime ?? 'Not checked out',
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

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String time,
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
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCardHeader(
            title: 'Quick Actions',
            subtitle: 'Manage your attendance',
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Request Leave',
                        onPressed: () => AppRouter.navigateTo(context, AppRouter.requestLeave),
                        variant: ButtonVariant.secondary,
                        icon: Icons.event_note,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'View Report',
                        onPressed: () => AppRouter.navigateTo(context, AppRouter.report),
                        variant: ButtonVariant.outline,
                        icon: Icons.assessment,
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

  Widget _buildStatistics() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCardHeader(
            title: 'This Month',
            subtitle: 'Your attendance statistics',
          ),
          AppCardContent(
            child: _monthlyOverviewError != null
                ? _buildErrorState()
                : _buildStatisticsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          color: AppTheme.errorColor,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'Failed to load monthly data',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.errorColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _monthlyOverviewError ?? 'Unknown error',
          style: AppTheme.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        AppButton(
          text: 'Retry',
          onPressed: _loadMonthlyOverview,
          variant: ButtonVariant.outline,
          icon: Icons.refresh,
        ),
      ],
    );
  }

  Widget _buildStatisticsContent() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            title: 'Present',
            value: '${_monthlyOverview?.presentDay ?? 0}',
            color: AppTheme.successColor,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            title: 'Absent',
            value: '${_monthlyOverview?.absentDay ?? 0}',
            color: AppTheme.errorColor,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            title: 'Leave',
            value: '${_monthlyOverview?.leaveDay ?? 0}',
            color: AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              value,
              style: AppTheme.headingSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTheme.bodySmall.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCardHeader(
            title: 'Recent Activity',
            subtitle: 'Your latest attendance records',
            trailing: TextButton(
              onPressed: () => AppRouter.navigateTo(context, AppRouter.attendanceList),
              child: const Text('View All'),
            ),
          ),
          AppCardContent(
            child: _summary?.recentActivities?.isNotEmpty == true
                ? Column(
                    children: _summary!.recentActivities!
                        .take(3)
                        .map((activity) => _buildActivityItem(activity))
                        .toList(),
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No recent activity'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(dynamic activity) {
    // TODO: Implement activity item widget
    return const ListTile(
      leading: Icon(Icons.access_time),
      title: Text('Check In'),
      subtitle: Text('Today at 9:00 AM'),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
} 