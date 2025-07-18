import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme_notifier.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final currentMode = themeNotifier.themeMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dark_mode_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Choose App Theme',
                  style: AppTheme.headingMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: currentMode,
                    title: const Text('Light'),
                    onChanged: (mode) => themeNotifier.setThemeMode(mode!),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: currentMode,
                    title: const Text('Dark'),
                    onChanged: (mode) => themeNotifier.setThemeMode(mode!),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: currentMode,
                    title: const Text('System Default'),
                    onChanged: (mode) => themeNotifier.setThemeMode(mode!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'You can change the appearance of the app by selecting your preferred theme. "System Default" will follow your device settings.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
} 