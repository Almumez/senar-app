import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/auth_back_button.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../controller/forget_password_cubit.dart';
import '../controller/forget_password_states.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final form = GlobalKey<FormState>();
  final cubit = sl<ForgetPasswordCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 100.h),
                  Center(
                    child: CustomImage("assets/images/splash.png", height: 100.h),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    LocaleKeys.reset_password.tr(),
                    textAlign: TextAlign.center,
                    style: context.mediumText.copyWith(fontSize: 20),
                  ),
                  SizedBox(height: 16.h),
                  // Text(
                  //   LocaleKeys.please_enter_the_phone_number_below_to_reset_your_password.tr(),
                  //   textAlign: TextAlign.center,
                  //   style: context.mediumText.copyWith(fontSize: 14, color: '#f5f5f5'.color),
                  // ),
                  SizedBox(height: 45.h),
                  AppField(
                    controller: cubit.phone,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.text,
                    labelText: LocaleKeys.phone_number.tr(),
                    direction: "right",
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 25.h,
                          width: 1,
                          color: Colors.black,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
                          child: Text(
                            textAlign: TextAlign.left,
                            "+${cubit.country?.phoneCode ?? '966'}",
                            style: context.mediumText.copyWith(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
                    bloc: cubit,
                    listener: (context, state) {
                      if (state.requestState.isDone) {
                        push(NamedRoutes.verifyPhone, arg: {'type': VerifyType.resetPassword, 'phone': cubit.phone.text, 'phone_code': cubit.country!.phoneCode});
                      } else if (state.requestState.isError) {
                        FlashHelper.showToast(state.msg);
                      }
                    },
                    builder: (context, state) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: AppBtn(
                          loading: state.requestState.isLoading,
                          onPressed: () => form.isValid ? cubit.forgotPassword() : null,
                          title: LocaleKeys.send.tr(),
                          backgroundColor: Colors.transparent,
                          textColor: Colors.white,
                          radius: 30.r,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          AuthBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: AppBtn(
          title: LocaleKeys.login.tr(),
          backgroundColor: Colors.transparent,
          textColor: Colors.black,
          onPressed: () => push(NamedRoutes.login),
          radius: 30.r,
        ),
      ),
    );
  }
}
