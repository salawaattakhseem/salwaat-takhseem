import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Utility class for haptic feedback
/// Silently ignored on web platform
class HapticUtils {
  /// Light tap feedback - for button presses
  static Future<void> lightTap() async {
    if (kIsWeb) return; // Skip on web
    await HapticFeedback.lightImpact();
  }
  
  /// Medium tap feedback - for selections
  static Future<void> mediumTap() async {
    if (kIsWeb) return;
    await HapticFeedback.mediumImpact();
  }
  
  /// Heavy tap feedback - for important actions
  static Future<void> heavyTap() async {
    if (kIsWeb) return;
    await HapticFeedback.heavyImpact();
  }
  
  /// Success feedback - for successful operations
  static Future<void> success() async {
    if (kIsWeb) return;
    await HapticFeedback.mediumImpact();
  }
  
  /// Error/Warning feedback - for errors or destructive actions
  static Future<void> warning() async {
    if (kIsWeb) return;
    await HapticFeedback.heavyImpact();
  }
  
  /// Selection changed feedback
  static Future<void> selectionClick() async {
    if (kIsWeb) return;
    await HapticFeedback.selectionClick();
  }
  
  /// Vibrate feedback - standard vibration
  static Future<void> vibrate() async {
    if (kIsWeb) return;
    await HapticFeedback.vibrate();
  }
}
