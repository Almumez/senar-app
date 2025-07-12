import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/extensions.dart';

import '../../../../../core/widgets/custom_image.dart';
import '../../../../../core/widgets/custom_radius_icon.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../../../models/wallet.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel data;
  const TransactionItem({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Parse the date string to DateTime
    DateTime dateTime;
    try {
      dateTime = DateTime.parse(data.date);
    } catch (e) {
      // Fallback to current date if parsing fails
      dateTime = DateTime.now();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
      child: Row(
        children: [
          CustomRadiusIcon(
            size: 48.h,
            backgroundColor: context.canvasColor,
            child: CustomImage(Assets.svg.transactionIcon),
          ).withPadding(end: 5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.type, style: context.mediumText).withPadding(bottom: 10.h),
                Row(
                  children: [
                    Icon(Icons.calendar_month, size: 20.h, color: context.hintColor).withPadding(end: 4.w),
                    Text(DateFormat("d MMM yyyy", context.locale.languageCode).format(dateTime),
                            style: context.regularText.copyWith(fontSize: 12, color: context.hintColor))
                        .withPadding(end: 15.w),
                    Icon(Icons.access_time, size: 20.h, color: context.hintColor).withPadding(end: 4.w),
                    Text(DateFormat("hh:mm a", context.locale.languageCode).format(dateTime),
                        style: context.regularText.copyWith(fontSize: 12, color: context.hintColor)),
                  ],
                )
              ],
            ).withPadding(horizontal: 4.w),
          ),
          Text.rich(
            TextSpan(
              text: '${data.amount}',
              style: context.boldText.copyWith(color: context.primaryColor),
              children: [
                TextSpan(text: ' ', style: context.mediumText.copyWith(fontSize: 12)),
                TextSpan(text: LocaleKeys.currency.tr(), style: context.mediumText.copyWith(color: context.primaryColor, fontSize: 12)),
              ],
            ),
          ).toEnd
        ],
      ),
    );
  }
}
