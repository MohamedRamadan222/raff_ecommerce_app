import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/errors/failure_message.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';
import 'package:raff_app/core/widgets/app_button.dart';
import 'package:raff_app/core/widgets/app_text_field.dart';
import 'package:raff_app/features/auth/presentation/cubit/login_cubit.dart';
import 'package:raff_app/features/auth/presentation/cubit/login_state.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<LoginCubit>().login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.failure.message(context)),
                    backgroundColor: cs.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            } else if (state is LoginSuccess) {
              context.go(AppRoutes.home);
            }
          },
          builder: (context, state) {
            final isLoading = state is LoginLoading;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Text(
                            'رَفّ',
                            style: tt.headlineLarge!.copyWith(
                              fontFamily: 'ReemKufi',
                              fontSize: 32,
                              height: 1.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Gap(28),

                        Text(
                          l10n.loginTitle,
                          style: tt.headlineMedium!.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          l10n.loginSubtitle,
                          style: tt.bodyMedium!.copyWith(
                            fontSize: 15,
                            color: cs.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                        const Gap(28),

                        AppTextField(
                          label: l10n.email,
                          hint: 'moram@elsoudi.sh',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.fieldRequired
                              : null,
                        ),
                        const Gap(20),

                        AppTextField(
                          label: l10n.password,
                          hint: '••••••••',
                          controller: _passwordCtrl,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.fieldRequired
                              : null,
                        ),
                        const Gap(12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () =>
                                  setState(() => _rememberMe = !_rememberMe),
                              borderRadius: BorderRadius.circular(8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (val) => setState(
                                        () => _rememberMe = val ?? false,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      activeColor: cs.onSurface,
                                      checkColor: cs.surface,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    l10n.rememberMe,
                                    style: tt.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                foregroundColor: cs.onSurface.withValues(
                                  alpha: 0.65,
                                ),
                              ),
                              child: Text(
                                l10n.forgotPassword,
                                style: tt.bodySmall!.copyWith(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const Gap(24),

                        AppButton(
                          label: l10n.loginButton,
                          isLoading: isLoading,
                          onPressed: () => _onLoginPressed(context),
                        ),
                        const Gap(24),

                        Row(
                          children: [
                            Expanded(child: Divider(color: theme.dividerColor)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                l10n.orDivider,
                                style: tt.bodySmall!.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: theme.dividerColor)),
                          ],
                        ),
                        const Gap(24),

                        _SocialAuthButton(
                          icon: Icons.apple,
                          label: l10n.continueWithApple,
                          onPressed: () {},
                        ),
                        const Gap(12),
                        _SocialAuthButton(
                          icon: Icons.g_mobiledata_rounded,
                          label: l10n.continueWithGoogle,
                          onPressed: () {},
                        ),
                        const Gap(42),

                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              l10n.dontHaveAccount,
                              style: tt.bodyMedium!.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.65),
                              ),
                            ),

                            GestureDetector(
                              onTap: () => context.push(AppRoutes.register),
                              child: Text(
                                l10n.createAccount,
                                style: tt.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
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
        ),
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialAuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final inputTheme = theme.inputDecorationTheme;

    final defaultBorder = inputTheme.enabledBorder is OutlineInputBorder
        ? inputTheme.enabledBorder as OutlineInputBorder
        : null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: inputTheme.fillColor,
          side:
              defaultBorder?.borderSide ??
              BorderSide(color: theme.dividerColor),
          shape: RoundedRectangleBorder(
            borderRadius:
                defaultBorder?.borderRadius ?? BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: cs.onSurface),
            const Gap(10),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: tt.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
