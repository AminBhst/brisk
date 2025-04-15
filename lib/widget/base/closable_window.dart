import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClosableWindow extends StatelessWidget {
  final Widget content;
  final double width;
  final double height;
  final List<Widget> actions;
  final VoidCallback? onWindowClosed;
  final EdgeInsets padding;
  final bool disableCloseButton;
  final Color backgroundColor;
  final double borderRadius;
  final Widget? title;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const ClosableWindow({
    super.key,
    required this.content,
    this.width = 400,
    this.height = 400,
    this.borderRadius = 25,
    this.onWindowClosed,
    this.actions = const [],
    this.padding = const EdgeInsets.all(20),
    this.disableCloseButton = false,
    this.backgroundColor = const Color.fromRGBO(25, 25, 25, 1),
    this.title,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;
    return AlertDialog(
      backgroundColor: theme.backgroundColor,
      surfaceTintColor: theme.backgroundColor,
      insetPadding: const EdgeInsets.all(20),
      elevation: 0,
      title: title,
      content: AnimatedSize(
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.fromBorderSide(BorderSide(color: Colors.white24)),
            color: backgroundColor,
          ),
          child: Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Padding(
                padding: const EdgeInsets.all(0),
                child: Stack(
                  children: [
                    Visibility(
                      visible: !disableCloseButton,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Material(
                          type: MaterialType.transparency,
                          child: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onWindowClosed?.call();
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 0),
              content
            ],
          ),
        ),
      ),
    );
  }
}
