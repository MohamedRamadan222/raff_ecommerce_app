import 'package:raff_app/features/catalog/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({required super.name, required super.slug});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(name: json['name'] ?? '', slug: json['slug'] ?? '');
  }
}
