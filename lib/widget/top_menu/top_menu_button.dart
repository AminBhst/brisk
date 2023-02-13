import 'package:flutter/material.dart';

class TopMenuButton extends StatelessWidget {
  final String title;
  final Widget icon;
  final Color onHoverColor;
  final VoidCallback onTap;

  const TopMenuButton({super.key, required this.title, required this.icon, this.onHoverColor = Colors.blueGrey, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        hoverColor: onHoverColor,
        onTap: onTap,
        child: SizedBox(
          width: 80,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              Text(title, style: const TextStyle(color: Colors.white))
            ],
          ),
        ),
      ),
    );
  }
}
