import 'package:brisk/constants/file_duplication_behaviour.dart';
import 'package:brisk/constants/file_type.dart';
import 'package:brisk/constants/setting_options.dart';
import 'package:brisk/constants/setting_type.dart';
import 'package:csv/csv.dart';

bool parseBool(String val) {
  return val.toLowerCase() == "true" ? true : false;
}

SettingType parseSettingType(String val) {
  return SettingType.values.where((type) => type.name == val).first;
}

DLFileType parseFileType(String val) {
  return DLFileType.values.where((type) => type.name == val).first;
}

FileDuplicationBehaviour parseFileDuplicationBehaviour(String val) {
  return FileDuplicationBehaviour.values
      .where((type) => type.name == val)
      .first;
}

SettingOptions parseSettingOptions(String val) {
  return SettingOptions.values.where((type) => type.name == val).first;
}

String parseBoolStr(bool val) {
  return val ? "true" : "false";
}

String parseListToCsv(List<String> list) {
  return const ListToCsvConverter().convert([list, []]);
}

List<String> parseCsvToList(String csv) {
  return csv.isEmpty ? [] : const CsvToListConverter().convert(csv)[0].cast();
}
