import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
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
import '../../../../models/country.dart';
import '../controller/register_cubit.dart';
import '../controller/register_states.dart';

class RegisterView extends StatefulWidget {
  final UserType userType;
  const RegisterView({super.key, required this.userType});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final form = GlobalKey<FormState>();
  final cubit = sl<RegisterCubit>();

  @override
  void initState() {
    cubit.userType = widget.userType;
    print("user type is : ${cubit.userType}");
    // تعيين رمز الدولة الافتراضي للسعودية (+966)
    cubit.country = CountryModel.fromJson({
      'name': 'Saudi Arabia',
      'phone_code': '966',
      'flag': '',
      'short_name': 'SA',
      'phone_limit': 9
    });
    super.initState();
  }

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
                    "تسجيل",
                    textAlign: TextAlign.center,
                    style: context.mediumText.copyWith(fontSize: 20),
                  ),
                  SizedBox(height: 45.h),
                  AppField(
                    controller: cubit.fullName,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.name,
                    labelText: LocaleKeys.fullname.tr(),
                  ),
                  AppField(
                    controller: cubit.phone,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.text,
                    labelText: "هاتف",
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
                            "+966",
                            style: context.mediumText.copyWith(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppField(
                    controller: cubit.password,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.visiblePassword,
                    labelText: "رمز",
                  ),
                  AppField(
                    controller: cubit.confirmPassword,
                    validator: (v) {
                      if (v != cubit.password.text) {
                        return LocaleKeys.passwords_do_not_match.tr();
                      } else {
                        return null;
                      }
                    },
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.visiblePassword,
                    labelText: LocaleKeys.confirm_password.tr(),
                  ),
                  SizedBox(height: 24.h),
                  BlocConsumer<RegisterCubit, RegisterState>(
                    bloc: cubit,
                    listener: (context, state) {
                      if (state.requestState.isDone) {
                        replacement(NamedRoutes.verifyPhone, arg: {'type': VerifyType.register, 'phone': cubit.phone.text, 'phone_code': cubit.country!.phoneCode});
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
                          onPressed: () => form.isValid ? cubit.register() : null,
                          title: "تسجيل",
                          backgroundColor: Colors.transparent,
                          textColor: Colors.white,
                          radius: 30.r,
                        ),
                      );
                    },
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: LocaleKeys.login.tr(),
                          recognizer: TapGestureRecognizer()..onTap = () => replacement(NamedRoutes.login),
                          style: context.mediumText.copyWith(fontSize: 14, color: Color(0xff000000)),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ).withPadding(vertical: 18.h),
                ],
              ),
            ),
          ),
          AuthBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
