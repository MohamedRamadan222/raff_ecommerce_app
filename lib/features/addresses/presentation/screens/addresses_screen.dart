import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/l10n_extension.dart';
import 'package:raff_app/core/widgets/app_app_bar.dart';
import 'package:raff_app/core/widgets/dashed_add_button.dart';
import 'package:raff_app/core/widgets/empty_view.dart';
import 'package:raff_app/core/widgets/error_view.dart';
import 'package:raff_app/core/widgets/loading_view.dart';
import 'package:raff_app/features/addresses/domain/entities/address_entity.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:raff_app/features/addresses/presentation/cubit/addresses_state.dart';
import 'package:raff_app/features/addresses/presentation/widgets/address_card.dart';
import 'package:raff_app/features/addresses/presentation/widgets/address_form_sheet.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بنستخدم الـ AddressesCubit العام من main.dart، فأي تغيير هنا
    // (اختيار عنوان افتراضي مثلًا) بيظهر في الهوم هيدر على طول
    return const _AddressesView();
  }
}

class _AddressesView extends StatelessWidget {
  const _AddressesView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppAppBar(title: l10n.addresses, showBackButton: true),
      body: BlocBuilder<AddressesCubit, AddressesState>(
        builder: (context, state) {
          if (state.status == AddressesStatus.loading &&
              state.addresses.isEmpty) {
            return const LoadingView();
          }

          if (state.status == AddressesStatus.failure &&
              state.addresses.isEmpty &&
              state.failure != null) {
            return ErrorView(
              message: state.failure!.message(context),
              onRetry: () => context.read<AddressesCubit>().loadAddresses(),
            );
          }

          if (state.addresses.isEmpty) {
            return EmptyView(
              title: l10n.emptyAddressesTitle,
              subtitle: l10n.emptyAddressesSubtitle,
              icon: Icons.location_on_outlined,
              buttonText: l10n.addAddress,
              onAction: () => _openForm(context),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              for (final address in _sortedDefaultFirst(state)) ...[
                AddressCard(
                  address: address,
                  onEditTap: () => _openForm(context, existing: address),
                  onDeleteTap: () => _delete(context, address.id),
                  onSetDefaultTap: () =>
                      context.read<AddressesCubit>().setDefault(address.id),
                ),
                const Gap(12),
              ],
              DashedAddButton(
                label: l10n.addAddress,
                onTap: () => _openForm(context),
              ),
            ],
          );
        },
      ),
    );
  }

  List<AddressEntity> _sortedDefaultFirst(AddressesState state) {
    final list = [...state.addresses];
    list.sort(
      (a, b) => b.isDefault == a.isDefault ? 0 : (b.isDefault ? 1 : -1),
    );
    return list;
  }

  Future<void> _openForm(
    BuildContext context, {
    AddressEntity? existing,
  }) async {
    final saved = await AddressFormSheet.show(context, existing: existing);
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.addressSaved)));
    }
  }

  Future<void> _delete(BuildContext context, String id) async {
    await context.read<AddressesCubit>().deleteAddress(id);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.addressDeleted)));
    }
  }
}
