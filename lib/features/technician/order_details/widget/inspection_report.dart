import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_field.dart';

import '../../../../gen/locale_keys.g.dart';
import '../cubit/order_details_cubit.dart';

class InspectionReportWidget extends StatelessWidget {
  final TechnicianOrderDetailsCubit cubit;
  const InspectionReportWidget({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    if (cubit.order?.status != 'checking') return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "• ${LocaleKeys.inspection_report.tr()}",
          style: context.mediumText.copyWith(fontSize: 20),
        ).withPadding(bottom: 20.h),
        ...List.generate(
          cubit.inspectionReports.length,
          (index) => Column(
            children: [
              AppField(
                controller: cubit.inspectionReports[index].description,
                labelText: LocaleKeys.problem_no.tr(args: ["${index + 1}"]),
                hintText: LocaleKeys.write_the_problem.tr(),
                direction: 'top',
              ),
              AppField(
                controller: cubit.inspectionReports[index].price,
                hintText: LocaleKeys.value.tr(),
                keyboardType: TextInputType.number,
                direction: 'bottom',
                suffixIcon: SizedBox(
                  width: 50.w,
                  child: Text(
                    LocaleKeys.currency.tr(),
                  ).center,
                ),
              )
            ],
          ).withPadding(bottom: 15.h),
        ),
        if (cubit.inspectionReports.length > 1)
          InkWell(
            onTap: () {
              cubit.removeInspectionReport();
            },
            child: Text(
              LocaleKeys.delete.tr(),
              style: context.mediumText.copyWith(fontSize: 14, color: context.errorColor),
            ),
          ),
        SizedBox(height: 15.h),
        AppBtn(
          height: 35.h,
          title: LocaleKeys.add_another_problem.tr(),
          textColor: context.primaryColor,
          backgroundColor: Colors.transparent,
          icon: Icon(Icons.add, color: context.primaryColor),
          onPressed: cubit.addInspectionReport,
        ).withPadding(horizontal: 20.w)
      ],
    );
  }
}
