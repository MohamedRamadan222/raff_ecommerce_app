import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raff_app/app.dart';
import 'package:raff_app/core/di/injection.dart';
import 'package:raff_app/core/session/session_cubit.dart';
import 'package:raff_app/core/storage/preferences_service.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:raff_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:raff_app/features/catalog/presentation/cubit/home_cubit.dart';
import 'package:raff_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:raff_app/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:raff_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:raff_app/features/settings/presentation/cubit/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpGetIt();

  final prefsServices = sl<PreferencesService>();
  final savedTheme = await prefsServices.loadThemeMode();
  final savedLang = await prefsServices.loadLanguageCode();

  final initialState = SettingsState(
    locale: Locale(savedLang),
    themeMode: ThemeMode.values.byName(savedTheme),
  );

  final session = sl<SessionCubit>();
  await session.restore();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider(create: (_) => SettingsCubit(prefsServices, initialState)),
        BlocProvider(create: (_) => sl<AddressesCubit>()..loadAddresses()),
        BlocProvider(create: (_) => sl<HomeCubit>()..loadHomeData()),
        BlocProvider(create: (_) => sl<FavoritesCubit>()..loadFavorites()),
        BlocProvider(create: (_) => sl<CartCubit>()..loadCart()),
        BlocProvider(create: (_) => sl<OrdersCubit>()..loadOrders()),
        BlocProvider(create: (_) => sl<NotificationsCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}
