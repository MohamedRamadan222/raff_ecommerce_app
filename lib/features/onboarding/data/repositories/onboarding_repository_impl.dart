import 'package:raff_app/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:raff_app/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource _localDataSource;

  const OnboardingRepositoryImpl(this._localDataSource);

  @override
  Future<void> setOnboardingSeen() => _localDataSource.cacheOnboardingSeen();

  @override
  bool isOnboardingSeen() => _localDataSource.getOnboardingSeen();
}
