import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../models/technician_order.dart';

import '../../../../gen/locale_keys.g.dart';

class TechnicianOrderPaymentItem extends StatelessWidget {
  const TechnicianOrderPaymentItem({
    super.key,
    required this.data,
  });

  final TechnicianOrderModel data;

  @override
  Widget build(BuildContext context) {
    if (data.paymentMethod == '') return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ${LocaleKeys.payment_method.tr()}", style: context.mediumText.copyWith(fontSize: 20)).withPadding(bottom: 10.h),
        Container(
          width: context.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: Color(0xfff5f5f5)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.paymentMethod == '' ? LocaleKeys.no_payment.tr() : data.paymentMethod, style: context.mediumText.copyWith(fontSize: 14)),
            ],
          ),
        ).withPadding(bottom: 16),
      ],
    );
  }
}
