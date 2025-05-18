import 'dart:io';

final isFlatpak = Platform.environment["FLATPAK_ID"] != null;
final isSnap = Platform.environment.containsKey('SNAP');
const isAur = String.fromEnvironment('BUILD_METHOD') == "aur";
final isWindows = Platform.isWindows;
final isMacos = Platform.isMacOS;
final isLinux = Platform.isLinux;
