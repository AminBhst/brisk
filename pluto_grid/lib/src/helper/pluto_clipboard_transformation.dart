class PlutoClipboardTransformation {
  /// Converts [text] separated by newline and tab characters into a two-dimensional array.
  static List<List<String>> stringToList(String text) {
    return text
        .split(RegExp('\n|\r\n'))
        .map((text) => text.split('\t'))
        .toList();
  }
}
