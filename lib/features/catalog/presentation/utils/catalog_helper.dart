import 'package:flutter/material.dart';

abstract final class CatalogHelper {
  static String localizeCategory(
    BuildContext context, {
    required String slug,
    String? fallbackName,
  }) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final key = slug.trim().toLowerCase();

    const arMap = <String, String>{
      'beauty': 'تجميل',
      'fragrances': 'عطور',
      'furniture': 'أثاث',
      'groceries': 'بقالة',
      'home-decoration': 'ديكور',
      'kitchen-accessories': 'المطبخ',
      'laptops': 'لابتوب',
      'mens-shirts': 'قمصان',
      'mens-shoes': 'أحذية رجالي',
      'mens-watches': 'ساعات رجالي',
      'mobile-accessories': 'إكسسوارات',
      'motorcycle': 'دراجات',
      'skin-care': 'العناية بالبشرة',
      'smartphones': 'هواتف',
      'sports-accessories': 'رياضة',
      'sunglasses': 'نظارات',
      'tablets': 'تابلت',
      'tops': 'ملابس',
      'vehicle': 'سيارات',
      'womens-bags': 'حقائب',
      'womens-dresses': 'فساتين',
      'womens-jewellery': 'مجوهرات',
      'womens-shoes': 'أحذية نسائي',
      'womens-watches': 'ساعات نسائي',
    };

    const enMap = <String, String>{
      'home-decoration': 'Home Decor',
      'kitchen-accessories': 'Kitchen',
      'mobile-accessories': 'Accessories',
      'sports-accessories': 'Sports',
    };

    if (isAr) {
      return arMap[key] ?? fallbackName ?? slug;
    }
    return enMap[key] ?? fallbackName ?? _titleCase(slug);
  }

  static IconData categoryIcon(String slug) {
    final s = slug.toLowerCase();
    if (s.contains('furniture')) return Icons.chair_rounded;
    if (s.contains('decoration')) return Icons.local_florist_rounded;
    if (s.contains('kitchen')) return Icons.soup_kitchen_rounded;
    if (s.contains('light') || s.contains('lamp')) return Icons.light_rounded;
    if (s.contains('smartphones') || s.contains('phone')) {
      return Icons.smartphone_rounded;
    }
    if (s.contains('mobile-accessories')) return Icons.headphones_rounded;
    if (s.contains('laptop')) return Icons.laptop_mac_rounded;
    if (s.contains('tablet')) return Icons.tablet_mac_rounded;
    if (s.contains('fragrance')) return Icons.auto_awesome_rounded;
    if (s.contains('beauty') || s.contains('skin')) return Icons.spa_rounded;
    if (s.contains('groceries')) return Icons.local_grocery_store_rounded;
    if (s.contains('watch')) return Icons.watch_rounded;
    if (s.contains('shoe')) return Icons.hiking_rounded;
    if (s.contains('bag')) return Icons.shopping_bag_rounded;
    if (s.contains('sunglasses')) return Icons.visibility_rounded;
    if (s.contains('jewellery')) return Icons.diamond_outlined;
    if (s.contains('shirt') || s.contains('dress') || s.contains('top')) {
      return Icons.checkroom_rounded;
    }
    if (s.contains('sport')) return Icons.sports_basketball_rounded;
    if (s.contains('vehicle') || s.contains('motorcycle')) {
      return Icons.directions_car_outlined;
    }
    return Icons.grid_view_rounded;
  }

  static String _titleCase(String text) {
    return text
        .split('-')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
