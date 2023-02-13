import 'package:flutter/material.dart';

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
    final size = MediaQuery
        .of(context)
        .size;
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
            child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
          Container(
            width: containerWidth,
            height: containerHeight,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(42, 43, 43, 1),
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
