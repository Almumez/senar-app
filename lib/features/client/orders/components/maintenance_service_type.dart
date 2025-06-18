import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/extensions.dart';

import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';

class MaintenanceServiceType extends StatelessWidget {
  final ClientOrderModel data;
  const MaintenanceServiceType({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ${LocaleKeys.service_type.tr()}", style: context.semiboldText.copyWith(fontSize: 16)).withPadding(bottom: 10.h),
        Container(
          width: context.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(
                data.orderServices.length,
                (index) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.orderServices[index].title, style: context.mediumText).withPadding(bottom: 5.h),
                    Text("• ${data.orderServices[index].description}", style: context.regularText.copyWith(fontSize: 12)).withPadding(bottom: 5.h),
                  ],
                ),
              ),
              Row(
                children: [
                  CustomImage(
                    Assets.svg.calender,
                    height: 16.sp,
                    width: 16.sp,
                    color: context.hintColor,
                  ).withPadding(end: 5.w),
                  Text(
                    DateFormat('dd MMM yyyy', context.locale.languageCode).format(data.createdAt),
                    style: context.regularText.copyWith(
                      fontSize: 12,
                      color: context.hintColor,
                    ),
                  ),
                  CustomImage(
                    Assets.svg.clock,
                    height: 16.sp,
                    width: 16.sp,
                    color: context.hintColor,
                  ).withPadding(start: 12.w, end: 5.w),
                  Text(
                    DateFormat('hh:mm a', context.locale.languageCode).format(data.createdAt),
                    style: context.regularText.copyWith(
                      fontSize: 12,
                      color: context.hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).withPadding(bottom: 16.h),
      ],
    );
  }
}
