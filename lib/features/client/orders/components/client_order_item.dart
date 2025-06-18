import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/custom_radius_icon.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';
import '../../../shared/components/status_container.dart';

class ClientOrderCard extends StatelessWidget {
  final Function() onBack;
  final ClientOrderModel data;
  const ClientOrderCard({super.key, required this.data, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(data.type);
        push(NamedRoutes.orderDetails, arg: {"id": data.id, "type": data.type}).then((context) => onBack());
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          color: Color(0xfff5f5f5),
        ),
        child: Column(
          spacing: 10.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.agent.id != '' ? data.agent.fullname : LocaleKeys.no_agent.tr(),
                        style: context.mediumText.copyWith(fontSize: 14, color: Colors.black),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          CustomImage(
                            Assets.svg.location,
                            height: 16.sp,
                            width: 16.sp,
                            color: Colors.black,
                          ).withPadding(end: 4.w),
                          Expanded(
                            child: Text(
                              data.address.placeDescription,
                              style: context.mediumText.copyWith(fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  width: 105.w,
                  height: 30.h,
                  child: StatusContainer(
                    title: data.statusTrans,
                    color: data.color,
                  ),
                )
              ],
            ),
            Text.rich(
              TextSpan(
                text: LocaleKeys.the_service.tr(),
                style: context.mediumText.copyWith(color: Colors.black),
                children: [
                  TextSpan(
                    text: data.typeTrans,
                    style: context.mediumText.copyWith(color: Colors.black),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                CustomImage(
                  Assets.svg.calender,
                  height: 16.sp,
                  width: 16.sp,
                  color: Colors.black,
                ).withPadding(end: 5.w),
                Text(
                  DateFormat('dd/MM/yyyy', 'en').format(data.createdAt),
                  style: context.mediumText.copyWith(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                CustomImage(
                  Assets.svg.clock,
                  height: 16.sp,
                  width: 16.sp,
                  color: Colors.black,
                ).withPadding(start: 12.w, end: 5.w),
                Text(
                  DateFormat('hh:mm a', 'en').format(data.createdAt),
                  style: context.mediumText.copyWith(
                    fontSize: 14,
                    color: Colors.black,
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
