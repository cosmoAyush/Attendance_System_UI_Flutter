import 'package:flutter/material.dart';
import 'package:attendance_system_hris/components/common/app_button.dart';
import 'package:attendance_system_hris/components/common/app_input.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/services/api/attendance_api_service.dart';
import 'package:attendance_system_hris/models/api/attendance_models.dart';

class AttendanceRequestScreen extends StatefulWidget {
  const AttendanceRequestScreen({super.key});

  @override
  State<AttendanceRequestScreen> createState() => _AttendanceRequestScreenState();
}

class _AttendanceRequestScreenState extends State<AttendanceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _reasonController = TextEditingController();
  
  String _selectedRequestType = 'CHECK-IN';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  final List<String> _requestTypes = [
    'CHECK-IN',
    'CHECK-OUT',
  ];

  @override
  void initState() {
    super.initState();
    // Set default date to today
    _selectedDate = DateTime.now();
    _dateController.text = _formatDate(_selectedDate!);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _formatTime(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select both date and time'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('📝 AttendanceRequest: Submitting attendance correction request');
      
      // Create the request data
      final requestData = AttendanceRequestData(
        requestedType: _selectedRequestType,
        requestedTime: _formatTime(_selectedTime!),
        reason: _reasonController.text.trim(),
        attendanceDate: _selectedDate!,
      );

      // Call the API
      final response = await AttendanceApiService.createAttendanceRequest(requestData);

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
        } else if (response.isOnLeave) {
          // On leave error case
          _showErrorDialog(
            'Cannot Submit Request',
            response.message,
            'You are currently on leave status and cannot submit attendance correction requests.',
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
      print('❌ AttendanceRequest: Failed to submit request: ${e.toString()}');
      
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Request Correction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Request Type Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedRequestType,
                  decoration: const InputDecoration(
                    labelText: 'Request Type',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                  items: _requestTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRequestType = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Request type is required';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Date Picker
              AppInput(
                label: 'Attendance Date',
                hint: 'Select date',
                controller: _dateController,
                readOnly: true,
                prefixIcon: const Icon(Icons.calendar_today),
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Date is required';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Time Picker
              AppInput(
                label: 'Requested Time',
                hint: 'Select time',
                controller: _timeController,
                readOnly: true,
                prefixIcon: const Icon(Icons.access_time),
                onTap: _selectTime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Time is required';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Reason Text Area
              AppInput(
                label: 'Reason for Correction',
                hint: 'Please explain why you need this correction...',
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
                text: 'Submit Request',
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