import 'package:brisk/provider/settings_provider.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsSideMenuItem extends StatefulWidget {
  final int tabId;
  final String title;
  final IconData icon;

  const SettingsSideMenuItem({
    super.key,
    required this.tabId,
    required this.title,
    required this.icon,
  });

  @override
  State<SettingsSideMenuItem> createState() => _SettingsSideMenuItemState();
}

class _SettingsSideMenuItemState extends State<SettingsSideMenuItem> {
  late SettingsProvider provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<SettingsProvider>(context);
    final sideMenuTheme = Provider.of<ThemeProvider>(context)
        .activeTheme
        .settingTheme
        .sideMenuTheme;

    final size = MediaQuery.of(context).size;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: sideMenuTheme.inactiveTabHoverBackgroundColor,
        onTap: () => provider.setSelectedSettingsTab(widget.tabId),
        child: Container(
          height: 40,
          width: minimizedSideMenu(size) ? 45 : 120,
          decoration: BoxDecoration(
            color: isTabSelected
                ? sideMenuTheme.activeTabBackgroundColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: minimizedSideMenu(size)
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: minimizedSideMenu(size) ? 0 : 10),
              Icon(
                widget.icon,
                color: isTabSelected
                    ? sideMenuTheme.activeTabIconColor
                    : sideMenuTheme.inactiveTabIconColor,
              ),
              SizedBox(width: minimizedSideMenu(size) ? 0 : 5),
              minimizedSideMenu(size)
                  ? Container()
                  : Text(widget.title,
                      style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  bool get isTabSelected => provider.selectedTabId == widget.tabId;

  bool minimizedSideMenu(Size size) => size.width < 1400;
}
