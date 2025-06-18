import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/agent_order.dart';
import '../../../shared/components/status_container.dart';

class ProductAgentOrderWidget extends StatelessWidget {
  final AgentOrderModel item;
  final Function() onBack;
  const ProductAgentOrderWidget({super.key, required this.item, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        push(NamedRoutes.productAgentOrderDetails, arg: {"id": item.id, "type": item.type}).then((_) => onBack());
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: Color(0xfff5f5f5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${LocaleKeys.order_number.tr()} : ${item.id}", style: context.mediumText.copyWith(fontSize: 20)),
                Row(
                  children: [
                    Icon(Icons.access_time, color: context.primaryColor, size: 20.h).withPadding(end: 3.w),
                    Text(item.createdAt, style: context.mediumText.copyWith(fontSize: 14)),
                  ],
                ),
              ],
            ),
            Divider(height: 25.h),
            Text.rich(
              TextSpan(
                text: "${LocaleKeys.service_type.tr()} : ",
                style: context.mediumText.copyWith(fontSize: 14, color: context.hintColor),
                children: [
                  TextSpan(text: item.typeTrans, style: context.mediumText.copyWith(fontSize: 14)),
                ],
              ),
            ),
            Divider(height: 25.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomImage(
                      item.clientImage,
                      height: 40.h,
                      width: 40.h,
                      borderRadius: BorderRadius.circular(20.h),
                      fit: BoxFit.cover,
                    ).withPadding(end: 8.w),
                    Text(
                      item.clientName,
                      style: context.mediumText.copyWith(fontSize: 20),
                    )
                  ],
                ),
                StatusContainer(
                  title: item.statusTrans,
                  color: item.color,
                )
              ],
            ),
            Row(
              children: [
                CustomImage(
                  Assets.svg.location,
                  height: 20.sp,
                  width: 20.sp,
                ),
                Expanded(
                  child: Text(
                    item.address.placeDescription,
                    style: context.mediumText.copyWith(fontSize: 12),
                  ).withPadding(horizontal: 4.w),
                ),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: LocaleKeys.sar.tr(),
                      style: context.mediumText.copyWith(fontSize: 14),
                    ),
                    TextSpan(
                      text: "${item.price}",
                      style: context.mediumText.copyWith(fontSize: 14),
                    ),
                  ]),
                )
              ],
            ).withPadding(top: 8.h),
          ],
        ),
      ),
    );
  }
}
