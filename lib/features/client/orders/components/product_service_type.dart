import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/extensions.dart';

import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';

class ProductServiceType extends StatelessWidget {
  final ClientOrderModel data;
  const ProductServiceType({super.key, required this.data});

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
            children: List.generate(
              data.orderProducts.length,
              (index) => Row(
                children: [
                  CustomImage(
                    data.orderProducts[index].product.image,
                    height: 80,
                    borderRadius: BorderRadius.circular(4.r),
                    backgroundColor: '#F0F0F5'.color,
                    width: 80.h,
                  ).withPadding(end: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: context.w * 0.6,
                        child: Text(data.orderProducts[index].product.name, style: context.mediumText, maxLines: 2, overflow: TextOverflow.ellipsis)
                            .withPadding(bottom: 10.h),
                      ),
                      Text(
                        '${LocaleKeys.quantity.tr()} : ${data.orderProducts[index].quantity.toString()}',
                        style: context.mediumText.copyWith(color: context.hintColor),
                      ),
                    ],
                  )
                ],
              ).withPadding(bottom: 10.h),
            ),
          ),
        ).withPadding(bottom: 16.h),
      ],
    );
  }
}
