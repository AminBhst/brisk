import 'package:flutter/foundation.dart'
    show kIsWeb, TargetPlatform, defaultTargetPlatform;

final _isAndroid = defaultTargetPlatform == TargetPlatform.android;
final _isIOS = defaultTargetPlatform == TargetPlatform.iOS;
final _isFuchsia = defaultTargetPlatform == TargetPlatform.fuchsia;
final _isWindows = defaultTargetPlatform == TargetPlatform.windows;
final _isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
final _isLinux = defaultTargetPlatform == TargetPlatform.linux;

final _isMobileWeb = kIsWeb && (_isAndroid || _isIOS || _isFuchsia);
final _isDesktopWeb = kIsWeb && (_isWindows || _isMacOS || _isLinux);
final _isMobileApp = !kIsWeb && (_isAndroid || _isIOS || _isFuchsia);
final _isDesktopApp = !kIsWeb && (_isWindows || _isMacOS || _isLinux);
final _isMobile = _isMobileWeb || _isMobileApp;
final _isDesktop = _isDesktopWeb || _isDesktopApp;

/// This is a helper class for implementing code that only runs on a specific platform.
class PlatformHelper {
  static const bool isWeb = kIsWeb;

  static final bool isMobile = _isMobile;

  static final bool isDesktop = _isDesktop;

  static final bool isMobileWeb = _isMobileWeb;

  static final bool isDesktopWeb = _isDesktopWeb;

  static final bool isMobileApp = _isMobileApp;

  static final bool isDesktopApp = _isDesktopApp;

  static T? onWeb<T>(T Function() callback) {
    return _executeOrNull<T>(isWeb, callback);
  }

  static T? onMobile<T>(T Function() callback) {
    return _executeOrNull<T>(isMobile, callback);
  }

  static T? onDesktop<T>(T Function() callback) {
    return _executeOrNull<T>(isDesktop, callback);
  }

  static T? onMobileWeb<T>(T Function() callback) {
    return _executeOrNull<T>(isMobileWeb, callback);
  }

  static T? onMobileApp<T>(T Function() callback) {
    return _executeOrNull<T>(isMobileApp, callback);
  }

  static T? onDesktopWeb<T>(T Function() callback) {
    return _executeOrNull<T>(isDesktopWeb, callback);
  }

  static T? onDesktopApp<T>(T Function() callback) {
    return _executeOrNull<T>(isDesktopApp, callback);
  }

  static T? _executeOrNull<T>(bool executable, T Function() callback) {
    if (!executable) {
      return null;
    }

    return callback();
  }
}
