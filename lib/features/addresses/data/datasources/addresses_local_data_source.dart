import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:raff_app/features/addresses/data/models/address_model.dart';

abstract class AddressesLocalDataSource {
  List<AddressModel> getAddresses();

  Future<List<AddressModel>> addAddress(AddressModel address);

  Future<List<AddressModel>> updateAddress(AddressModel address);

  Future<List<AddressModel>> deleteAddress(String id);

  Future<List<AddressModel>> setDefaultAddress(String id);
}

class AddressesLocalDataSourceImpl implements AddressesLocalDataSource {
  final Box<String> box;

  AddressesLocalDataSourceImpl(this.box);

  @override
  List<AddressModel> getAddresses() {
    final addresses = <AddressModel>[];
    for (final key in box.keys) {
      // أي عنوان قديم أو بايظ بنتخطاه بدل ما الشاشة كلها تقع
      try {
        final raw = box.get(key);
        if (raw == null) continue;
        final map = jsonDecode(raw) as Map<String, dynamic>;
        addresses.add(AddressModel.fromJson(map));
      } catch (_) {
        continue;
      }
    }
    return addresses;
  }

  @override
  Future<List<AddressModel>> addAddress(AddressModel address) async {
    // أول عنوان بيتحفظ بيبقى افتراضي تلقائيًا
    final isFirst = box.isEmpty;
    final toSave = isFirst ? _copyWithDefault(address, true) : address;
    if (toSave.isDefault) {
      await _clearDefault();
    }
    await box.put(toSave.id, jsonEncode(toSave.toJson()));
    return getAddresses();
  }

  @override
  Future<List<AddressModel>> updateAddress(AddressModel address) async {
    if (address.isDefault) {
      await _clearDefault();
    }
    await box.put(address.id, jsonEncode(address.toJson()));
    return getAddresses();
  }

  @override
  Future<List<AddressModel>> deleteAddress(String id) async {
    await box.delete(id);
    return getAddresses();
  }

  @override
  Future<List<AddressModel>> setDefaultAddress(String id) async {
    await _clearDefault();
    final raw = box.get(id);
    if (raw != null) {
      final model = AddressModel.fromJson(jsonDecode(raw));
      final updated = _copyWithDefault(model, true);
      await box.put(id, jsonEncode(updated.toJson()));
    }
    return getAddresses();
  }

  Future<void> _clearDefault() async {
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw == null) continue;
      final AddressModel model;
      try {
        model = AddressModel.fromJson(jsonDecode(raw));
      } catch (_) {
        continue;
      }
      if (model.isDefault) {
        final updated = _copyWithDefault(model, false);
        await box.put(key, jsonEncode(updated.toJson()));
      }
    }
  }

  AddressModel _copyWithDefault(AddressModel model, bool isDefault) {
    return AddressModel(
      id: model.id,
      label: model.label,
      fullAddress: model.fullAddress,
      phone: model.phone,
      isDefault: isDefault,
    );
  }
}
