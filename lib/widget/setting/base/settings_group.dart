import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsGroup extends StatelessWidget {
  final double width;
  final String title;
  final List<Widget> children;
  final double? containerWidth;
  final double? containerHeight;

  const SettingsGroup({
    super.key,
    this.width = 650,
    required this.children,
    this.title = "",
    this.containerWidth,
    this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.settingTheme.pageTheme;
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: resolveWidth(size),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                title,
                style: TextStyle(
                  color: theme.groupTitleTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Container(
            width: containerWidth,
            // Don't set height unless explicitly passed
            height: containerHeight,
            decoration: BoxDecoration(
              color: theme.groupBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          )
        ],
      ),
    );
  }

  double resolveWidth(Size size) {
    if (size.width < 809) {
      return size.width * 0.85;
    }
    return width;
  }
}

