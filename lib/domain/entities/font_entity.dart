/// Domain entity representing font configuration
/// Following clean architecture principles - this is pure business logic
class FontEntity {
  final String fontFamily;
  final String displayName;

  const FontEntity({
    required this.fontFamily,
    required this.displayName,
  });

  FontEntity copyWith({
    String? fontFamily,
    String? displayName,
  }) {
    return FontEntity(
      fontFamily: fontFamily ?? this.fontFamily,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FontEntity &&
        other.fontFamily == fontFamily &&
        other.displayName == displayName;
  }

  @override
  int get hashCode {
    return fontFamily.hashCode ^ displayName.hashCode;
  }

  @override
  String toString() {
    return 'FontEntity(fontFamily: $fontFamily, displayName: $displayName)';
  }
}
