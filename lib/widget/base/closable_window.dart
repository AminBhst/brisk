import 'package:flutter/material.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedSize(
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
