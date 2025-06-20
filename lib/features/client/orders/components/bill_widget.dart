import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';

class ClientBillWidget extends StatelessWidget {
  final ClientOrderModel data;

  const ClientBillWidget({super.key, required this.data});

  bool get isMaintenanceOrSupply => data.type == 'maintenance' || data.type == 'supply';

  @override
  Widget build(BuildContext context) {
    if (data.price == 0) return const SizedBox();

    return Container(
      width: MediaQuery.of(context).size.width - 32.w,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceRow(context, data.price).withPadding(start: 15.w),
          if (isMaintenanceOrSupply) _buildRow(LocaleKeys.check_fee.tr(), data.checkFee, context).withPadding(start: 30.w),
          if (!isMaintenanceOrSupply) _buildRow("توصيل", data.deliveryFee, context).withPadding(start: 43.w),
          if (!isMaintenanceOrSupply) _buildRow("ضريبة", data.tax, context).withPadding(start: 43.w),
          if (isMaintenanceOrSupply) _buildRow("ضريبة", data.tax, context).withPadding(start: 43.w),
        
          _buildRow("اجمالي", data.totalPrice, context).withPadding(start: 43.w),
        ],
      ),
    );
  }

  Widget _buildServiceRow(BuildContext context, num value) {
    // Format the number to remove decimal places if they're zeros
    String formattedValue = value.toStringAsFixed(2);
    if (formattedValue.endsWith('.00')) {
      formattedValue = value.toInt().toString();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/pay.svg',
                  height: 20.h,
                  width: 20.w,
                  colorFilter: ColorFilter.mode(
                    context.primaryColor,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  "خدمة",
                  style: context.mediumText.copyWith(
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: formattedValue,
                style: context.mediumText.copyWith(
                  fontSize: 14.sp,
                ),
              ),
              TextSpan(
                text: " ${LocaleKeys.sar.tr()}",
                style: context.mediumText.copyWith(
                  fontSize: 14.sp,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, num value, BuildContext context, {bool isBold = false}) {
    // Format the number to remove decimal places if they're zeros
    String formattedValue = value.toStringAsFixed(2);
    if (formattedValue.endsWith('.00')) {
      formattedValue = value.toInt().toString();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              title,
              style: context.mediumText.copyWith(
                fontSize: 14.sp,
              ),
            ),
          ),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: formattedValue,
                style: context.mediumText.copyWith(
                  fontSize: 14.sp,
                ),
              ),
              TextSpan(
                text: " ${LocaleKeys.sar.tr()}",
                style: context.mediumText.copyWith(
                  fontSize: 14.sp,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
