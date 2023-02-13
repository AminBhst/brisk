import 'package:brisk/constants/setting_type.dart';

class Setting {
  int id;
  String name;
  String value;
  SettingType type;

  Setting({this.id = 0, required this.name, required this.value, required this.type});
}
