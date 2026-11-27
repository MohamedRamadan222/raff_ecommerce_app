import 'package:raff_app/features/catalog/domain/repositories/catalog_repository.dart';

/// Clears the catalog repository cache so pull-to-refresh reaches the network.
class InvalidateCatalogCacheUseCase {
  final CatalogRepository _repository;

  const InvalidateCatalogCacheUseCase(this._repository);

  void call() => _repository.invalidateCache();
}
