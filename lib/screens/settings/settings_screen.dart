import 'package:flutter/material.dart';
import 'package:attendance_system_hris/components/common/app_bottom_navigation.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/core/routes/app_router.dart';
import 'package:attendance_system_hris/core/config/app_config.dart';
import 'package:attendance_system_hris/services/auth_service.dart';
import 'package:attendance_system_hris/services/api/employee_api_service.dart';
import 'package:attendance_system_hris/models/api/employee_models.dart';
import 'dart:async'; // Added for Timer
import 'package:attendance_system_hris/screens/login/login_screen.dart'; // Added for LoginScreen
import 'package:provider/provider.dart';
import '../../../theme_notifier.dart';
import 'package:attendance_system_hris/screens/settings/theme_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  EmployeeData? _employee;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    try {
      print('🔧 Settings: Loading employee data for profile picture');
      final response = await EmployeeApiService.getAuthenticatedEmployee();
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _employee = response.data;
          _isLoading = false;
        });
        print('✅ Settings: Employee data loaded successfully');
        print('   Name: ${response.data!.fullName}');
        print('   Image URL: ${response.data!.imageUrl}');
      } else {
        print('⚠️ Settings: Failed to get employee data from API');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Settings: Failed to load employee data: ${e.toString()}');
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
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployeeData,
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context),
            const SizedBox(height: 24),
            _buildAccountSettings(context),
            const SizedBox(height: 24),
            _buildAppSettings(context),
            const SizedBox(height: 24),
            _buildLogoutSection(context),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationWithRoutes(currentIndex: 4),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final theme = Theme.of(context);
    final userData = AuthService.getCurrentUserData();
    
    // Get employee data for display
    final employeeName = _employee?.fullName.isNotEmpty == true 
        ? _employee!.fullName 
        : (userData['name'] ?? 'User Name');
    final employeePosition = _employee?.position.isNotEmpty == true 
        ? _employee!.position 
        : (userData['role'] ?? 'Role');
    final employeeImageUrl = _employee?.imageUrl;
    
    final hasImage = employeeImageUrl != null && employeeImageUrl.isNotEmpty;
    final imageProvider = hasImage 
        ? NetworkImage('${AppConfig.baseUrl}${employeeImageUrl!.startsWith('/') ? '' : '/'}$employeeImageUrl')
        : null;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: imageProvider,
                onBackgroundImageError: hasImage
                    ? (exception, stackTrace) {
                        print('❌ Settings: Failed to load profile image: $exception');
                      }
                    : null,
                child: !hasImage
                    ? const Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                        size: 25,
                      )
                    : null,
              ),
              title: Text(
                employeeName,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                employeePosition,
                style: AppTheme.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => AppRouter.navigateTo(context, AppRouter.profile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Settings',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              subtitle: const Text('Update your password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => AppRouter.navigateTo(context, AppRouter.changePassword),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notification preferences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement notifications settings
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettings(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final currentMode = themeNotifier.themeMode;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Settings',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Theme'),
              subtitle: Text(_themeModeLabel(currentMode)),
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement language settings
              },
            ),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System Default';
    }
  }

  void _showThemeBottomSheet(BuildContext context, ThemeNotifier themeNotifier, ThemeMode currentMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.35,
          minChildSize: 0.2,
          maxChildSize: 0.5,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Choose Theme',
                  style: AppTheme.headingSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: currentMode,
                  title: const Text('Light'),
                  onChanged: (mode) {
                    themeNotifier.setThemeMode(mode!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: currentMode,
                  title: const Text('Dark'),
                  onChanged: (mode) {
                    themeNotifier.setThemeMode(mode!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: currentMode,
                  title: const Text('System Default'),
                  onChanged: (mode) {
                    themeNotifier.setThemeMode(mode!);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: AppTheme.errorColor,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppTheme.errorColor),
              ),
              subtitle: const Text('Sign out of your account'),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Close dialog immediately and start logout
              Navigator.pop(context);
              // Use Future.microtask to ensure dialog is closed before logout
              Future.microtask(() => _performSimpleLogout(context));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Instant logout method - navigate first, then cleanup (without biometric)
  void _performSimpleLogout(BuildContext context) async {
    print('🔐 Settings: Starting instant logout process');
    
    // Step 1: Navigate to login page IMMEDIATELY
    print('🔄 Settings: Navigating to login screen immediately');
    
    if (context.mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logging out...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate to login screen immediately
      try {
        print('🔄 Settings: Using MaterialPageRoute navigation');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
        print('✅ Settings: Navigation to login page successful');
      } catch (e) {
        print('❌ Settings: MaterialPageRoute navigation failed: $e');
        
        // Fallback navigation
        try {
          AppRouter.navigateToAndRemoveUntil(context, AppRouter.login);
          print('✅ Settings: AppRouter fallback navigation successful');
        } catch (e2) {
          print('❌ Settings: All navigation methods failed: $e2');
        }
      }
    }
    
    // Step 2: Do cleanup in background (after navigation) - without biometric
    print('🧹 Settings: Starting background cleanup (keeping biometric)');
    
    try {
      // Try API logout with short timeout
      bool apiLogoutSuccess = false;
      try {
        print('🌐 Settings: Attempting API logout in background');
        final logoutResponse = await AuthService.logout().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            print('⚠️ Settings: API logout timeout, using fallback');
            throw Exception('API logout timeout');
          },
        );
        
        if (logoutResponse.isSuccess) {
          print('✅ Settings: API logout successful - ${logoutResponse.message}');
          apiLogoutSuccess = true;
        } else {
          print('⚠️ Settings: API logout failed - ${logoutResponse.message}');
        }
      } catch (e) {
        print('⚠️ Settings: API logout error: $e');
        // Continue with fallback
      }
      
      // If API failed, do simple logout (without biometric)
      if (!apiLogoutSuccess) {
        print('🔄 Settings: Using simple logout fallback');
        
        // Clear all local data (but keep biometric)
        print('🧹 Settings: Clearing session data (keeping biometric)');
        AuthService.clearSession();
        
        // Note: Biometric data is NOT cleared - user can still use biometric login
        print('🔐 Settings: Biometric authentication preserved for next login');
      }
      
      print('✅ Settings: Background cleanup completed successfully (biometric preserved)');
      
    } catch (e) {
      print('❌ Settings: Background cleanup error: $e');
      // Continue anyway - user is already on login page
    }
  }
} 


