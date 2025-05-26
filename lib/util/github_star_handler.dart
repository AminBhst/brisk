import 'dart:async';

import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/general_data.dart';
import 'package:flutter/material.dart';

import '../widget/other/github_star_dialog.dart';

class GitHubStarHandler {
  static Timer? timer;

  static void handleShowDialog(BuildContext context) {
    if (neverShowAgainGeneralData.value) return;
    timer = Timer.periodic(Duration(minutes: 5), (_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => GithubStarDialog(),
      );
      timer?.cancel();
    });
  }

  static void setNeverShowAgain() async {
    final neverShowAgain = neverShowAgainGeneralData;
    neverShowAgain.value = true;
    await neverShowAgain.save();
  }

  static GeneralData get neverShowAgainGeneralData {
    return HiveUtil.instance.generalDataBox.values
        .where((g) => g.fieldName == "githubStar_neverShowAgain")
        .first;
  }
}
