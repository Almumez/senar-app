import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/agent_order.dart';

class ProductAgentBillWidget extends StatelessWidget {
  final AgentOrderModel data;
  const ProductAgentBillWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.price != 0) {
      return CustomImage(
        Assets.svg.bill,
        fit: BoxFit.fill,
        width: context.w,
        height: 270.h,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.service_price.tr(),
                    style: context.mediumText.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: "${data.price}", style: context.mediumText.copyWith(fontSize: 14)),
                    TextSpan(text: LocaleKeys.sar.tr(), style: context.mediumText.copyWith(fontSize: 14)),
                  ]),
                )
              ],
            ),
            Row(children: List.generate(40, (i) => Expanded(child: Divider(height: 28.h, endIndent: 1.w, indent: 1.w)))),
            Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.delivery_price.tr(),
                    style: context.mediumText.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '${data.deliveryFee - data.tax}', style: context.mediumText.copyWith(fontSize: 14)),
                    TextSpan(text: LocaleKeys.sar.tr(), style: context.mediumText.copyWith(fontSize: 14)),
                  ]),
                )
              ],
            ),
            Row(children: List.generate(40, (i) => Expanded(child: Divider(height: 28.h, endIndent: 1.w, indent: 1.w)))),
            Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.tax.tr(),
                    style: context.mediumText.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: "${data.tax}", style: context.mediumText.copyWith(fontSize: 14)),
                    TextSpan(text: LocaleKeys.sar.tr(), style: context.mediumText.copyWith(fontSize: 14)),
                  ]),
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${LocaleKeys.total.tr()} :',
                    style: context.mediumText.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '${data.totalPrice}', style: context.mediumText.copyWith(fontSize: 14)),
                    TextSpan(text: LocaleKeys.sar.tr(), style: context.mediumText.copyWith(fontSize: 14)),
                  ]),
                )
              ],
            ),
          ],
        ).withPadding(vertical: 22.h, horizontal: 16.w),
      );
    }
    return SizedBox();
  }
}
