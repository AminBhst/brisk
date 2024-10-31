import 'dart:io';

import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

class BriskChangeLogDialog extends StatelessWidget {
  final String updatedVersion;
  final String changeLog;

  const BriskChangeLogDialog({
    super.key,
    required this.updatedVersion,
    required this.changeLog,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    final size = MediaQuery.of(context).size;
    return ClosableWindow(
        height: 700,
        width: 600,
        backgroundColor: theme.backgroundColor,
        content: Column(
          children: [
            Text(
              EmojiParser().emojify(
                  "Brisk successfully updated to v$updatedVersion! :tada:"),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white10),
                  borderRadius: BorderRadius.circular(20)),
              width: 500,
              height: resolveMainContainerHeight(size),
              child: Markdown(
                data: EmojiParser().emojify(changeLog),
              ),
            )
          ],
        ));
  }

  double resolveMainContainerHeight(Size size) {
    print(size.height);
    double height = 500;
    if (size.height < 761) {
      height = size.height * 0.6;
    }
    if (size.height < 653) {
      height = size.height * 0.55;
    }
    if (size.height < 580) {
      height = size.height * 0.50;
    }
    if (size.height < 522) {
      height = size.height * 0.45;
    }
    if (size.height < 475) {
      height = size.height * 0.4;
    }
    if (size.height < 435) {
      height = size.height * 0.3;
    }
    return height;
  }
}
