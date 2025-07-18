import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      // First check if the plugin is available
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        print('🔐 BiometricService: Device not supported for biometric authentication');
        return false;
      }

      final isAvailable = await _localAuth.canCheckBiometrics;
      
      print('🔐 BiometricService: Biometric available: $isAvailable');
      print('🔐 BiometricService: Device supported: $isDeviceSupported');
      
      return isAvailable && isDeviceSupported;
    } on PlatformException catch (e) {
      print('❌ BiometricService: PlatformException: ${e.message}');
      print('❌ BiometricService: Error code: ${e.code}');
      return false;
    } catch (e) {
      print('❌ BiometricService: Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      print('🔐 BiometricService: Available biometrics: $availableBiometrics');
      return availableBiometrics;
    } on PlatformException catch (e) {
      print('❌ BiometricService: PlatformException getting biometrics: ${e.message}');
      print('❌ BiometricService: Error code: ${e.code}');
      return [];
    } catch (e) {
      print('❌ BiometricService: Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if any biometric authentication is available
  static Future<bool> isAnyBiometricAvailable() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      final hasAnyBiometric = availableBiometrics.isNotEmpty;
      
      print('🔐 BiometricService: Any biometric available: $hasAnyBiometric');
      print('🔐 BiometricService: Available types: $availableBiometrics');
      return hasAnyBiometric;
    } catch (e) {
      print('❌ BiometricService: Error checking any biometric availability: $e');
      return false;
    }
  }

  /// Check if fingerprint is available
  static Future<bool> isFingerprintAvailable() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      final hasFingerprint = availableBiometrics.contains(BiometricType.fingerprint);
      
      print('🔐 BiometricService: Fingerprint available: $hasFingerprint');
      return hasFingerprint;
    } catch (e) {
      print('❌ BiometricService: Error checking fingerprint availability: $e');
      return false;
    }
  }

  /// Get the best available biometric type for authentication
  static Future<BiometricType?> getBestAvailableBiometric() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      
      // Priority order: fingerprint > face > iris > strong > weak
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      } else if (availableBiometrics.contains(BiometricType.face)) {
        return BiometricType.face;
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return BiometricType.iris;
      } else if (availableBiometrics.contains(BiometricType.strong)) {
        return BiometricType.strong;
      } else if (availableBiometrics.contains(BiometricType.weak)) {
        return BiometricType.weak;
      }
      
      return null;
    } catch (e) {
      print('❌ BiometricService: Error getting best biometric: $e');
      return null;
    }
  }

  /// Get user-friendly name for biometric type
  static String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
      default:
        return 'Biometric';
    }
  }

  /// Authenticate using biometrics
  static Future<bool> authenticateWithBiometrics({
    String reason = 'Please authenticate to continue',
    String cancelLabel = 'Cancel',
    String disableLabel = 'Disable',
  }) async {
    try {
      print('🔐 BiometricService: Starting biometric authentication');
      
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print('❌ BiometricService: Biometric authentication not available');
        return false;
      }

      final hasAnyBiometric = await isAnyBiometricAvailable();
      if (!hasAnyBiometric) {
        print('❌ BiometricService: No biometrics available');
        return false;
      }

      final bestBiometric = await getBestAvailableBiometric();
      if (bestBiometric == null) {
        print('❌ BiometricService: No suitable biometric found');
        return false;
      }

      print('🔐 BiometricService: Using biometric type: ${getBiometricTypeName(bestBiometric)}');

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      print('🔐 BiometricService: Authentication result: $authenticated');
      return authenticated;
    } on PlatformException catch (e) {
      print('❌ BiometricService: PlatformException during authentication: ${e.message}');
      print('❌ BiometricService: Error code: ${e.code}');
      
      // Handle specific error codes
      switch (e.code) {
        case 'NotAvailable':
          print('❌ BiometricService: Biometric authentication not available on this device');
          break;
        case 'NotEnrolled':
          print('❌ BiometricService: No biometrics enrolled on this device');
          break;
        case 'PasscodeNotSet':
          print('❌ BiometricService: Device passcode not set');
          break;
        case 'LockedOut':
          print('❌ BiometricService: Biometric authentication locked out');
          break;
        case 'PermanentlyLockedOut':
          print('❌ BiometricService: Biometric authentication permanently locked out');
          break;
        default:
          print('❌ BiometricService: Unknown platform error: ${e.code}');
      }
      
      return false;
    } catch (e) {
      print('❌ BiometricService: Error during biometric authentication: $e');
      return false;
    }
  }

  /// Get biometric authentication status
  static Future<BiometricStatus> getBiometricStatus() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricStatus.notAvailable;
      }

      final hasAnyBiometric = await isAnyBiometricAvailable();
      if (!hasAnyBiometric) {
        return BiometricStatus.notEnrolled;
      }

      return BiometricStatus.available;
    } catch (e) {
      print('❌ BiometricService: Error getting biometric status: $e');
      return BiometricStatus.notAvailable;
    }
  }
}

enum BiometricStatus {
  available,
  notAvailable,
  notEnrolled,
} 