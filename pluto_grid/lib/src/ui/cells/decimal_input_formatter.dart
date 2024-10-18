import 'package:flutter/services.dart';

// https://stackoverflow.com/questions/54454983/allow-only-two-decimal-number-in-flutter-input
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({
    int? decimalRange,
    required bool activatedNegativeValues,
    required bool allowFirstDot,
    required String decimalSeparator,
  }) : assert(decimalRange == null || decimalRange >= 0,
            'DecimalTextInputFormatter declaration error') {
    String dp = (decimalRange != null && decimalRange > 0)
        ? '([$decimalSeparator][0-9]{0,$decimalRange}){0,1}'
        : '';
    String num = '[0-9]*$dp';

    if (activatedNegativeValues) {
      final firstSymbols = allowFirstDot ? '[-$decimalSeparator]' : '[-]';

      _exp = RegExp(
        '^(((($firstSymbols){0,1})|(($firstSymbols){0,1}[0-9]$num))){0,1}\$',
      );
    } else {
      _exp = RegExp('^($num){0,1}\$');
    }
  }

  late RegExp _exp;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_exp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
