import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlutoKeyManagerEvent {
  FocusNode focusNode;
  KeyEvent event;

  PlutoKeyManagerEvent({
    required this.focusNode,
    required this.event,
  });

  bool get needsThrottle => isMoving || isTab || isPageUp || isPageDown;

  bool get isKeyDownEvent => event.runtimeType == KeyDownEvent;

  bool get isKeyUpEvent => event.runtimeType == KeyUpEvent;

  bool get isMoving => isHorizontal || isVertical;

  bool get isHorizontal => isLeft || isRight;

  bool get isVertical => isUp || isDown;

  bool get isLeft =>
      event.logicalKey.keyId == LogicalKeyboardKey.arrowLeft.keyId;

  bool get isRight =>
      event.logicalKey.keyId == LogicalKeyboardKey.arrowRight.keyId;

  bool get isUp => event.logicalKey.keyId == LogicalKeyboardKey.arrowUp.keyId;

  bool get isDown =>
      event.logicalKey.keyId == LogicalKeyboardKey.arrowDown.keyId;

  bool get isHome => event.logicalKey.keyId == LogicalKeyboardKey.home.keyId;

  bool get isEnd => event.logicalKey.keyId == LogicalKeyboardKey.end.keyId;

  bool get isPageUp {
    // windows 에서 pageUp keyId 가 0x10700000021.
    return event.logicalKey.keyId == LogicalKeyboardKey.pageUp.keyId ||
        event.logicalKey.keyId == 0x10700000021;
  }

  bool get isPageDown {
    // windows 에서 pageDown keyId 가 0x10700000022.
    return event.logicalKey.keyId == LogicalKeyboardKey.pageDown.keyId ||
        event.logicalKey.keyId == 0x10700000022;
  }

  bool get isEsc => event.logicalKey.keyId == LogicalKeyboardKey.escape.keyId;

  bool get isEnter =>
      event.logicalKey.keyId == LogicalKeyboardKey.enter.keyId ||
      event.logicalKey.keyId == LogicalKeyboardKey.numpadEnter.keyId;

  bool get isTab => event.logicalKey.keyId == LogicalKeyboardKey.tab.keyId;

  bool get isF2 => event.logicalKey.keyId == LogicalKeyboardKey.f2.keyId;

  bool get isF3 => event.logicalKey.keyId == LogicalKeyboardKey.f3.keyId;

  bool get isF4 => event.logicalKey.keyId == LogicalKeyboardKey.f4.keyId;

  bool get isBackspace =>
      event.logicalKey.keyId == LogicalKeyboardKey.backspace.keyId;

  bool get isShift =>
      event.logicalKey.keyId == LogicalKeyboardKey.shift.keyId ||
      event.logicalKey.keyId == LogicalKeyboardKey.shiftLeft.keyId ||
      event.logicalKey.keyId == LogicalKeyboardKey.shiftRight.keyId;

  bool get isControl =>
      event.logicalKey.keyId == LogicalKeyboardKey.control.keyId ||
      event.logicalKey.keyId == LogicalKeyboardKey.controlLeft.keyId ||
      event.logicalKey.keyId == LogicalKeyboardKey.controlRight.keyId;

  bool get isCharacter => _characters.contains(event.logicalKey.keyId);

  bool get isCtrlC {
    return isCtrlPressed &&
        event.logicalKey.keyId == LogicalKeyboardKey.keyC.keyId;
  }

  bool get isCtrlV {
    return isCtrlPressed &&
        event.logicalKey.keyId == LogicalKeyboardKey.keyV.keyId;
  }

  bool get isCtrlA {
    return isCtrlPressed &&
        event.logicalKey.keyId == LogicalKeyboardKey.keyA.keyId;
  }

  bool get isShiftPressed {
    return HardwareKeyboard.instance.isShiftPressed;
  }

  bool get isCtrlPressed {
    return HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed;
  }

  bool get isAltPressed {
    return HardwareKeyboard.instance.isAltPressed;
  }

  bool get isModifierPressed {
    return isShiftPressed || isCtrlPressed || isAltPressed;
  }
}

const _characters = {
  0x0000000041, // keyA,
  0x0000000042, // keyB,
  0x0000000043, // keyC,
  0x0000000044, // keyD,
  0x0000000045, // keyE,
  0x0000000046, // keyF,
  0x0000000047, // keyG,
  0x0000000048, // keyH,
  0x0000000049, // keyI,
  0x000000004a, // keyJ,
  0x000000004b, // keyK,
  0x000000004c, // keyL,
  0x000000004d, // keyM,
  0x000000004e, // keyN,
  0x000000004f, // keyO,
  0x0000000050, // keyP,
  0x0000000051, // keyQ,
  0x0000000052, // keyR,
  0x0000000053, // keyS,
  0x0000000054, // keyT,
  0x0000000055, // keyU,
  0x0000000056, // keyV,
  0x0000000057, // keyW,
  0x0000000058, // keyX,
  0x0000000059, // keyY,
  0x000000005a, // keyZ,
  0x0000000061, // keyA,
  0x0000000062, // keyB,
  0x0000000063, // keyC,
  0x0000000064, // keyD,
  0x0000000065, // keyE,
  0x0000000066, // keyF,
  0x0000000067, // keyG,
  0x0000000068, // keyH,
  0x0000000069, // keyI,
  0x000000006a, // keyJ,
  0x000000006b, // keyK,
  0x000000006c, // keyL,
  0x000000006d, // keyM,
  0x000000006e, // keyN,
  0x000000006f, // keyO,
  0x0000000070, // keyP,
  0x0000000071, // keyQ,
  0x0000000072, // keyR,
  0x0000000073, // keyS,
  0x0000000074, // keyT,
  0x0000000075, // keyU,
  0x0000000076, // keyV,
  0x0000000077, // keyW,
  0x0000000078, // keyX,
  0x0000000079, // keyY,
  0x000000007a, // keyZ,
  0x0000000031, // digit1,
  0x0000000032, // digit2,
  0x0000000033, // digit3,
  0x0000000034, // digit4,
  0x0000000035, // digit5,
  0x0000000036, // digit6,
  0x0000000037, // digit7,
  0x0000000038, // digit8,
  0x0000000039, // digit9,
  0x0000000030, // digit0,
  0x0000000020, // space,
  0x000000002d, // minus,
  0x000000003d, // equal,
  0x000000005b, // bracketLeft,
  0x000000005d, // bracketRight,
  0x000000005c, // backslash,
  0x000000003b, // semicolon,
  0x0000000027, // quote,
  0x0000000060, // backquote,
  0x000000002c, // comma,
  0x000000002e, // period,
  0x000000002f, // slash,
  0x0100070054, // numpadDivide,
  0x0100070055, // numpadMultiply,
  0x0100070056, // numpadSubtract,
  0x0100070057, // numpadAdd,
  0x0100070059, // numpad1,
  0x010007005a, // numpad2,
  0x010007005b, // numpad3,
  0x010007005c, // numpad4,
  0x010007005d, // numpad5,
  0x010007005e, // numpad6,
  0x010007005f, // numpad7,
  0x0100070060, // numpad8,
  0x0100070061, // numpad9,
  0x0100070062, // numpad0,
  0x0100070063, // numpadDecimal,
  0x0100070064, // intlBackslash,
  0x0100070067, // numpadEqual,
  0x0100070085, // numpadComma,
  0x0100070087, // intlRo,
  0x0100070089, // intlYen,
  0x01000700b6, // numpadParenLeft,
  0x01000700b7, // numpadParenRight,
};
