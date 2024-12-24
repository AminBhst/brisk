import 'package:hive/hive.dart';

part 'migration.g.dart';

@HiveType(typeId: 4)
class Migration extends HiveObject {
  @HiveField(1)
  int version;

  @HiveField(2)
  String description;

  Migration(this.version, this.description);
}
