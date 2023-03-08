import 'package:flutter/cupertino.dart';

class QueueProvider with ChangeNotifier {
  bool queueSelected = false;
  int? selectedQueueId;

  void setIsQueueTopMenu(bool value) {
    queueSelected = value;
    notifyListeners();
  }
}