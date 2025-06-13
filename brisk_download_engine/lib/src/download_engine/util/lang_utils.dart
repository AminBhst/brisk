extension IgnoreCase on Map<String, String> {
  bool containsKeyIgnoreCase(String key) {
    return keys.any((k) => k.toLowerCase() == key.toLowerCase());
  }
}

