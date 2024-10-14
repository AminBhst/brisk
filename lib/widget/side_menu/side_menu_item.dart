import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideMenuItem extends StatelessWidget {
  final VoidCallback onTap;
  final Widget leading;
  final Widget? trailing;
  final String title;
  final bool active;

  const SideMenuItem({
    super.key,
    required this.onTap,
    required this.leading,
    this.trailing = null,
    required this.title,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sideMenuTheme =
        Provider.of<ThemeProvider>(context).activeTheme.sideMenuTheme;
    return Container(
      color:
          active ? sideMenuTheme.activeTabBackgroundColor : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        hoverColor: sideMenuTheme.tabHoverColor,
        leading: minimizedSideMenu(size)
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 12.5, left: 20),
                child: leading,
              ),
        title: minimizedSideMenu(size)
            ? Center(
                child: leading,
              )
            : Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
        trailing: trailing,
      ),
    );
  }


  bool minimizedSideMenu(Size size) => true;
  // bool minimizedSideMenu(Size size) => size.width < 1300;
}
