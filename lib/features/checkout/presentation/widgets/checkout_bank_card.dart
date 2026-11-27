import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raff_app/core/session/session_cubit.dart';

class CheckoutBankCard extends StatelessWidget {
  const CheckoutBankCard({super.key});

  @override
  Widget build(BuildContext context) {
    const fg = Color(0xFFF2F1EC);
    // اسم صاحب الحساب الحقيقي بدل الاسم الوهمي اللي في الديزاين
    final user = context.watch<SessionCubit>().state.user;
    final holder = user == null
        ? ''
        : '${user.firstName} ${user.lastName}'.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 152,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A3A35), Color(0xFF23231F)],
            stops: [0, 0.7],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFCDBB98), Color(0xFFA99573)],
                ),
              ),
            ),
            const Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '5241 •••• •••• 4421',
                style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(holder, style: const TextStyle(fontSize: 13, color: fg)),
                const Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '08/29',
                    style: TextStyle(fontSize: 13, color: fg),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
