import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExternalLinkSetting extends StatelessWidget {
  final String title;
  final String linkText;
  final VoidCallback onLinkPressed;
  final String? tooltipMessage;
  double titleWidth;

  ExternalLinkSetting({
    super.key,
    required this.title,
    required this.linkText,
    required this.onLinkPressed,
    this.tooltipMessage,
    this.titleWidth = 100,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.settingTheme.pageTheme;
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5 * 0.5,
          child: Row(children: [
            SizedBox(
              width: titleWidth,
              child: Text(
                title,
                style: TextStyle(
                  overflow: TextOverflow.clip,
                  color: theme.titleTextColor,
                ),
              ),
            ),
            tooltipMessage != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Tooltip(
                      child: Icon(Icons.info, color: Colors.grey),
                      message: tooltipMessage,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(33, 33, 33, 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: TextStyle(color: Colors.white),
                    ),
                  )
                : Container(),
          ]),
        ),
        const Spacer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onLinkPressed,
              icon: Icon(Icons.launch_rounded, color: Colors.white),
            ),
            Text(linkText, style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        )
      ],
    );
  }
}
