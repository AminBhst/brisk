import 'package:brisk/setting/rule/file_condition.dart';

class FileRule {
  final FileCondition condition;
  final String value;

  FileRule({required this.condition, required this.value});

  @override
  String toString() {
    return "${condition.name}:$value";
  }

  factory FileRule.fromString(String str) {
    final conditionStr = str.substring(0, str.indexOf(":"));
    final condition = FileCondition.values.byName(conditionStr);
    final value = str.substring(str.indexOf(":") + 1);
    return FileRule(condition: condition, value: value);
  }
}
