import 'package:hive/hive.dart';

part 'setting.g.dart';

@HiveType(typeId: 2)
class Setting extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String value;

  @HiveField(2)
  String settingType;

  Setting({
    required this.name,
    required this.value,
    required this.settingType,
  });
}
