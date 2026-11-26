import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/widgets/app_button.dart';
import 'package:raff_app/core/widgets/app_text_field.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:raff_app/features/addresses/presentation/widgets/address_card.dart';

class AddressFormSheet extends StatefulWidget {
  final AddressEntity? existing;

  const AddressFormSheet({super.key, this.existing});

  static Future<bool?> show(BuildContext context, {AddressEntity? existing}) {
    final cs = Theme.of(context).colorScheme;
    // الشيت بتفتح في route جديد فوق الـ BlocProvider بتاع الشاشة،
    // فبنمررله نفس الـ cubit بـ BlocProvider.value
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AddressesCubit>(),
        child: AddressFormSheet(existing: existing),
      ),
    );
  }

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late AddressLabel _label;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _addressController = TextEditingController(text: existing?.fullAddress);
    _phoneController = TextEditingController(text: existing?.phone);
    _label = existing?.label ?? AddressLabel.home;
    _isDefault = existing?.isDefault ?? false;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        // viewInsets بترفع الشيت فوق الكيبورد لما يفتح
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existing == null ? l10n.addAddress : l10n.editAddress,
                  style: tt.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                const Gap(16),

                Text(l10n.addressLabel, style: tt.labelMedium),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final label in AddressLabel.values)
                      ChoiceChip(
                        label: Text(addressLabelText(l10n, label)),
                        selected: _label == label,
                        onSelected: (_) => setState(() => _label = label),
                      ),
                  ],
                ),
                const Gap(16),

                AppTextField(
                  label: l10n.addressDetails,
                  hint: l10n.addressDetailsHint,
                  controller: _addressController,
                  prefixIcon: Icons.location_on_outlined,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.fieldRequired
                      : null,
                ),
                const Gap(12),

                AppTextField(
                  label: l10n.phoneNumber,
                  hint: '5X XXX XXXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.fieldRequired
                      : null,
                ),
                const Gap(8),

                CheckboxListTile(
                  value: _isDefault,
                  onChanged: (value) =>
                      setState(() => _isDefault = value ?? false),
                  title: Text(l10n.setAsDefault, style: tt.bodyMedium),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const Gap(12),

                SizedBox(
                  width: double.infinity,
                  child: AppButton(label: l10n.saveAddress, onPressed: _save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final address = AddressEntity(
      id:
          widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      label: _label,
      fullAddress: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      isDefault: _isDefault,
    );

    if (widget.existing == null) {
      context.read<AddressesCubit>().addAddress(address);
    } else {
      context.read<AddressesCubit>().updateAddress(address);
    }
    Navigator.of(context).pop(true);
  }
}
