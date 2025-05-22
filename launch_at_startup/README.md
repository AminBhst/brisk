> **🚀 Ship Your App Faster**: Try [Fastforge](https://fastforge.dev) - The simplest way to build, package and distribute your Flutter apps.

# launch_at_startup

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image]

[pub-image]: https://img.shields.io/pub/v/launch_at_startup.svg
[pub-url]: https://pub.dev/packages/launch_at_startup
[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb
[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.launch_at_startup/visits

This plugin allows Flutter desktop apps to Auto launch on startup / login.

---

English | [简体中文](./README-ZH.md)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Platform Support](#platform-support)
- [Quick Start](#quick-start)
  - [Installation](#installation)
  - [Usage](#usage)
- [MacOS Support](#macos-support)
  - [Setup](#setup)
  - [Requirements](#requirements)
  - [Install](#install)
  - [Usage](#usage-1)
- [Who's using it?](#whos-using-it)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | macOS\* | Windows |
| :---: | :-----: | :-----: |
|  ✔️   |   ✔️    |   ✔️    |

> \*Required macOS support installation instructions below

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  launch_at_startup: ^0.5.1
```

Or

```yaml
dependencies:
  launch_at_startup:
    git:
      url: https://github.com/leanflutter/launch_at_startup.git
      ref: main
```

### Usage

```dart
import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
    // Set packageName parameter to support MSIX.
    packageName: 'dev.leanflutter.examples.launchatstartupexample',
  );

  await launchAtStartup.enable();
  await launchAtStartup.disable();
  bool isEnabled = await launchAtStartup.isEnabled();

  runApp(const MyApp());
}

// ...

```

> Please see the example app of this plugin for a full example.

## macOS Support

### Setup

Add platform channel code to your `macos/Runner/MainFlutterWindow.swift` file.

```swift
import Cocoa
import FlutterMacOS
// Add the LaunchAtLogin module
import LaunchAtLogin
//

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Add FlutterMethodChannel platform code
    FlutterMethodChannel(
      name: "launch_at_startup", binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    .setMethodCallHandler { (_ call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "launchAtStartupIsEnabled":
        result(LaunchAtLogin.isEnabled)
      case "launchAtStartupSetEnabled":
        if let arguments = call.arguments as? [String: Any] {
          LaunchAtLogin.isEnabled = arguments["setEnabledValue"] as! Bool
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    //

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}

```

then open your `macos/` folder in Xcode and do the following:

> Instructions referenced from ["LaunchAtLogin" package repository](https://github.com/sindresorhus/LaunchAtLogin). Read for more details and FAQ's.

### Requirements

macOS 10.13+

### Install

Add `https://github.com/sindresorhus/LaunchAtLogin` in the [“Swift Package Manager” tab in Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

### Usage

**Skip this step if your app targets macOS 13 or later.**

Add a new [“Run Script Phase”](http://stackoverflow.com/a/39633955/64949) **below** (not into) “Copy Bundle Resources” in “Build Phases” with the following:

```sh
"${BUILT_PRODUCTS_DIR}/LaunchAtLogin_LaunchAtLogin.bundle/Contents/Resources/copy-helper-swiftpm.sh"
```

And uncheck “Based on dependency analysis”.

The build phase cannot run with "User Script Sandboxing" enabled. With Xcode 15 or newer where it is enabled by default, disable "User Script Sandboxing" in build settings.

_(It needs some extra works to have our script to comply with the build phase sandbox.)_
_(I would name the run script `Copy “Launch at Login Helper”`)_

## Who's using it?

- [Biyi (比译)](https://biyidev.com/) - A convenient translation and dictionary app.

## License

[MIT](./LICENSE)
