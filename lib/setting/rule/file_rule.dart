import 'package:brisk/setting/rule/file_condition.dart';

class FileRule {
  final FileCondition condition;
  final String value;

  FileRule({required this.condition, required this.value});

  @override
  String toString() {
    return "${condition.name}:$value";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other is! FileRule)
      return false;
    return this.condition == other.condition && this.value == other.value;
  }

  String get valueWithTypeConsidered {
    return readableValue
        .replaceAll(" GB", "")
        .replaceAll(" MB", "")
        .replaceAll(" KB", "");
  }

  String get readableValue {
    if (condition.hasTextValue()) {
      return value;
    }
    double bytes = double.tryParse(value) ?? 0;
    if (bytes >= 1024 * 1024 * 1024) {
      double gb = bytes / (1024 * 1024 * 1024);
      return "${gb.toStringAsFixed(2)} GB";
    } else if (bytes >= 1024 * 1024) {
      double mb = bytes / (1024 * 1024);
      return "${mb.toStringAsFixed(2)} MB";
    } else {
      double kb = bytes / 1024;
      return "${kb.toStringAsFixed(2)} KB";
    }
  }

  factory FileRule.fromString(String str) {
    final conditionStr = str.substring(0, str.indexOf(":"));
    final condition = FileCondition.values.byName(conditionStr);
    final value = str.substring(str.indexOf(":") + 1);
    return FileRule(condition: condition, value: value);
  }
}
