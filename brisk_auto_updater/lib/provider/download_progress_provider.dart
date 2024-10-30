import 'package:flutter/cupertino.dart';

class DownloadProgressProvider with ChangeNotifier {
  double progress = 0;
  String? error;

  void setProgress(double progress) {
    this.progress = progress;
    notifyListeners();
  }

  void setError(String error) {
    this.error = error;
    notifyListeners();
  }
}
