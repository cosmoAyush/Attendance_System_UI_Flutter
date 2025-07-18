import 'package:flutter/material.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';

class LeaveListScreen extends StatelessWidget {
  const LeaveListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave History'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Leave History',
              style: AppTheme.headingMedium,
            ),
            SizedBox(height: 8),
            Text(
              'View all your leave requests',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
} 