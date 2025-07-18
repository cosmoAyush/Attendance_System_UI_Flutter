import 'package:flutter/material.dart';
import 'package:attendance_system_hris/components/common/app_bottom_navigation.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/services/api/attendance_api_service.dart';
import 'package:attendance_system_hris/models/api/attendance_models.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<MonthlyAttendanceRecord> _monthlyRecords = [];
  DateTime _selectedDate = DateTime.now();
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    // Set to current month by default
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _fetchMonthlyAttendance();
    }
  }

  Future<void> _fetchMonthlyAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasData = false;
    });

    try {
      print('DEBUG: Fetching monthly attendance for ${_selectedDate.year}-${_selectedDate.month}');
      final request = MonthlyAttendanceRequest(
        year: _selectedDate.year,
        month: _selectedDate.month,
      );
      
      final response = await AttendanceApiService.getMonthlyAttendance(request);
      print('DEBUG: Monthly attendance fetched: ${response.data.length} records');
      
      setState(() {
        _monthlyRecords = response.data;
        _isLoading = false;
        _hasData = true;
      });
    } catch (e) {
      print('DEBUG: Error fetching monthly attendance: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load monthly attendance: $e';
        _hasData = false;
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Monthly Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMonthlyAttendance,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(context),
            const SizedBox(height: 24),
            _buildMonthlyReport(context),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationWithRoutes(currentIndex: 3),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Select Month & Year',
                  style: AppTheme.headingSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchMonthlyAttendance,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.search),
                label: Text(_isLoading ? 'Loading...' : 'Generate Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyReport(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_errorMessage != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error Loading Report',
                style: AppTheme.headingSmall.copyWith(color: AppTheme.errorColor),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasData) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.assessment_outlined,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Monthly Attendance Report',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Select a month and year above to generate your attendance report',
                style: AppTheme.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_monthlyRecords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Records Found',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'No attendance records found for ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                style: AppTheme.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assessment, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Monthly Report - ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                      style: AppTheme.headingSmall,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_monthlyRecords.length} records',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _monthlyRecords.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final record = _monthlyRecords[index];
            return _buildAttendanceCard(record, theme);
          },
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(MonthlyAttendanceRecord record, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    Text(
                      record.formattedDate,
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${record.dayName})',
                      style: AppTheme.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: record.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: record.statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    record.status,
                    style: AppTheme.labelMedium.copyWith(
                      color: record.statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.login, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                          const SizedBox(width: 6),
                          Text('Check In', style: AppTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.formattedCheckInTime,
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.logout, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                          const SizedBox(width: 6),
                          Text('Check Out', style: AppTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.formattedCheckOutTime,
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 