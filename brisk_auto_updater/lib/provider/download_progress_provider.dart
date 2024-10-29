import 'package:flutter/cupertino.dart';

class DownloadProgressProvider with ChangeNotifier {
  double progress = 0;

  void setProgress(double progress) {
    this.progress = progress;
    print(progress);
    notifyListeners();
  }
}
