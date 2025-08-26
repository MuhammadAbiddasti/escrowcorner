class EscrowCategory {
  final int id;
  final String title;
  final String fr;
  final String status;

  EscrowCategory({required this.id, required this.title, required this.fr, required this.status});

  factory EscrowCategory.fromJson(Map<String, dynamic> json) {
    return EscrowCategory(
      id: json['id'],
      title: json['title'] ?? '',
      fr: json['fr'] ?? '',
      status: json['status'],
    );
  }

  // Get localized title based on current language
  String getLocalizedTitle(String locale) {
    if (locale == 'fr') {
      return fr.isNotEmpty ? fr : title; // Fallback to English if French is empty
    }
    return title; // Default to English
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EscrowCategory &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
