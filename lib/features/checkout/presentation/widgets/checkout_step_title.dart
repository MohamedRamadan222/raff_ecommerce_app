import 'package:flutter/material.dart';

class CheckoutStepTitle extends StatelessWidget {
  final String text;

  const CheckoutStepTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge!
            .copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
