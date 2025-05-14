import 'dart:io';

final isFlatpak = Platform.environment["FLATPAK_ID"] != null;
final isWindows = Platform.isWindows;
final isMacos = Platform.isMacOS;
final isLinux = Platform.isLinux;
