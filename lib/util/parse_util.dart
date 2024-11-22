import 'package:brisk/constants/app_closure_behaviour.dart';
import 'package:brisk/constants/file_duplication_behaviour.dart';
import 'package:brisk/constants/file_type.dart';
import 'package:brisk/constants/setting_options.dart';
import 'package:brisk/constants/setting_type.dart';
import 'package:brisk/setting/rule/file_save_path_rule.dart';
import 'package:brisk/setting/rule/file_rule.dart';
import 'package:csv/csv.dart';
import 'package:dartx/dartx.dart';

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

AppClosureBehaviour parseAppCloseBehaviour(String val) {
  return AppClosureBehaviour.values.where((type) => type.name == val).first;
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

bool isCsv(String str) {
  return str.contains(",");
}

String parseFileRulesToCsv(List<FileRule> fileRules) {
  if (fileRules.isEmpty) return "";
  final fileRulesStr = fileRules.map((o) => o.toString()).toList();
  return parseListToCsv(fileRulesStr);
}

String parseFileSavePathRulesToCsv(List<FileSavePathRule> rules) {
  if (rules.isEmpty) return "";
  final fileRulesStr = rules.map((o) => o.toString()).toList();
  return parseListToCsv(fileRulesStr);
}

List<FileSavePathRule> parseCsvToFileSavePathRuleList(String csv) {
  if (csv.isNullOrBlank) return [];
  final rulesStr = parseCsvToList(csv);
  return rulesStr.map((str) => FileSavePathRule.fromString(str)).toList();
}

List<FileRule> parseCsvToFileRuleList(String csv) {
  if (csv.isNullOrBlank) return [];
  final rulesStr = parseCsvToList(csv);
  return rulesStr.map((str) => FileRule.fromString(str)).toList();
}

List<String> parseCsvToList(String csv) {
  if (csv.isNullOrBlank) return [];
  return csv.isEmpty ? [] : const CsvToListConverter().convert(csv)[0].cast();
}
