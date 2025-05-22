import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:preference_list/preference_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PackageInfo? _packageInfo;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _packageInfo = await PackageInfo.fromPlatform();
    _isEnabled = await launchAtStartup.isEnabled();
    setState(() {});
  }

  _handleEnable() async {
    try {
      await launchAtStartup.enable();
    } catch (error) {
      BotToast.showText(text: error.toString());
    }
    await _init();
  }

  _handleDisable() async {
    try {
      await launchAtStartup.disable();
    } catch (error) {
      BotToast.showText(text: error.toString());
    }
    await _init();
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          children: [
            PreferenceListItem(
              title: Text('App name: ${_packageInfo?.appName}'),
            ),
            PreferenceListItem(
              title: Text('App path: ${Platform.resolvedExecutable}'),
            ),
            PreferenceListItem(
              title: Text('Version: ${_packageInfo?.version}'),
            ),
            PreferenceListItem(
              title: Text('Build number: ${_packageInfo?.buildNumber}'),
            ),
          ],
        ),
        PreferenceListSection(
          title: const Text('Methods'),
          children: [
            PreferenceListItem(
              title: const Text('enable'),
              onTap: _handleEnable,
            ),
            PreferenceListItem(
              title: const Text('disable'),
              onTap: _handleDisable,
            ),
            PreferenceListItem(
              title: const Text('isEnabled'),
              accessoryView: Text('$_isEnabled'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: _buildBody(context),
    );
  }
}
