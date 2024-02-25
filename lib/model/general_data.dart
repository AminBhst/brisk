import 'package:hive/hive.dart';

part 'general_data.g.dart';

@HiveType(typeId: 3)
class GeneralData extends HiveObject{

  @HiveField(1)
  String fieldName;

  @HiveField(2)
  dynamic value;

  GeneralData({
    required this.fieldName,
    required this.value
  });
}
