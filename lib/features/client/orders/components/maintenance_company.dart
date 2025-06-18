import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/extensions.dart';

import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';
import '../../../shared/components/status_container.dart';

class MaintenanceCompanyItem extends StatelessWidget {
  const MaintenanceCompanyItem({
    super.key,
    required this.data,
  });

  final ClientOrderModel data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ${LocaleKeys.maintenance_company.tr()}", style: context.semiboldText.copyWith(fontSize: 16)).withPadding(bottom: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
          child: Row(
            children: [
              CustomImage(data.merchant.image, height: 40.h, width: 40.h, borderRadius: BorderRadius.circular(20.h)).withPadding(end: 8.w),
              Expanded(
                child: Text(data.merchant.fullname, style: context.mediumText),
              ),
              StatusContainer(
                title: data.statusTrans,
                color: data.color,
              ).toEnd
            ],
          ),
        ).withPadding(bottom: 16.h),
      ],
    );
  }
}
