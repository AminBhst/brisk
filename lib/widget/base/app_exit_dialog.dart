import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppExitDialog extends StatefulWidget {
  final Function(bool) onExitPressed;
  final Function(bool) onMinimizeToTrayPressed;

  const AppExitDialog({
    super.key,
    required this.onExitPressed,
    required this.onMinimizeToTrayPressed,
  });

  @override
  State<AppExitDialog> createState() => _AppExitDialogState();
}

class _AppExitDialogState extends State<AppExitDialog> {
  bool rememberChecked = false;

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    return AlertDialog(
      backgroundColor: theme.backgroundColor,
      surfaceTintColor: theme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(245, 158, 11, 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Align(
                alignment: const Alignment(0, -0.16),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Color.fromRGBO(245, 158, 11, 1),
                  size: 35,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Text(
            "Choose Action",
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Container(
        height: 270,
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Choose what you'd like to do with the application",
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                RoundedOutlinedButton(
                  mainAxisAlignment: MainAxisAlignment.start,
                  text: "Exit Application",
                  icon: Icon(
                    Icons.power_settings_new_rounded,
                    color: Colors.white54,
                  ),
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                  backgroundColor: theme.itemContainerBackgroundColor,
                  hoverBackgroundColor: Color.fromRGBO(220, 38, 38, 1),
                  height: 45,
                  width: 500,
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onExitPressed(rememberChecked);
                  },
                ),
                SizedBox(height: 10),
                RoundedOutlinedButton(
                  mainAxisAlignment: MainAxisAlignment.start,
                  text: "Minimize To System Tray",
                  height: 45,
                  icon: Icon(Icons.minimize_rounded, color: Colors.white54),
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                  hoverBackgroundColor: Color.fromRGBO(53, 89, 143, 1),
                  backgroundColor: theme.itemContainerBackgroundColor,
                  width: 500,
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onMinimizeToTrayPressed(rememberChecked);
                  },
                ),
                SizedBox(height: 10),
                RoundedOutlinedButton(
                  mainAxisAlignment: MainAxisAlignment.start,
                  text: "Cancel",
                  height: 45,
                  icon: Icon(Icons.close_rounded, color: Colors.white54),
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                  backgroundColor: theme.itemContainerBackgroundColor,
                  width: 500,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      side: WidgetStateBorderSide.resolveWith(
                        (states) => BorderSide(width: 1.0, color: Colors.grey),
                      ),
                      activeColor: Colors.blueGrey,
                      value: rememberChecked,
                      onChanged: (value) => setState(
                        () => rememberChecked = value!,
                      ),
                    ),
                    Text("Remember this decision"),
                  ],
                )
              ],
            )
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
