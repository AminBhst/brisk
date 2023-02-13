import 'package:flutter/material.dart';

class SideMenuItem extends StatelessWidget {
  final VoidCallback onTap;
  final Color hoverColor;
  final Widget leading;
  final Widget? trailing;
  final String title;
  const SideMenuItem({
    super.key,
    required this.onTap,
    this.hoverColor = const Color.fromRGBO(51, 59, 75, 1),
    required this.leading,
    required this.trailing,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ListTile(
      onTap: onTap,
      hoverColor: const Color.fromRGBO(51, 59, 75, 1),
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
    );
  }

  bool minimizedSideMenu(Size size) => size.width < 1300;
}
