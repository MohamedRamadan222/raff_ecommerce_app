import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raff_app/core/storage/preferences_service.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_state.dart';

import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefsServices = PreferencesService();
  final savedTheme = await prefsServices.loadThemeMode();
  final savedLang = await prefsServices.loadLanguageCode();
  final initialState = SettingsState(
    locale: Locale(savedLang),
    themeMode: ThemeMode.values.byName(savedTheme),
  );
  runApp(
    BlocProvider(
      create: (_) => SettingsCubit(prefsServices, initialState),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: state.locale,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.themeMode,
          home: const Scaffold(),
        );
      },
    );
  }
}
