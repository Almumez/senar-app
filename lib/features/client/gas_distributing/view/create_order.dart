import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/closing_time_warning_dialog.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../core/widgets/successfully_sheet.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/components/payment_bottom_sheet.dart';
import '../../../shared/pages/navbar/cubit/navbar_cubit.dart';
import '../../addresses/components/my_addresses.dart';
// import '../components/additional_services.dart';
import '../../../shared/components/payment_methods.dart';
import '../components/service_price.dart';
import '../controller/cubit.dart';
import '../controller/states.dart';

class ClientDistributingCreateOrderView extends StatefulWidget {
  const ClientDistributingCreateOrderView({super.key});

  @override
  State<ClientDistributingCreateOrderView> createState() => _ClientDistributingCreateOrderViewState();
}

class _ClientDistributingCreateOrderViewState extends State<ClientDistributingCreateOrderView> {
  final cubit = sl<ClientDistributeGasCubit>();
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
        _processOrder();
      }
    } else {
      // إذا كان الوقت ليس قريبًا من وقت الإغلاق، استمر في إنشاء الطلب
      _processOrder();
    }
  }
  
  // دالة لمعالجة الطلب بناءً على طريقة الدفع
  void _processOrder() {
    if (cubit.paymentMethod == 'visa') {
      // استخدام bottom sheet للدفع الإلكتروني بدلاً من الانتقال إلى صفحة جديدة
      showPaymentBottomSheet(
        context: context,
        amount: cubit.state.orderPrices?.total.toString() ?? "0",
        onSuccess: (String paymentId) {
          // تخزين معرف المعاملة وإكمال الطلب
          cubit.paymentId = paymentId;
          cubit.completeOrder();
        },
      );
    } else {
      // إذا كانت طريقة الدفع هي الكاش، قم بإكمال الطلب مباشرة
      cubit.completeOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "تفاصيل"),
      bottomNavigationBar: BlocConsumer<ClientDistributeGasCubit, ClientDistributeGasState>(
        bloc: cubit,
        buildWhen: (previous, current) => previous.createOrderState != current.createOrderState,
        listener: (context, state) {
          if (state.createOrderState.isDone) {
            showModalBottomSheet(
              elevation: 0,
              context: context,
              enableDrag: false,
              isScrollControlled: true,
              isDismissible: true,
              builder: (context) => SuccessfullySheet(
                title: LocaleKeys.order_created_successfully.tr(),
                onLottieFinish: () {
                  sl<NavbarCubit>().changeTap(1);
                  Navigator.popUntil(context, (s) => s.isFirst);
                },
              ),
            );
          } else if (state.createOrderState.isError) {
            FlashHelper.showToast(state.msg);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: AppBtn(
              loading: state.createOrderState.isLoading,
              title: "طلب",
              onPressed: () {
                if (cubit.addressId == '') {
                  FlashHelper.showToast(LocaleKeys.choose_address_first.tr());
                } else if (cubit.paymentMethod == '') {
                  FlashHelper.showToast(LocaleKeys.choose_payment_method_first.tr());
                } else {
                  // التحقق من وقت الإغلاق قبل إنشاء الطلب
                  _checkClosingTimeAndCreateOrder();
                }
              },
            ).withPadding(horizontal: 16.w, bottom: 16.h),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم التعليمات في البداية
            _buildInstructionsSection(context).withPadding(bottom: 25.h),
            
            MyAddressWidgets(
              initialId: cubit.addressId,
              callback: (val) {
                setState(() {
                  cubit.addressId = val;
                  
                  // If we have selected services, recalculate the order with the new address
                  // but don't set isRequestingOrder to avoid navigation
                  if (cubit.hasChosenServices()) {
                    cubit.calculateOrder();
                  }
                });
              },
            ).withPadding(bottom: 10.h),
            
            // Price Widget or Loading Indicator
            BlocBuilder<ClientDistributeGasCubit, ClientDistributeGasState>(
              bloc: cubit,
              buildWhen: (previous, current) => 
                previous.calculationsState != current.calculationsState ||
                previous.orderPrices != current.orderPrices,
              builder: (context, state) {
                if (state.calculationsState.isLoading) {
                  return Center(
                    child: Column(
                      children: [
                        CustomProgress(size: 30.w),
                        SizedBox(height: 10.h),
                        Text(
                          "جاري حساب السعر...",
                          style: context.mediumText.copyWith(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ).withPadding(vertical: 20.h);
                } else if (state.orderPrices != null) {
                  return ServicePriceWidget().withPadding(bottom: 15.h);
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
            
            PaymentMethodsView(
              callback: (v) {
                cubit.paymentMethod = v;
              },
            ).withPadding(bottom: 15.h),
          ],
        ),
      ),
    );
  }
  
  // دالة لإنشاء قسم التعليمات
  Widget _buildInstructionsSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildVerticalInstructionItem(
          context: context,
          svgAsset: 'assets/svg/clean.svg',
          text: "اسطوانة نظيفة",
        ),
        _buildVerticalInstructionItem(
          context: context,
          svgAsset: 'assets/svg/door.svg',
          text: "توصل للباب",
        ),
        _buildVerticalInstructionItem(
          context: context,
          svgAsset: 'assets/svg/warning.svg',
          text: "استلامك مسوؤليتك",
        ),
      ],
    );
  }
  
  // دالة لإنشاء عنصر تعليمة واحدة بشكل عمودي (أيقونة فوق النص)
  Widget _buildVerticalInstructionItem({
    required BuildContext context, 
    required String svgAsset, 
    required String text
  }) {
    // تقسيم النص إلى كلمات
    List<String> words = text.split(' ');
    
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgAsset,
            height: 24.h,
            width: 24.h,
            colorFilter: ColorFilter.mode(
              context.primaryColor,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 8.h),
          Column(
            children: words.map((word) => 
              Text(
                word,
                textAlign: TextAlign.center,
                style: context.mediumText.copyWith(
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              )
            ).toList(),
          ),
        ],
      ),
    );
  }
}
