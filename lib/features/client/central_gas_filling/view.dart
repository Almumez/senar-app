import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/custom_image.dart';
import '../../../gen/assets.gen.dart';

import '../../../gen/locale_keys.g.dart';
import '../../shared/components/appbar.dart';

class CentralGasFillingView extends StatefulWidget {
  const CentralGasFillingView({super.key});

  @override
  State<CentralGasFillingView> createState() => _CentralGasFillingViewState();
}

class _CentralGasFillingViewState extends State<CentralGasFillingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.central_gas_filling.tr()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16.h,
        children: [
          CustomImage(Assets.images.fillingHeader.path),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 20.h),
              Text("بريدة، القصيم، المملكة العربية السعودية", style: context.mediumText),
            ],
          ).withPadding(bottom: 10.h),
          Text("• ${LocaleKeys.exclusive_service.tr()}", style: context.mediumText.copyWith(fontSize: 16)),
          Text(LocaleKeys.exclusive_service_description.tr(), style: context.regularText.copyWith(fontSize: 12))
        ],
      ).withPadding(horizontal: 16.w, vertical: 16.w),
    );
  }
}
