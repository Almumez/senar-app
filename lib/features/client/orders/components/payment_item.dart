import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/utils/extensions.dart';

import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';

class OrderPaymentItem extends StatelessWidget {
  const OrderPaymentItem({
    super.key,
    required this.data,
  });

  final ClientOrderModel data;

  @override
  Widget build(BuildContext context) {
    if (data.paymentMethod == '') return const SizedBox();
    
    String paymentText = data.paymentMethod.toLowerCase() == 'cash' ? "كاش" : "الكتروني";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 32.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/cash.svg',
                height: 20.h,
                width: 20.w,
                colorFilter: ColorFilter.mode(
                  context.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                paymentText, 
                style: context.mediumText.copyWith(fontSize: 14.sp)
              ),
            ],
          ),
        ),
      ],
    );
  }
}
