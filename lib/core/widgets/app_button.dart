import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isText;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isText = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isText
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          )
        : Text(label);
    final action = isLoading ? null : onPressed;
    if (isText) {
      return TextButton(onPressed: action, child: child);
    }
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(onPressed: action, child: child),
    );
  }
}
