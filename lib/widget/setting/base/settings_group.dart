import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsGroup extends StatelessWidget {
  final double height;
  final double width;
  final String title;
  final List<Widget> children;
  final double? containerWidth;
  final double? containerHeight;

  const SettingsGroup({
    super.key,
    this.height = 200,
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
      height: height,
      width: size.width * 0.6 * 0.68,
      // width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            height: containerHeight,
            decoration: BoxDecoration(
              color: theme.groupBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            ),
          )
        ],
      ),
    );
  }
}
