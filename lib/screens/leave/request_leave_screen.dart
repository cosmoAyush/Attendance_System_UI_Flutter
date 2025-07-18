import 'package:flutter/material.dart';
import 'package:attendance_system_hris/components/common/app_button.dart';
import 'package:attendance_system_hris/components/common/app_input.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/services/api/leave_api_service.dart';
import 'package:attendance_system_hris/models/api/leave_models.dart';

class RequestLeaveScreen extends StatefulWidget {
  const RequestLeaveScreen({super.key});

  @override
  State<RequestLeaveScreen> createState() => _RequestLeaveScreenState();
}

class _RequestLeaveScreenState extends State<RequestLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _reasonController = TextEditingController();
  
  String _selectedLeaveType = 'Sick Leave';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isLoading = false;

  List<LeavePolicy> _leavePolicies = [];
  bool _isLoadingPolicies = true;
  String? _leaveTypeError;
  int? _availableLeaveCount;
  bool _isLoadingAvailableLeave = false;
  String? _availableLeaveError;
  String? _durationError;

  final List<String> _leaveTypes = [
    'Sick Leave',
    'Casual Leave',
    'Annual Leave',
    'Maternity Leave',
    'Paternity Leave',
    'Bereavement Leave',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchLeavePolicies();
    // Set default start date to today
    _selectedStartDate = DateTime.now();
    _startDateController.text = _formatDate(_selectedStartDate!);
    
    // Set default end date to today
    _selectedEndDate = DateTime.now();
    _endDateController.text = _formatDate(_selectedEndDate!);
  }

  Future<void> _fetchAvailableLeave(String leaveType) async {
    setState(() {
      _isLoadingAvailableLeave = true;
      _availableLeaveError = null;
      _availableLeaveCount = null;
    });
    try {
      final response = await LeaveApiService.getAvailableLeave(leaveType);
      setState(() {
        _availableLeaveCount = response.data?.availableLeaveCount;
        _isLoadingAvailableLeave = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAvailableLeave = false;
        _availableLeaveError = 'Failed to fetch available leave.';
      });
    }
  }

  Future<void> _fetchLeavePolicies() async {
    setState(() {
      _isLoadingPolicies = true;
      _leaveTypeError = null;
    });
    try {
      final response = await LeaveApiService.getLeavePolicies();
      setState(() {
        _leavePolicies = response.data;
        _isLoadingPolicies = false;
        if (_leavePolicies.isNotEmpty) {
          _selectedLeaveType = _leavePolicies.first.leaveType;
        }
      });
      if (response.data.isNotEmpty) {
        _fetchAvailableLeave(response.data.first.leaveType);
      }
    } catch (e) {
      setState(() {
        _isLoadingPolicies = false;
        _leaveTypeError = 'Failed to load leave types. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        _startDateController.text = _formatDate(picked);
        
        // If end date is before start date, update end date
        if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = picked;
          _endDateController.text = _formatDate(picked);
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedStartDate ?? DateTime.now(),
      firstDate: _selectedStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
        _endDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStartDate == null || _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select both start and end dates'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('End date cannot be before start date'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    if (_selectedLeaveType.isEmpty) {
      setState(() {
        _leaveTypeError = 'Leave type is required';
      });
      return;
    }

    final requestedDays = _selectedEndDate!.difference(_selectedStartDate!).inDays + 1;
    if (_availableLeaveCount != null && requestedDays > _availableLeaveCount!) {
      setState(() {
        _durationError = 'Requested leave duration ($requestedDays days) exceeds available leave ($_availableLeaveCount days).';
      });
      return;
    } else {
      setState(() {
        _durationError = null;
      });
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('📅 LeaveRequest: Submitting leave request');
      
      // Create the request data
      final requestData = LeaveRequestData(
        startDate: _selectedStartDate!,
        endDate: _selectedEndDate!,
        leaveType: _selectedLeaveType,
        reason: _reasonController.text.trim(),
      );

      // Call the API
      final response = await LeaveApiService.createLeaveRequest(requestData);

      if (mounted) {
        if (response.isSuccess) {
          // Success case
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          Navigator.pop(context);
        } else if (response.isAttendanceExists) {
          // Attendance exists error case
          _showErrorDialog(
            'Cannot Submit Request',
            response.message,
            'You already have attendance records for the selected date range. Please choose different dates.',
          );
        } else {
          // Other error case
          _showErrorDialog(
            'Request Failed',
            response.message,
            'Please try again or contact support if the issue persists.',
          );
        }
      }
    } catch (e) {
      print('❌ LeaveRequest: Failed to submit request: ${e.toString()}');
      
      if (mounted) {
        _showErrorDialog(
          'Request Failed',
          'An error occurred while submitting your request',
          'Please check your connection and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message, String details) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 8),
              Text(
                details,
                style: AppTheme.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateRangeInfo() {
    if (_selectedStartDate == null || _selectedEndDate == null) {
      return const SizedBox.shrink();
    }

    final days = _selectedEndDate!.difference(_selectedStartDate!).inDays + 1;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Leave duration: $days day${days > 1 ? 's' : ''}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Request Leave'),
      ),
      body: _isLoadingPolicies
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Leave Type Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedLeaveType.isNotEmpty ? _selectedLeaveType : null,
                        decoration: const InputDecoration(
                          labelText: 'Leave Type',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _leavePolicies.map((policy) {
                          return DropdownMenuItem<String>(
                            value: policy.leaveType,
                            child: Text(policy.leaveType),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLeaveType = newValue ?? '';
                            _leaveTypeError = null;
                          });
                          if (newValue != null && newValue.isNotEmpty) {
                            _fetchAvailableLeave(newValue);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Leave type is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_leaveTypeError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _leaveTypeError!,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.errorColor),
                      ),
                    ],
                    // Available Leave Count
                    if (_isLoadingAvailableLeave) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text('Checking available leave...', style: AppTheme.bodySmall),
                        ],
                      ),
                    ] else if (_availableLeaveCount != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppTheme.primaryColor),
                          const SizedBox(width: 6),
                          Text('Available: $_availableLeaveCount', style: AppTheme.bodySmall),
                        ],
                      ),
                    ] else if (_availableLeaveError != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: AppTheme.errorColor),
                          const SizedBox(width: 6),
                          Text(_availableLeaveError!, style: AppTheme.bodySmall.copyWith(color: AppTheme.errorColor)),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Start Date Picker
                    AppInput(
                      label: 'Start Date',
                      hint: 'Select start date',
                      controller: _startDateController,
                      readOnly: true,
                      prefixIcon: const Icon(Icons.calendar_today),
                      onTap: _selectStartDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Start date is required';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // End Date Picker
                    AppInput(
                      label: 'End Date',
                      hint: 'Select end date',
                      controller: _endDateController,
                      readOnly: true,
                      prefixIcon: const Icon(Icons.calendar_today),
                      onTap: _selectEndDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'End date is required';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Date Range Info
                    _buildDateRangeInfo(),
                    if (_durationError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _durationError!,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.errorColor),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Reason Text Area
                    AppInput(
                      label: 'Reason for Leave',
                      hint: 'Please explain the reason for your leave request...',
                      controller: _reasonController,
                      maxLines: 4,
                      prefixIcon: const Icon(Icons.note),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Reason is required';
                        }
                        if (value.length < 10) {
                          return 'Please provide a detailed reason (at least 10 characters)';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    AppButton(
                      text: 'Submit Leave Request',
                      onPressed: _handleSubmit,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      icon: Icons.send,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 