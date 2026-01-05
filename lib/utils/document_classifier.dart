class DocumentClassifier {
  static String detect(String text) {
    final t = text.toLowerCase();

    if (t.contains("insurance") || t.contains("policy")) {
      return "insurance";
    }
    if (t.contains("registration") || t.contains("reg no")) {
      return "rc";
    }
    if (t.contains("driving licence") || t.contains("dl no")) {
      return "dl";
    }
    if (t.contains("pollution") || t.contains("puc")) {
      return "puc";
    }
    return "others";
  }
}
