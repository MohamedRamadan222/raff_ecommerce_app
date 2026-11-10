import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? prefix;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.prefix,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(widget.label, style: theme.textTheme.labelMedium),
        ),
        Gap(8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _hidden,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: 20),
            prefix: widget.prefix == null
                ? null
                : Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: widget.prefix,
                  ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _hidden ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
