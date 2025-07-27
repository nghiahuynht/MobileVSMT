import 'package:flutter/material.dart';
import 'package:trash_pay/constants/colors.dart';

class XCircularProgressIndicator extends StatelessWidget {
  const XCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
    ));
  }
}
