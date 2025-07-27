import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'controller/states.dart';

import '../../../core/services/service_locator.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_btn.dart';
import '../../../core/widgets/closing_time_warning_dialog.dart';
import '../../../core/widgets/custom_image.dart';
import '../../../core/widgets/custom_radius_icon.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/locale_keys.g.dart';
import '../../shared/components/increment_widget.dart';
import '../addresses/components/my_addresses.dart';
import 'controller/cubit.dart';

class ClientRefillView extends StatefulWidget {
  const ClientRefillView({super.key});

  @override
  State<ClientRefillView> createState() => _ClientRefillViewState();
}

class _ClientRefillViewState extends State<ClientRefillView> {
  final cubit = sl<ClientRefillCubit>();
  final settingsService = sl<SettingsService>();
  
  // دالة للتحقق من وقت الإغلاق قبل إنشاء الطلب
  Future<void> _checkClosingTimeAndCreateOrder() async {
    // التحقق مما إذا كان الوقت قريبًا من وقت الإغلاق
    if (settingsService.isNearClosingTime()) {
      // عرض تحذير للمستخدم
      final shouldContinue = await ClosingTimeWarningDialog.show(
        context, 
        settingsService.getCancellationTimeInMinutes()
      );
      
      // إذا اختار المستخدم المتابعة
      if (shouldContinue == true) {
        cubit.refill();
      }
    } else {
      // إذا كان الوقت ليس قريبًا من وقت الإغلاق، استمر في إنشاء الطلب
      cubit.refill();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ClientRefillCubit, ClientRefillState>(
        bloc: cubit,
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                snap: true,
                floating: true,
                expandedHeight: 350.h,
                backgroundColor: context.canvasColor,
                title: Text(LocaleKeys.small_cylinder_refill.tr(), style: context.mediumText.copyWith(fontSize: 20)),
                centerTitle: true,
                leading: CustomRadiusIcon(
                  onTap: () => Navigator.pop(context),
                  backgroundColor: context.primaryColorLight,
                  child: Icon(Icons.arrow_back),
                ).withPadding(start: 16.w),
                leadingWidth: 75.w,
                flexibleSpace: FlexibleSpaceBar(
                  background: CustomImage(Assets.svg.clientRefill, height: 180.h).center.withPadding(top: 50.h),
                ),
              ),
           
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(LocaleKeys.refilling_a_small_cylinder_with_a_capacity_of_2_5_kg.tr(), 
                         style: context.mediumText.copyWith(fontSize: 14)).withPadding(vertical: 10.h),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(LocaleKeys.specify_quantity.tr(), style: context.mediumText.copyWith(fontSize: 20)),
                        IncrementWidget(
                          count: cubit.count,
                          increment: () {
                            cubit.incrementCount();
                          },
                          decrement: () {
                            cubit.decrementCount();
                          },
                        )
                      ],
                    ),
                    Divider(height: 50.h),
                    MyAddressWidgets(
                      callback: (val) {
                        setState(() {
                          cubit.addressId = val;
                        });
                      },
                    ),
                    BlocBuilder<ClientRefillCubit, ClientRefillState>(
                      bloc: cubit,
                      builder: (context, state) {
                        return AppBtn(
                          enable: cubit.count != 0,
                          title: LocaleKeys.order_now.tr(),
                          loading: state.requestState.isLoading,
                          onPressed: () => _checkClosingTimeAndCreateOrder(),
                        ).withPadding(bottom: 25.h);
                      },
                    )
                  ],
                ).withPadding(horizontal: 16.w),
              )
            ],
          );
        },
      ),
    );
  }
}
