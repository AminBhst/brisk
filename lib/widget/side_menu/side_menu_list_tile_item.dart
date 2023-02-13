import 'package:flutter/material.dart';

class SideMenuListTileItem extends StatelessWidget {
  final String text;
  final Widget icon;
  final double size;
  Widget? trailing;
  VoidCallback onTap;

  SideMenuListTileItem({
    super.key,
    required this.text,
    required this.icon,
    this.size = 25,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mSize = MediaQuery.of(context).size;
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        hoverColor: Colors.blueAccent,
        onTap: onTap,
        leading: minimizedSideMenu(mSize) ? null : SizedBox(width: size, height: size, child: icon),
        title: minimizedSideMenu(mSize) ? Padding(
          padding: const EdgeInsets.only(right: 3.0),
          child: SizedBox(width: size, height: size, child: icon),
        ): Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
  bool minimizedSideMenu(Size size) => size.width < 1300;
}
