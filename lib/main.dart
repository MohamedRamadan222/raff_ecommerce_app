import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raff_app/app.dart';
import 'package:raff_app/core/di/injection.dart';
import 'package:raff_app/core/storage/preferences_service.dart';
import 'package:raff_app/features/auth/presentation/cubit/login_cubit.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpGetIt();
  // final prefs = sl<SharedPreferences>();
  // await prefs.clear();

  final prefsServices = sl<PreferencesService>();
  final savedTheme = await prefsServices.loadThemeMode();
  final savedLang = await prefsServices.loadLanguageCode();

  final initialState = SettingsState(
    locale: Locale(savedLang),
    themeMode: ThemeMode.values.byName(savedTheme),
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(prefsServices, initialState)),

        BlocProvider(create: (_) => sl<LoginCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}
