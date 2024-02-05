import 'package:brisk/model/file_metadata.dart';
import 'package:brisk/util/file_util.dart';
import 'package:brisk/util/http_util.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

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
