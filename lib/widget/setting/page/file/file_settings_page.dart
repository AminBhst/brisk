import 'package:brisk/widget/setting/page/file/file_category_group.dart';
import 'package:brisk/widget/setting/page/file/file_rules_group.dart';
import 'package:brisk/widget/setting/page/file/path_settings_group.dart';
import 'package:flutter/material.dart';

class FileSettingsPage extends StatelessWidget {
  const FileSettingsPage({super.key});

  /// to be implemented :
  /// Duplication behavior
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            PathSettingsGroup(),
            FileRulesGroup(),
            FileCategoryGroup(),
          ],
        ),
      ),
    );
  }
}
