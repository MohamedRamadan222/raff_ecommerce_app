/// Rules for cart promo codes: the only supported code and its discount.
abstract final class PromoCodePolicy {
  static const String supportedCode = 'RAFF10';
  static const double discountRate = 0.10;

  /// Canonical form used for storage and comparisons.
  static String normalize(String raw) => raw.trim().toUpperCase();

  /// Whether [normalized] (see [normalize]) is a supported promo code.
  static bool isValid(String normalized) => normalized == supportedCode;

  /// Discount for [code] on [subtotal]; zero when the code is missing or
  /// unsupported.
  static double discountFor(String? code, double subtotal) {
    if (code == null) return 0.0;

    final normalized = normalize(code);
    if (!isValid(normalized)) return 0.0;

    return subtotal * discountRate;
  }
}
