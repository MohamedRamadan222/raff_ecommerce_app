import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:raff_app/core/router/app_routes.dart';
import 'package:raff_app/core/theme/app_colors.dart';
import 'package:raff_app/core/widgets/app_app_bar.dart';
import 'package:raff_app/core/widgets/app_button.dart';

import '../../../../core/l10n/l10n_extension.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _length = 4;
  static const _resendSeconds = 60;

  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  bool _isVerifying = false;

  bool get _isComplete =>
      _controllers.every((controller) => controller.text.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _verify() async {
    if (!_isComplete || _isVerifying) return;
    setState(() => _isVerifying = true);
    // Mock verification: in production this calls the backend with the code.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.accent;
    final accentSoft = isDark ? AppColors.darkAccentSoft : AppColors.accentSoft;
    final muted = isDark ? AppColors.darkMuted : AppColors.muted;

    return Scaffold(
      appBar: AppAppBar(title: l10n.otpTitle, showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.shield_outlined, size: 30, color: accent),
              ),
              Text(
                l10n.otpHead,
                style: tt.headlineSmall!.copyWith(
                  fontSize: 24,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                l10n.otpSub,
                style: tt.bodyMedium!.copyWith(
                  fontSize: 15,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Gap(24),
              // خانات الكود دايمًا LTR زي الديزاين
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    for (var i = 0; i < _length; i++) ...[
                      if (i > 0) const Gap(12),
                      Expanded(
                        child: _OtpBox(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          onChanged: (value) {
                            if (value.isNotEmpty && i < _length - 1) {
                              _focusNodes[i + 1].requestFocus();
                            } else if (value.isEmpty && i > 0) {
                              _focusNodes[i - 1].requestFocus();
                            }
                            setState(() {});
                            if (_isComplete && i == _length - 1) {
                              FocusScope.of(context).unfocus();
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: Text(
                  l10n.otpMockHint,
                  textAlign: TextAlign.center,
                  style: tt.bodySmall!.copyWith(fontSize: 12, color: muted),
                ),
              ),
              const Gap(4),
              SizedBox(
                width: double.infinity,
                child: _secondsLeft > 0
                    ? Text(
                        '${l10n.resendIn} ${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                        textAlign: TextAlign.center,
                        style: tt.bodySmall!.copyWith(
                          fontSize: 12,
                          color: muted,
                        ),
                      )
                    : Center(
                        child: GestureDetector(
                          onTap: () {
                            _startTimer();
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(l10n.otpSent),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              l10n.resendNow,
                              style: tt.bodySmall!.copyWith(
                                fontSize: 13,
                                color: accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              const Gap(16),
              AppButton(
                label: l10n.verify,
                isLoading: _isVerifying,
                onPressed: _isComplete ? _verify : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineStrong = isDark ? AppColors.darkLineStrong : AppColors.lineStrong;
    final ink = isDark ? AppColors.darkInk : AppColors.ink;

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );

    return SizedBox(
      height: 64,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: cs.surface,
          contentPadding: EdgeInsets.zero,
          border: border(lineStrong),
          enabledBorder: border(lineStrong),
          focusedBorder: border(ink),
        ),
      ),
    );
  }
}
