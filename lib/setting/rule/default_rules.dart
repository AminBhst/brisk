import 'package:brisk/setting/rule/file_condition.dart';
import 'package:brisk/setting/rule/file_rule.dart';
import 'package:brisk/util/file_extensions.dart';

class DefaultRules {
  static final List<FileRule> extensionSkipCaptureRules = [
    ...FileExtensions.image.map(
      (e) {
        return FileRule(
          condition: FileCondition.fileExtensionIs,
          value: e,
        );
      },
    ),
    FileRule(
      condition: FileCondition.fileSizeLessThan,
      value: "1048576",
    ),
  ];
}
