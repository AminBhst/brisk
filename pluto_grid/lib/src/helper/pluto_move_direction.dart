enum PlutoMoveDirection {
  left,
  right,
  up,
  down;

  bool get horizontal {
    switch (this) {
      case PlutoMoveDirection.left:
      case PlutoMoveDirection.right:
        return true;
      default:
        return false;
    }
  }

  bool get vertical {
    switch (this) {
      case PlutoMoveDirection.up:
      case PlutoMoveDirection.down:
        return true;
      default:
        return false;
    }
  }

  int get offset {
    switch (this) {
      case PlutoMoveDirection.left:
      case PlutoMoveDirection.up:
        return -1;
      case PlutoMoveDirection.right:
      case PlutoMoveDirection.down:
        return 1;
      default:
        return 0;
    }
  }

  bool get isLeft {
    return PlutoMoveDirection.left == this;
  }

  bool get isRight {
    return PlutoMoveDirection.right == this;
  }

  bool get isUp {
    return PlutoMoveDirection.up == this;
  }

  bool get isDown {
    return PlutoMoveDirection.down == this;
  }
}
