/// Feed post'unun medya tipini temsil eden enum.
enum MediaType {
  image,
  video;

  /// JSON/string'den parse eder.
  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MediaType.image,
    );
  }
}
