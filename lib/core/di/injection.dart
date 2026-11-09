import 'package:get_it/get_it.dart';
import 'package:raff_app/core/storage/preferences_service.dart';

import '../network/dio_clint.dart';

final sl = GetIt.instance;

void init() {
  sl.registerLazySingleton(() => PreferencesService());
  sl.registerLazySingleton(() => DioClint());
}
