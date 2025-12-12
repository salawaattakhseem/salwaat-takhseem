import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for biometric authentication
/// Gracefully handles web platform (not supported)
class BiometricService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  /// Check if device supports biometrics
  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false; // Not supported on web
    
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
  
  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return [];
    
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  /// Authenticate user with biometrics
  Future<bool> authenticate({String reason = 'Please authenticate to continue'}) async {
    if (kIsWeb) return true; // Skip on web, return success
    
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/pattern as fallback
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric auth error: ${e.message}');
      return false;
    }
  }
  
  /// Check if biometric login is enabled by user
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Enable or disable biometric login
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, enabled);
    } catch (e) {
      // Ignore errors
    }
  }
  
  /// Get biometric type label for display
  String getBiometricLabel(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometric';
  }
}
