/// Where the ABV of an outing item or of a record came from. Kept next to the
/// value so a corrected ABV is never mistaken for the official one.
enum AbvSource {
  /// Read from a label photo and confirmed by the user.
  label('label', 'Rótulo (foto), conferido por você'),

  /// Written in a menu photo and confirmed by the user.
  menu('menu', 'Cardápio (foto), conferido por você'),

  /// Typed or corrected by the user.
  typed('typed', 'Informado por você'),

  /// Copied from a catalog product.
  catalog('catalog', 'Copiado do catálogo');

  const AbvSource(this.code, this.label);

  final String code;
  final String label;

  static AbvSource? fromCode(String? code) {
    for (final s in AbvSource.values) {
      if (s.code == code) return s;
    }
    return null;
  }
}
