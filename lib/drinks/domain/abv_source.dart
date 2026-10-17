import '../../l10n/l10n.dart';

/// Where the ABV of an outing item or of a record came from. Kept next to the
/// value so a corrected ABV is never mistaken for the official one.
enum AbvSource {
  /// Read from a label photo and confirmed by the user.
  photoLabel('label'),

  /// Written in a menu photo and confirmed by the user.
  menu('menu'),

  /// Typed or corrected by the user.
  typed('typed'),

  /// Copied from a catalog product.
  catalog('catalog');

  const AbvSource(this.code);

  /// Stored value; never translated.
  final String code;

  String get label => switch (this) {
    AbvSource.photoLabel => tr.abvSourceLabel,
    AbvSource.menu => tr.abvSourceMenu,
    AbvSource.typed => tr.abvSourceTyped,
    AbvSource.catalog => tr.abvSourceCatalog,
  };

  static AbvSource? fromCode(String? code) {
    for (final s in AbvSource.values) {
      if (s.code == code) return s;
    }
    return null;
  }
}
