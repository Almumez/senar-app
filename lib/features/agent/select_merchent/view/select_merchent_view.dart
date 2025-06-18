import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/appbar.dart';
import '../cubit/select_merchent_cubit.dart';
import '../cubit/select_merchent_state.dart';

class SelectMerchentView extends StatefulWidget {
  const SelectMerchentView({super.key});

  @override
  State<SelectMerchentView> createState() => _SelectMerchentViewState();
}

class _SelectMerchentViewState extends State<SelectMerchentView> {
  final cubit = sl<SelectMerchentCubit>()..getMerchent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.nearest_stores.tr()),
      body: BlocBuilder<SelectMerchentCubit, SelectMerchentState>(
        bloc: cubit,
        builder: (context, state) {
          if (state.requestState.isDone) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              itemCount: cubit.factories.length,
              itemBuilder: (context, index) {
                final item = cubit.factories[index];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: context.borderColor),
                    color: context.hoverColor,
                  ),
                  child: Row(
                    children: [
                      CustomImage(
                        item.image,
                        height: 120.h,
                        width: 120.h,
                        borderRadius: BorderRadius.circular(12.r),
                        backgroundColor: context.primaryColorLight,
                        fit: BoxFit.cover,
                      ).withPadding(end: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.fullname,
                              style: context.boldText.copyWith(fontSize: 16),
                            ),
                            AppBtn(
                              saveArea: false,
                              height: 40.h,
                              title: LocaleKeys.choose_this_store.tr(),
                              onPressed: () => Navigator.pop(context, item.id),
                            ).withPadding(vertical: 12.h),
                            if (item.address.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 20.h, color: context.hintColor),
                                  Text(item.address, style: context.regularText.copyWith(fontSize: 14)),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).withPadding(bottom: 15.h);
              },
            );
          } else if (state.requestState.isError) {
            return CustomErrorWidget(
              title: LocaleKeys.nearest_stores.tr(),
              subtitle: state.msg,
              errType: state.errorType,
            );
          } else {
            return LoadingApp();
          }
        },
      ),
    );
  }
}
