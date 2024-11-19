import 'package:brisk/setting/rule/file_condition.dart';
import 'package:brisk/setting/rule/file_rule.dart';
import 'package:brisk/util/file_extensions.dart';

class DefaultRules {
  static final List<FileRule> extensionIgnoreListRules = [
    FileRule(
      condition: FileCondition.fileExtensionIs,
      value: FileExtensions.image.join("-"),
    ),
    FileRule(
      condition: FileCondition.fileSizeLessThan,
      value: "1048576",
    ),
  ];
}
