import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideMenuListTileItem extends StatelessWidget {
  final String text;
  final Widget? icon;
  final double size;
  Widget? trailing;
  VoidCallback onTap;
  final bool responsive;
  final bool active;

  SideMenuListTileItem({
    super.key,
    required this.text,
    this.responsive = true,
    this.icon,
    this.size = 25,
    this.trailing,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final sideMenuTheme =
        Provider.of<ThemeProvider>(context).activeTheme.sideMenuTheme;
    final mSize = MediaQuery.of(context).size;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: active
            ? sideMenuTheme.expansionTileItemActiveColor
            : Colors.transparent,
        child: ListTile(
          hoverColor: sideMenuTheme.expansionTileItemHoverColor,
          onTap: onTap,
          leading: minimizedSideMenu(mSize)
              ? null
              : SizedBox(width: size, height: size, child: icon),
          title: minimizedSideMenu(mSize)
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(end: 3),
                  child: SizedBox(width: size, height: size, child: icon),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
          trailing: trailing,
        ),
      ),
    );
  }


  bool minimizedSideMenu(Size size) => true;
  // bool minimizedSideMenu(Size size) => size.width < 1300 && responsive;
}
