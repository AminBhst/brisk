import 'package:brisk/constants/setting_options.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/model/migration.dart';
import 'package:brisk/model/setting.dart';
import 'package:brisk/util/settings_cache.dart';

class MigrationManager {
  static List<Migration> migrations = [
    Migration(0, "Add proxy Settings"),
    Migration(1, "Add m3u8 connection number"),
  ];

  static runMigrations() async {
    final migrationBox = HiveUtil.instance.migrationBox;
    for (final migration in migrations) {
      var existingMigration = migrationBox.get(migration.version);
      if (existingMigration != null) {
        continue;
      }
      await runMigration(migration);
    }
  }

  static runMigration(Migration migration) async {
    switch (migration.version) {
      case 0:
        await runMigrationV0();
        break;
      case 1:
        await runMigrationV1();
        break;
      default:
        break;
    }
    await HiveUtil.instance.migrationBox.put(migration.version, migration);
  }

  static runMigrationV0() async {
    final newSettings = [
      Setting(
        name: SettingOptions.proxyEnabled.name,
        value:
            SettingsCache.defaultSettings[SettingOptions.proxyEnabled.name]![1],
        settingType:
            SettingsCache.defaultSettings[SettingOptions.proxyEnabled.name]![0],
      ),
      Setting(
        name: SettingOptions.proxyAddress.name,
        value:
            SettingsCache.defaultSettings[SettingOptions.proxyAddress.name]![1],
        settingType:
            SettingsCache.defaultSettings[SettingOptions.proxyAddress.name]![0],
      ),
      Setting(
        name: SettingOptions.proxyPort.name,
        value: SettingsCache.defaultSettings[SettingOptions.proxyPort.name]![1],
        settingType:
            SettingsCache.defaultSettings[SettingOptions.proxyPort.name]![0],
      ),
      Setting(
        name: SettingOptions.proxyUsername.name,
        value: SettingsCache
            .defaultSettings[SettingOptions.proxyUsername.name]![1],
        settingType: SettingsCache
            .defaultSettings[SettingOptions.proxyUsername.name]![0],
      ),
      Setting(
        name: SettingOptions.proxyPassword.name,
        value: SettingsCache
            .defaultSettings[SettingOptions.proxyPassword.name]![1],
        settingType: SettingsCache
            .defaultSettings[SettingOptions.proxyPassword.name]![0],
      ),
    ];
    for (final setting in newSettings) {
      await HiveUtil.instance.settingBox.add(setting);
    }
  }

  static runMigrationV1() async {
    final connNumSetting = Setting(
      name: SettingOptions.m3u8ConnectionsNumber.name,
      value: SettingsCache
          .defaultSettings[SettingOptions.m3u8ConnectionsNumber.name]![1],
      settingType: SettingsCache
          .defaultSettings[SettingOptions.m3u8ConnectionsNumber.name]![0],
    );
    await HiveUtil.instance.settingBox.add(connNumSetting);
  }
}
