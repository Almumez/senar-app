import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../controller/cubit.dart';
import '../../../../gen/locale_keys.g.dart';

import '../../../../core/widgets/custom_image.dart';

class AdditionalServicesSummaryWidget extends StatefulWidget {
  const AdditionalServicesSummaryWidget({
    super.key,
  });

  @override
  State<AdditionalServicesSummaryWidget> createState() => _AdditionalServicesSummaryWidgetState();
}

class _AdditionalServicesSummaryWidgetState extends State<AdditionalServicesSummaryWidget> {
  final cubit = sl<ClientDistributeGasCubit>();
  @override
  Widget build(BuildContext context) {
    if (cubit.selectedAdditionalServices.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ${LocaleKeys.additional_options.tr()}", style: context.semiboldText.copyWith(fontSize: 16)).withPadding(bottom: 10.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cubit.selectedAdditionalServices.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
              child: Row(
                children: [
                  CustomImage(cubit.selectedAdditionalServices[index].image, height: 60.h, width: 60.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cubit.selectedAdditionalServices[index].title, style: context.mediumText.copyWith(fontSize: 16)).withPadding(bottom: 8.h),
                      SizedBox(
                        width: context.w - 130.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${cubit.selectedAdditionalServices[index].price.toString()} ${LocaleKeys.currency.tr()}",
                                style: context.mediumText.copyWith(fontSize: 16, color: context.secondaryColor)),
                            Text("${LocaleKeys.quantity.tr()} : ${cubit.selectedAdditionalServices[index].count.toString()}",
                                style: context.mediumText.copyWith(fontSize: 16, color: context.secondaryColor)),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ).withPadding(bottom: 15.h);
          },
        )
      ],
    );
  }
}
