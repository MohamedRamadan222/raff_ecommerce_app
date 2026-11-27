import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/features/account/presentation/widgets/account_tile.dart';
import 'package:raff_app/features/account/presentation/widgets/design_switch.dart';
import 'package:raff_app/features/account/presentation/widgets/language_sheet.dart';
import 'package:raff_app/features/account/presentation/widgets/tiles_card.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_state.dart';

class PreferencesCard extends StatelessWidget {
  const PreferencesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final isArabic = settingsState.locale.languageCode == 'ar';
        final isDark = settingsState.themeMode == ThemeMode.dark;

        return TilesCard(
          children: [
            AccountTile(
              icon: Icons.language_rounded,
              title: l10n.language,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isArabic ? l10n.arabic : l10n.english,
                    style: tt.bodyMedium!.copyWith(
                      fontSize: 14,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const Gap(4),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
              onTap: () => LanguageSheet.show(context),
            ),
            AccountTile(
              icon: Icons.dark_mode_outlined,
              title: l10n.darkMode,
              trailing: DesignSwitch(
                value: isDark,
                onChanged: (value) => context.read<SettingsCubit>().changeTheme(
                  value ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
              onTap: () => context.read<SettingsCubit>().changeTheme(
                isDark ? ThemeMode.light : ThemeMode.dark,
              ),
            ),
          ],
        );
      },
    );
  }
}
