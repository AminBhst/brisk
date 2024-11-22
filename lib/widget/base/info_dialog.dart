import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoDialog extends StatelessWidget {
  final String title;

  const InfoDialog({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    return AlertDialog(
      backgroundColor: theme.backgroundColor,
      content: Container(
        child: Text(
          title,
          style: const TextStyle(fontSize: 17),
        ),
      ),
    );
  }
}
