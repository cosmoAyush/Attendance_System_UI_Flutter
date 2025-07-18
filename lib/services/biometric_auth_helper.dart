import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_system_hris/services/biometric_service.dart';
import 'package:attendance_system_hris/services/auth_service.dart';

class BiometricAuthHelper {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';

  /// Check if biometric authentication is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
      print('🔐 BiometricAuthHelper: Biometric enabled check: $isEnabled');
      return isEnabled;
    } catch (e) {
      print('❌ BiometricAuthHelper: Error checking biometric enabled: $e');
      return false;
    }
  }

  /// Enable biometric authentication
  static Future<bool> enableBiometric({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 BiometricAuthHelper: Enabling biometric for email: $email');
      
      // First check if biometric is available
      final isAvailable = await BiometricService.isBiometricAvailable();
      if (!isAvailable) {
        print('❌ BiometricAuthHelper: Biometric not available');
        return false;
      }

      // Check if any biometric type is available
      final hasAnyBiometric = await BiometricService.isAnyBiometricAvailable();
      if (!hasAnyBiometric) {
        print('❌ BiometricAuthHelper: No biometric types available');
        return false;
      }

      // Get the best available biometric type
      final bestBiometric = await BiometricService.getBestAvailableBiometric();
      if (bestBiometric == null) {
        print('❌ BiometricAuthHelper: No suitable biometric found');
        return false;
      }

      print('🔐 BiometricAuthHelper: Using biometric type: ${BiometricService.getBiometricTypeName(bestBiometric)}');

      // Test biometric authentication
      final authenticated = await BiometricService.authenticateWithBiometrics(
        reason: 'Enable biometric login for your account',
      );

      if (!authenticated) {
        print('❌ BiometricAuthHelper: Biometric authentication failed during setup');
        return false;
      }

      // Save credentials securely
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, true);
      await prefs.setString(_savedEmailKey, email);
      await prefs.setString(_savedPasswordKey, password);

      print('✅ BiometricAuthHelper: Biometric authentication enabled successfully');
      return true;
    } catch (e) {
      print('❌ BiometricAuthHelper: Error enabling biometric: $e');
      return false;
    }
  }

  /// Disable biometric authentication
  static Future<bool> disableBiometric() async {
    try {
      print('🔐 BiometricAuthHelper: Disabling biometric authentication');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, false);
      await prefs.remove(_savedEmailKey);
      await prefs.remove(_savedPasswordKey);

      print('✅ BiometricAuthHelper: Biometric authentication disabled successfully');
      return true;
    } catch (e) {
      print('❌ BiometricAuthHelper: Error disabling biometric: $e');
      return false;
    }
  }

  /// Authenticate using biometrics and login
  static Future<bool> authenticateWithBiometrics() async {
    try {
      print('🔐 BiometricAuthHelper: Starting biometric authentication and login');

      // Check if biometric is enabled
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        print('❌ BiometricAuthHelper: Biometric not enabled');
        return false;
      }

      // Check if biometric is available
      final isAvailable = await BiometricService.isBiometricAvailable();
      if (!isAvailable) {
        print('❌ BiometricAuthHelper: Biometric not available');
        return false;
      }

      // Check if any biometric type is available
      final hasAnyBiometric = await BiometricService.isAnyBiometricAvailable();
      if (!hasAnyBiometric) {
        print('❌ BiometricAuthHelper: No biometric types available');
        return false;
      }

      // Get the best available biometric type
      final bestBiometric = await BiometricService.getBestAvailableBiometric();
      if (bestBiometric == null) {
        print('❌ BiometricAuthHelper: No suitable biometric found');
        return false;
      }

      print('🔐 BiometricAuthHelper: Using biometric type: ${BiometricService.getBiometricTypeName(bestBiometric)}');

      // Authenticate with biometrics
      final authenticated = await BiometricService.authenticateWithBiometrics(
        reason: 'Login to your account',
      );

      if (!authenticated) {
        print('❌ BiometricAuthHelper: Biometric authentication failed');
        return false;
      }

      // Get saved credentials
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_savedEmailKey);
      final password = prefs.getString(_savedPasswordKey);

      if (email == null || password == null) {
        print('❌ BiometricAuthHelper: Saved credentials not found');
        return false;
      }

      print('🔐 BiometricAuthHelper: Logging in with saved credentials for: $email');
      
      // Login with saved credentials
      final loginSuccess = await AuthService.login(
        email: email,
        password: password,
      );

      if (loginSuccess) {
        print('✅ BiometricAuthHelper: Login successful via biometric');
      } else {
        print('❌ BiometricAuthHelper: Login failed with saved credentials');
      }

      return loginSuccess;
    } catch (e) {
      print('❌ BiometricAuthHelper: Error during biometric authentication: $e');
      return false;
    }
  }

  /// Get saved email for display
  static Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_savedEmailKey);
      print('🔐 BiometricAuthHelper: Retrieved saved email: $email');
      return email;
    } catch (e) {
      print('❌ BiometricAuthHelper: Error getting saved email: $e');
      return null;
    }
  }

  /// Check if biometric authentication is ready to use
  static Future<bool> isBiometricReady() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        print('🔐 BiometricAuthHelper: Biometric not enabled');
        return false;
      }

      final isAvailable = await BiometricService.isBiometricAvailable();
      if (!isAvailable) {
        print('🔐 BiometricAuthHelper: Biometric not available');
        return false;
      }

      final hasAnyBiometric = await BiometricService.isAnyBiometricAvailable();
      if (!hasAnyBiometric) {
        print('🔐 BiometricAuthHelper: No biometric types available');
        return false;
      }

      final savedEmail = await getSavedEmail();
      final isReady = savedEmail != null;
      print('🔐 BiometricAuthHelper: Biometric ready: $isReady');
      return isReady;
    } catch (e) {
      print('❌ BiometricAuthHelper: Error checking biometric ready: $e');
      return false;
    }
  }

  /// Get the current biometric type being used
  static Future<String?> getCurrentBiometricType() async {
    try {
      final bestBiometric = await BiometricService.getBestAvailableBiometric();
      if (bestBiometric != null) {
        return BiometricService.getBiometricTypeName(bestBiometric);
      }
      return null;
    } catch (e) {
      print('❌ BiometricAuthHelper: Error getting current biometric type: $e');
      return null;
    }
  }

  /// Clear all biometric data (for testing/debugging)
  static Future<void> clearBiometricData() async {
    try {
      print('🔐 BiometricAuthHelper: Clearing all biometric data');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_biometricEnabledKey);
      await prefs.remove(_savedEmailKey);
      await prefs.remove(_savedPasswordKey);
      print('✅ BiometricAuthHelper: Biometric data cleared');
    } catch (e) {
      print('❌ BiometricAuthHelper: Error clearing biometric data: $e');
    }
  }
} 