import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../models/technician_order.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/status_container.dart';

class TechnicianOrderWidget extends StatelessWidget {
  final TechnicianOrderModel item;
  final Function() onBack;
  const TechnicianOrderWidget({super.key, required this.item, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        push(NamedRoutes.technicianOrderDetails, arg: {"id": item.id, "isOffer": item.status == 'pending'}).then((context) => onBack());
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
            if (item.services.isNotEmpty)
              Text.rich(
                TextSpan(
                  text: "${LocaleKeys.services.tr()} : ",
                  style: context.mediumText.copyWith(fontSize: 14, color: context.hintColor),
                  children: List.generate(
                    item.services.length,
                    (index) => TextSpan(text: item.services[index].title, style: context.mediumText.copyWith(fontSize: 14)),
                  ),
                ),
              ),
            if (item.services.isNotEmpty) Divider(height: 25.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomImage(
                      item.client.image,
                      height: 40.h,
                      width: 40.h,
                      borderRadius: BorderRadius.circular(20.h),
                      fit: BoxFit.cover,
                    ).withPadding(end: 8.w),
                    Text(
                      item.client.fullname,
                      style: context.mediumText.copyWith(fontSize: 20),
                    )
                  ],
                ),
                StatusContainer(
                  title: item.statusTranslation,
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
                Text(
                  item.address.placeDescription,
                  style: context.mediumText.copyWith(fontSize: 14),
                ).withPadding(horizontal: 4.w),
              ],
            ).withPadding(top: 8.h),
            if (item.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: AppBtn(
                      onPressed: () =>
                          push(NamedRoutes.technicianOrderDetails, arg: {"id": item.id, "isOffer": item.status == 'pending'}).then((context) => onBack()),
                      height: 40.h,
                      saveArea: false,
                      title: LocaleKeys.accept.tr(),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AppBtn(
                      onPressed: () =>
                          push(NamedRoutes.technicianOrderDetails, arg: {"id": item.id, "isOffer": item.status == 'pending'}).then((context) => onBack()),
                      textColor: context.primaryColor,
                      saveArea: false,
                      height: 40.h,
                      backgroundColor: context.primaryColorLight,
                      title: LocaleKeys.reject.tr(),
                    ),
                  )
                ],
              ).withPadding(top: 8.h),
          ],
        ),
      ),
    );
  }
}
