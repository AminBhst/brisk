import 'dart:async';

import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/widget/base/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShutdownWarningDialog extends StatefulWidget {
  final VoidCallback onShutdownNowPressed;
  final VoidCallback onCancelShutdownPressed;

  const ShutdownWarningDialog({
    super.key,
    required this.onShutdownNowPressed,
    required this.onCancelShutdownPressed,
  });

  @override
  State<ShutdownWarningDialog> createState() => _ShutdownWarningDialogState();
}

class _ShutdownWarningDialogState extends State<ShutdownWarningDialog> {
  late Timer _countdownTimer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _countdownTimer.cancel();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.alertDialogTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: theme.backgroundColor,
      title: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(245, 158, 11, 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Align(
                alignment: Alignment(0, -0.16),
                child: Icon(
                  Icons.warning_rounded,
                  color: Color.fromRGBO(245, 158, 11, 1),
                  size: 35,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "Shutdown Warning",
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Text(
          "Your PC will shutdown in $_secondsRemaining seconds",
          style: const TextStyle(fontSize: 17),
        ),
      ),
      actions: [
        RoundedOutlinedButton.fromButtonColor(
          theme.deleteCancelColor,
          text: "Cancel Shutdown",
          width: 160,
          onPressed: () {
            _countdownTimer.cancel();
            widget.onCancelShutdownPressed();
            Navigator.of(context).pop();
          },
        ),
        RoundedOutlinedButton.fromButtonColor(
          theme.deleteConfirmColor,
          text: "Shutdown Now",
          width: 150,
          onPressed: () {
            _countdownTimer.cancel();
            widget.onShutdownNowPressed();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
