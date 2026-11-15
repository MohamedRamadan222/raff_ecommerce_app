import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/widgets/app_button.dart';
import 'package:raff_app/core/widgets/app_text_field.dart';
import 'package:raff_app/features/auth/presentation/cubit/register_cubit.dart';
import 'package:raff_app/features/auth/presentation/cubit/register_state.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RegisterCubit>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _acceptedTerms = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onRegisterPressed(BuildContext context, AppLocalizations l10n) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.acceptTermsRequired),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    FocusScope.of(context).unfocus();
    final emailText = _emailCtrl.text.trim();
    context.read<RegisterCubit>().register(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      email: emailText.isEmpty ? null : emailText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.failure.message(context)),
                    backgroundColor: cs.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            } else if (state is RegisterSuccess) {
              context.go(AppRoutes.home);
            }
          },
          builder: (context, state) {
            final isLoading = state is RegisterLoading;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 380;
                final horizontalPadding = isCompact ? 16.0 : 24.0;
                final fieldGap = isCompact ? 14.0 : 18.0;

                return Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20,
                      horizontalPadding,
                      24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => context.pop(),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      top: 4,
                                      bottom: 4,
                                      end: 6,
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 18,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                                const Gap(4),
                                Expanded(
                                  child: Text(
                                    l10n.createAccount,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: tt.headlineMedium!.copyWith(
                                      fontSize: isCompact ? 15 : 19,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(30),

                            Text(
                              l10n.registerSubtitle,
                              style: tt.bodyMedium!.copyWith(
                                fontSize: 14.5,
                                color: cs.onSurface.withValues(alpha: 0.65),
                              ),
                            ),
                            Gap(isCompact ? 20 : 26),
                            AppTextField(
                              label: l10n.fullName,
                              hint: l10n.fullNameHint,
                              controller: _nameCtrl,
                              keyboardType: TextInputType.name,
                              prefixIcon: Icons.person_outline_rounded,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? l10n.fieldRequired
                                  : null,
                            ),
                            Gap(fieldGap),
                            _PhoneTextField(
                              label: l10n.mobileNumber,
                              controller: _phoneCtrl,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? l10n.fieldRequired
                                  : null,
                            ),
                            Gap(fieldGap),

                            AppTextField(
                              label: l10n.emailOptional,
                              hint: 'name@example.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.mail_outline_rounded,
                            ),
                            Gap(fieldGap),

                            AppTextField(
                              label: l10n.password,
                              hint: l10n.passwordMinHint,
                              controller: _passwordCtrl,
                              obscureText: true,
                              prefixIcon: Icons.lock_outline_rounded,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return l10n.fieldRequired;
                                }
                                if (v.trim().length < 8 ||
                                    !RegExp(r'\d').hasMatch(v)) {
                                  return l10n.passwordHelper;
                                }
                                return null;
                              },
                            ),
                            const Gap(8),

                            Text(
                              l10n.passwordHelper,
                              style: tt.bodySmall!.copyWith(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                            const Gap(16),

                            InkWell(
                              onTap: () => setState(
                                () => _acceptedTerms = !_acceptedTerms,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: _acceptedTerms,
                                        onChanged: (val) => setState(
                                          () => _acceptedTerms = val ?? false,
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        activeColor: cs.onSurface,
                                        checkColor: cs.surface,
                                      ),
                                    ),
                                    const Gap(10),
                                    Expanded(
                                      child: Text(
                                        l10n.agreeTerms,
                                        style: tt.bodyMedium!.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Gap(isCompact ? 20 : 24),

                            AppButton(
                              label: l10n.createAccount,
                              isLoading: isLoading,
                              onPressed: () =>
                                  _onRegisterPressed(context, l10n),
                            ),
                            Gap(isCompact ? 31 : 37),

                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                Text(
                                  l10n.alreadyHaveAccount,
                                  style: tt.bodyMedium!.copyWith(
                                    fontSize: 13.5,
                                    color: cs.onSurface.withValues(alpha: 0.65),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Text(
                                    l10n.loginButton,
                                    style: tt.bodyMedium!.copyWith(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PhoneTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const _PhoneTextField({
    required this.label,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const Gap(8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          textAlign: isRtl ? TextAlign.right : TextAlign.left,
          validator: validator,
          style: tt.bodyMedium,
          decoration: InputDecoration(
            hintText: '5X XXX XXXX',
            hintTextDirection: TextDirection.ltr,
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 14, end: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.smartphone_outlined,
                    size: 20,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                  Container(
                    height: 20,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: theme.dividerColor,
                  ),
                  Text(
                    '+966',
                    textDirection: TextDirection.ltr,
                    style: tt.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
        ),
      ],
    );
  }
}
