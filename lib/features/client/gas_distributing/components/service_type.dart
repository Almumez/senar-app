import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../controller/cubit.dart';
import '../../../../gen/locale_keys.g.dart';

import '../../../../core/widgets/custom_image.dart';

class ServiceTypeSummaryWidget extends StatefulWidget {
  const ServiceTypeSummaryWidget({
    super.key,
  });

  @override
  State<ServiceTypeSummaryWidget> createState() => _ServiceTypeSummaryWidgetState();
}

class _ServiceTypeSummaryWidgetState extends State<ServiceTypeSummaryWidget> {
  final cubit = sl<ClientDistributeGasCubit>();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ${LocaleKeys.service_type.tr()}", style: context.semiboldText.copyWith(fontSize: 16)).withPadding(bottom: 10.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cubit.selectedSubServices.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
              child: Row(
                children: [
                  CustomImage(cubit.selectedSubServices[index].image, height: 60.h, width: 60.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cubit.selectedSubServices[index].title, style: context.mediumText.copyWith(fontSize: 16)).withPadding(bottom: 8.h),
                      Text("${LocaleKeys.quantity.tr()} : ${cubit.selectedSubServices[index].count.toString()}",
                          style: context.mediumText.copyWith(fontSize: 16, color: context.secondaryColor)),
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
