import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// Widget that is displayed when loading is enabled
/// with the [PlutoGridStateManager.setShowLoading] method.
class PlutoLoading extends StatelessWidget {
  final PlutoGridLoadingLevel level;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final String? text;
  final TextStyle? textStyle;

  const PlutoLoading({
    this.level = PlutoGridLoadingLevel.grid,
    this.backgroundColor,
    this.indicatorColor,
    this.text,
    this.textStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    switch (level) {
      case PlutoGridLoadingLevel.grid:
        return _GridLoading(
          backgroundColor: backgroundColor,
          indicatorColor: indicatorColor,
          text: text,
          textStyle: textStyle,
        );
      case PlutoGridLoadingLevel.rows:
        return LinearProgressIndicator(
          backgroundColor: Colors.transparent,
          color: indicatorColor,
        );
      case PlutoGridLoadingLevel.rowsBottomCircular:
        return CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          color: indicatorColor,
        );
    }
  }
}

class _GridLoading extends StatelessWidget {
  const _GridLoading({
    this.backgroundColor,
    this.indicatorColor,
    this.text,
    this.textStyle,
  });

  final Color? backgroundColor;
  final Color? indicatorColor;
  final String? text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.7,
            child: ColoredBox(
              color: backgroundColor ?? Colors.white,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                backgroundColor: backgroundColor ?? Colors.white,
                color: indicatorColor ?? Colors.lightBlue,
                strokeWidth: 2,
              ),
              const SizedBox(height: 10),
              Text(
                text ?? 'Loading',
                style: textStyle ??
                    const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
