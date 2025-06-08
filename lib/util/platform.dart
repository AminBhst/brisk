import 'dart:io';
import 'package:flutter/material.dart';

final isFlatpak = Platform.environment["FLATPAK_ID"] != null;
final isSnap = Platform.environment.containsKey('SNAP');
const isAur = String.fromEnvironment('BUILD_METHOD') == "aur";
final isWindows = Platform.isWindows;
final isMacos = Platform.isMacOS;
final isLinux = Platform.isLinux;

bool isDarkMode =
    WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;

bool isLightMode =
    WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.light;


Future<bool> get isLinux_x86_64 async {
  if (!Platform.isLinux) return false;
  final result = await Process.run('uname', ['-m']);
  final arch = result.stdout.toString().trim();
  return arch == 'x86_64';
}

Future<bool> get isLinux_arm64 async {
  if (!Platform.isLinux) return false;
  final result = await Process.run('uname', ['-m']);
  final arch = result.stdout.toString().trim();
  return arch == 'aarch64' || arch == 'arm64';
}
