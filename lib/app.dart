import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/router/app_router.dart';
import 'package:raff_app/core/theme/app_theme.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_state.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          // todo for test ar && light mode
          themeMode: ThemeMode.light, // مؤقت للتغلير
          locale: const Locale('ar'),
          // locale: state.locale,
          // themeMode: state.themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
        );
      },
    );
  }
}
