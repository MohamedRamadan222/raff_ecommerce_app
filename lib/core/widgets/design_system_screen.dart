import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/widgets/product_card.dart';
import 'package:raff_app/core/widgets/section_header.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_cubit.dart';

import '../theme/app_colors.dart';
import 'app_app_bar.dart';
import 'app_search_field.dart';


class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    final isDark = cubit.state.themeMode == ThemeMode.dark;
    final isAr = cubit.state.locale.languageCode == 'ar';
    bool isCardFav = false;

    return Scaffold(
      appBar: AppAppBar(
        title: 'مساء الخير، سارة',
        customSubtitle: Column(
          children: [
            Gap(5),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 4),
                Text(
                  'التوصيل إلى المنزل، الرياض',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                  color: AppColors.muted,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 16,
          children: [

            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: () => cubit.changeTheme(
                isDark ? ThemeMode.light : ThemeMode.dark,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: () => cubit.changeLanguage(isAr ? 'en' : 'ar'),
            ),
            const SizedBox(height: 24),
            Text('Section Header', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            const SectionHeader(
              title: 'مجموعة الشتاء',
            ),

            const SizedBox(height: 16),

            SectionHeader(
              title: 'الأكثر شيوعاً',
              actionText: 'عرض الكل',
              onActionTap: () {
                debugPrint('فتح شاشة الأكثر شيوعاً');
              },
            ),
            const SizedBox(height: 50),

            const SizedBox(height: 16),

            AppSearchField(
              hintText: 'ابحث عن مزهرية، شمعة، مصباح...',
              isOutline: true,
              autofocus: false,
              onChanged: (value) {
                debugPrint('يبحث عن: $value');
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
