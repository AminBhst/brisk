import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BugReportPage extends StatelessWidget {
  const BugReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SettingsGroup(
              height: 180,
              title: "How to report a bug",
              children: [
                SizedBox(
                  width: size.width * 0.6,
                  child: const Text(
                    "In order to report a bug or request a feature, open a new issue in the project github repo and add the proper labels.\n\n"
                        "The link of the project repo is available in the about tab.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
            SettingsGroup(
              height: 500,
              title: "Note",
              children: [
                SizedBox(
                  width: size.width * 0.6,
                  child: const Text(
                        "Please refrain from submitting issues which have already been mentioned in known issues section in the project README",
                    style: TextStyle(color: Colors.white),
                  ),
                )

              ],
            )

          ],
        ),
      ),
    );
  }
}
