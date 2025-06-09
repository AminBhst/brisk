import 'dart:io';

/// Returns `true` if the app is running in a sandbox, eg. Flatpak or Snap.
bool runningInSandbox() {
  return Platform.environment.containsKey('FLATPAK_ID') ||
      Platform.environment.containsKey('SNAP');
}
