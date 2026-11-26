import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_state.dart';

class LanguageSheet extends StatelessWidget {
  const LanguageSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => const LanguageSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final currentCode = state.locale.languageCode;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.language,
                  style: tt.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                const Gap(8),
                _LanguageOption(
                  label: l10n.arabic,
                  isSelected: currentCode == 'ar',
                  onTap: () => _select(context, 'ar'),
                ),
                _LanguageOption(
                  label: l10n.english,
                  isSelected: currentCode == 'en',
                  onTap: () => _select(context, 'en'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _select(BuildContext context, String code) {
    // السطر ده بيغير لغة التطبيق كله لحظيًا ويحفظها في SharedPreferences
    context.read<SettingsCubit>().changeLanguage(code);
    Navigator.of(context).pop();
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: tt.bodyLarge!.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: cs.primary) : null,
      onTap: onTap,
    );
  }
}
