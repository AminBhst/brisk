import 'package:intl/intl.dart';




DateTime normalizeDate(DateTime dateTime) {
  return DateTime(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    dateTime.hour,
    dateTime.minute,
    0,
    0,
    0,
  );
}

String? formatDate(DateTime? dateTime) {
  if (dateTime == null) return null;
  final formatter = DateFormat('yyyy-MM-dd HH:mm');
  return formatter.format(dateTime);
}
