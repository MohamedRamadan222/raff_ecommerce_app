import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.label,
    required super.fullAddress,
    required super.phone,
    super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      // بنخزن الـ enum كاسمه النصي، ولو لقينا قيمة قديمة مش معروفة بنرجع other
      label: AddressLabel.values.firstWhere(
        (label) => label.name == json['label'],
        orElse: () => AddressLabel.other,
      ),
      fullAddress: json['fullAddress'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      id: entity.id,
      label: entity.label,
      fullAddress: entity.fullAddress,
      phone: entity.phone,
      isDefault: entity.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label.name,
      'fullAddress': fullAddress,
      'phone': phone,
      'isDefault': isDefault,
    };
  }
}
