import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/widgets/dashed_add_button.dart';
import 'package:raff_app/core/widgets/empty_view.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_state.dart';
import 'package:raff_app/features/addresses/presentation/widgets/address_card.dart';
import 'package:raff_app/features/addresses/presentation/widgets/address_form_sheet.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_option_card.dart';
import 'package:raff_app/features/checkout/presentation/widgets/checkout_step_title.dart';

class CheckoutAddressStep extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const CheckoutAddressStep({
    super.key,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<AddressesCubit, AddressesState>(
      builder: (context, state) {
        if (state.addresses.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(8),
              EmptyView(
                title: l10n.emptyAddressesTitle,
                subtitle: l10n.emptyAddressesSubtitle,
                icon: Icons.location_on_outlined,
                buttonText: l10n.addAddress,
                onAction: () => AddressFormSheet.show(context),
              ),
            ],
          );
        }

        // لو لسه مختارش، بنختار الافتراضي تلقائيًا — مرة واحدة بس
        final selected = selectedId ?? state.defaultAddress?.id;
        if (selectedId == null && selected != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onSelect(selected);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckoutStepTitle(l10n.whereDeliver),
            for (final address in state.addresses) ...[
              CheckoutOptionCard(
                icon: addressLabelIcon(address.label),
                title: addressLabelText(l10n, address.label),
                subtitle: address.fullAddress,
                selected: selected == address.id,
                onTap: () => onSelect(address.id),
              ),
              const Gap(12),
            ],
            DashedAddButton(
              label: l10n.addAddress,
              onTap: () => AddressFormSheet.show(context),
            ),
          ],
        );
      },
    );
  }
}
