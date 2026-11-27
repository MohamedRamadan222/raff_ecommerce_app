import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:raff_app/features/addresses/data/models/address_model.dart';

abstract class AddressesLocalDataSource {
  List<AddressModel> getAddresses();

  Future<List<AddressModel>> addAddress(AddressModel address);

  Future<List<AddressModel>> updateAddress(AddressModel address);

  Future<List<AddressModel>> deleteAddress(String id);

  Future<List<AddressModel>> setDefaultAddress(String id);

  Future<void> clearAll();
}

class AddressesLocalDataSourceImpl implements AddressesLocalDataSource {
  final Box<String> box;

  AddressesLocalDataSourceImpl(this.box);

  /// العناوين بترتيب الـ Box عشان ما نفكش الـ JSON غير مرة واحدة.
  List<AddressModel>? _addressesCache;

  void _ensureLoaded() {
    if (_addressesCache != null) return;
    final addresses = <AddressModel>[];
    for (final raw in box.values) {
      // أي عنوان قديم أو بايظ بنتخطاه بدل ما الشاشة كلها تقع
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        addresses.add(AddressModel.fromJson(map));
      } catch (_) {
        continue;
      }
    }
    _addressesCache = addresses;
  }

  List<AddressModel> get _addresses {
    _ensureLoaded();
    return _addressesCache!;
  }

  List<AddressModel> _snapshot() {
    return List<AddressModel>.unmodifiable(_addresses);
  }

  @override
  List<AddressModel> getAddresses() => _snapshot();

  @override
  Future<List<AddressModel>> addAddress(AddressModel address) async {
    final addresses = _addresses;
    // أول عنوان بيتحفظ بيبقى افتراضي تلقائيًا
    final isFirst = addresses.isEmpty;
    final toSave = isFirst ? _copyWithDefault(address, true) : address;
    if (toSave.isDefault) {
      await _clearDefault();
    }

    final index = addresses.indexWhere((a) => a.id == toSave.id);
    if (index >= 0) {
      addresses[index] = toSave;
    } else {
      addresses.add(toSave);
    }
    await box.put(toSave.id, jsonEncode(toSave.toJson()));
    return _snapshot();
  }

  @override
  Future<List<AddressModel>> updateAddress(AddressModel address) async {
    final addresses = _addresses;
    if (address.isDefault) {
      await _clearDefault();
    }

    final index = addresses.indexWhere((a) => a.id == address.id);
    if (index >= 0) {
      addresses[index] = address;
    } else {
      addresses.add(address);
    }
    await box.put(address.id, jsonEncode(address.toJson()));
    return _snapshot();
  }

  @override
  Future<List<AddressModel>> deleteAddress(String id) async {
    _addresses.removeWhere((a) => a.id == id);
    await box.delete(id);
    return _snapshot();
  }

  @override
  Future<List<AddressModel>> setDefaultAddress(String id) async {
    await _clearDefault();
    final addresses = _addresses;
    final index = addresses.indexWhere((a) => a.id == id);
    if (index >= 0) {
      final updated = _copyWithDefault(addresses[index], true);
      addresses[index] = updated;
      await box.put(id, jsonEncode(updated.toJson()));
    }
    return _snapshot();
  }

  /// بيشيل الافتراضي من الكاش ويحفظ كل المتغيرين مرة واحدة.
  Future<void> _clearDefault() async {
    final addresses = _addresses;
    final changed = <String, String>{};
    for (var i = 0; i < addresses.length; i++) {
      final model = addresses[i];
      if (!model.isDefault) continue;
      final updated = _copyWithDefault(model, false);
      addresses[i] = updated;
      changed[updated.id] = jsonEncode(updated.toJson());
    }
    if (changed.isNotEmpty) {
      await box.putAll(changed);
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

  @override
  Future<void> clearAll() async {
    await box.clear();
    _addressesCache = <AddressModel>[];
  }
}
