import 'package:raff_app/core/l10n/app_localizations.dart';

enum ProductSortOption { popular, priceLowToHigh, priceHighToLow, highestRated }

extension ProductSortOptionX on ProductSortOption {
  String label(AppLocalizations l10n) => switch (this) {
    ProductSortOption.popular => l10n.sortPopular,
    ProductSortOption.priceLowToHigh => l10n.sortPriceLow,
    ProductSortOption.priceHighToLow => l10n.sortPriceHigh,
    ProductSortOption.highestRated => l10n.sortRating,
  };
}
