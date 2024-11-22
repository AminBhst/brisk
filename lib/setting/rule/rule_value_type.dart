import 'package:brisk/setting/rule/file_condition.dart';
import 'package:brisk/setting/rule/file_rule.dart';

enum RuleValueType {
  KB,
  MB,
  GB,
  Text;

  static RuleValueType fromRule(FileRule rule) {
    switch (rule.condition) {
      case FileCondition.fileNameContains:
      case FileCondition.downloadUrlContains:
      case FileCondition.fileExtensionIs:
        return RuleValueType.Text;
      case FileCondition.fileSizeLessThan:
      case FileCondition.fileSizeGreaterThan:
        final size = double.parse(rule.value);
        if (size >= 1024 * 1024 * 1024) {
          return RuleValueType.GB;
        } else if (size >= 1024 * 1024) {
          return RuleValueType.MB;
        } else {
          return RuleValueType.KB;
        }
    }
  }

  bool isText() {
    switch (this) {
      case RuleValueType.MB:
      case RuleValueType.KB:
      case RuleValueType.GB:
        return false;
      case RuleValueType.Text:
        return true;
    }
  }

  bool isNumber() {
    switch (this) {
      case RuleValueType.MB:
      case RuleValueType.KB:
      case RuleValueType.GB:
        return true;
      case RuleValueType.Text:
        return false;
    }
  }
}
