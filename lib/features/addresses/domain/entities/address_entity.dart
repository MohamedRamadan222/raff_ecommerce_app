import 'package:equatable/equatable.dart';

enum AddressLabel { home, work, other }

class AddressEntity extends Equatable {
  final String id;
  final AddressLabel label;
  final String fullAddress;
  final String phone;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.phone,
    this.isDefault = false,
  });

  /// عنوان مختصر بيظهر في الأماكن الضيقة زي هيدر الصفحة الرئيسية:
  /// بيرجع أول جزء من العنوان (قبل أول فاصلة).
  String get shortTitle {
    final first = fullAddress.split(RegExp(r'[،,]')).first.trim();
    return first.isNotEmpty ? first : fullAddress;
  }

  AddressEntity copyWith({
    String? id,
    AddressLabel? label,
    String? fullAddress,
    String? phone,
    bool? isDefault,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [id, label, fullAddress, phone, isDefault];
}
