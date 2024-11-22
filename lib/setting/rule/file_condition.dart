enum FileCondition {
  fileNameContains,
  fileSizeGreaterThan,
  fileSizeLessThan,
  fileExtensionIs,
  downloadUrlContains;

  bool hasNumberValue() {
    switch (this) {
      case FileCondition.downloadUrlContains:
      case FileCondition.fileNameContains:
      case FileCondition.fileExtensionIs:
        return false;
      case FileCondition.fileSizeLessThan:
      case FileCondition.fileSizeGreaterThan:
        return true;
    }
  }

  bool hasTextValue() {
    switch (this) {
      case FileCondition.downloadUrlContains:
      case FileCondition.fileNameContains:
      case FileCondition.fileExtensionIs:
        return true;
      case FileCondition.fileSizeLessThan:
      case FileCondition.fileSizeGreaterThan:
        return false;
    }
  }

  String toReadable() {
    switch (this) {
      case FileCondition.fileNameContains:
        return "File name contains";
      case FileCondition.fileSizeGreaterThan:
        return "File size greater than";
      case FileCondition.fileSizeLessThan:
        return "File size less than";
      case FileCondition.fileExtensionIs:
        return "File extension is";
      case FileCondition.downloadUrlContains:
        return "Download URL contains";
    }
  }
}
