import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dedicated service to coordinate OS notification permission requests.
///
/// Keeps permission logic completely isolated from business state (AppState).
class NotificationPermissionService {
  static const String _kPrefInitialPromptAttempted =
      'hasPromptedInitialNotificationPermission';

  static final NotificationPermissionService _instance =
      NotificationPermissionService._internal();
  factory NotificationPermissionService() => _instance;
  NotificationPermissionService._internal();

  /// Checks if the initial notification permission request has already been attempted.
  Future<bool> hasPromptedInitialPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kPrefInitialPromptAttempted) ?? false;
    } catch (e) {
      debugPrint('Error reading notification permission flag: $e');
      return false;
    }
  }

  /// Marks the initial notification permission request as attempted.
  Future<void> _markInitialPromptAttempted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPrefInitialPromptAttempted, true);
    } catch (e) {
      debugPrint('Error setting notification permission flag: $e');
    }
  }

  /// Marks the initial notification permission request as attempted.
  ///
  /// Call this when the user taps "Not Now" or dismisses the in-app screen
  /// so that they are not prompted again on subsequent launches.
  Future<void> markInitialPromptAttempted() async {
    await _markInitialPromptAttempted();
  }

  /// Checks if the in-app notification permission explanation screen should be shown.
  ///
  /// Returns false if:
  /// - The user has already been prompted previously.
  /// - The permission is already granted or provisional.
  /// - The permission is permanently denied (blocked in OS settings).
  ///
  /// Returns true only when an initial prompt is needed and requestable.
  Future<bool> shouldShowInitialPermissionScreen() async {
    try {
      final alreadyPrompted = await hasPromptedInitialPermission();
      if (alreadyPrompted) {
        return false;
      }

      final status = await Permission.notification.status;
      if (status.isGranted || status.isProvisional || status.isPermanentlyDenied) {
        await _markInitialPromptAttempted();
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error checking if initial notification permission is needed: $e');
      return false;
    }
  }

  /// Prompts the native OS notification permission dialog and records that
  /// an attempt has been made.
  Future<PermissionStatus> requestPermission() async {
    try {
      final status = await Permission.notification.request();
      await _markInitialPromptAttempted();
      return status;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      await _markInitialPromptAttempted();
      return PermissionStatus.denied;
    }
  }

  /// Handles the initial notification permission request on first app open.
  ///
  /// Backward compatible helper; delegates to [shouldShowInitialPermissionScreen]
  /// and [requestPermission].
  Future<void> requestInitialPermissionIfNeeded() async {
    try {
      final shouldShow = await shouldShowInitialPermissionScreen();
      if (!shouldShow) return;
      await requestPermission();
    } catch (e) {
      debugPrint('Error during initial notification permission request: $e');
    }
  }

  /// Handles notification permission request after a successful order placement.
  ///
  /// If the user previously denied permission and the OS still permits
  /// requesting it, displays the native prompt. Does nothing if already
  /// granted or permanently denied.
  Future<void> requestPostOrderPermissionIfNeeded() async {
    try {
      final status = await Permission.notification.status;

      // If already granted, provisional, or permanently blocked in settings, do nothing
      if (status.isGranted || status.isProvisional || status.isPermanentlyDenied) {
        return;
      }

      // If status is denied and the OS allows another request, prompt the native dialog
      if (status.isDenied) {
        await Permission.notification.request();
        await _markInitialPromptAttempted();
      }
    } catch (e) {
      debugPrint('Error during post-order notification permission request: $e');
    }
  }
}
