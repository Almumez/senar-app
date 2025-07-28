import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
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
import '../../../../core/widgets/select_item_sheet.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/user_model.dart';
import '../../../../models/country.dart';
import '../../../shared/pages/navbar/cubit/navbar_cubit.dart';
import '../controller/login_cubit.dart';
import '../controller/login_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final form = GlobalKey<FormState>();
  final cubit = sl<LoginCubit>();
  List<UserTypeModel> userTypes = [
    UserTypeModel(
      name: LocaleKeys.client.tr(), 
      userType: UserType.client,
      icon: "assets/svg/profile_out.svg"
    ),
    UserTypeModel(
      name: LocaleKeys.free_agent.tr(), 
      userType: UserType.freeAgent,
      icon: "assets/svg/delivry.svg"
    ),
  ];
  @override
  void initState() {
    super.initState();
    // تعيين رمز الدولة الافتراضي للسعودية (+966)
    cubit.country = CountryModel.fromJson({
      'name': 'Saudi Arabia',
      'phone_code': '966',
      'flag': '',
      'short_name': 'SA',
      'phone_limit': 9
    });
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
                    " دخول",
                    textAlign: TextAlign.center,
                    style:  context.mediumText.copyWith(fontSize: 20),
                  ),
                  SizedBox(height: 70.h),
                  AppField(
                    controller: cubit.phone,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.number,
                    labelText: "هاتف",
                    direction: "left",
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 25.h,
                          width: 1,
                          color: Colors.black,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
                          child: Text(
                         textAlign: TextAlign.left,
                            // textDirection:  TextDirection.LTR,
                            "+966",
                            style: context.mediumText.copyWith(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50.h),
                  BlocConsumer<LoginCubit, LoginState>(
                    bloc: cubit,
                    listener: (context, state) {
                      switch (state.requestState) {
                        case RequestState.done:
                          _navigateToVerifyPhone();
                          break;

                        case RequestState.error:
                          FlashHelper.showToast(state.msg);
                          break;

                        default:
                          break;
                      }
                    },
                    builder: (context, state) {
                      return Container(
                          decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30.r),),
                        child: AppBtn(
                          loading: state.requestState == RequestState.loading,
                          onPressed: () => form.isValid ? cubit.requestOtp() : null,
                          title: LocaleKeys.confirm.tr(),
                          backgroundColor: Colors.transparent,
                          textColor: Colors.white,
                          radius: 30.r,
                        ),
                      );
                    },
                  ),
                  // Text.rich(
                  //   TextSpan(
                  //     children: [
                  //       TextSpan(
                  //         text: "تسجيل",
                  //         recognizer: TapGestureRecognizer()
                  //           ..onTap = () {
                  //             showModalBottomSheet<UserTypeModel?>(
                  //               context: context,
                  //               builder: (context) => SelectItemSheet(
                  //                 title: "اختر",
                  //                 items: userTypes,
                  //               ),
                  //             ).then((value) {
                  //               if (value != null) {
                  //                 push(NamedRoutes.register,
                  //                     arg: {"type": value.userType});
                  //               }
                  //             });
                  //           },
                  //         style: context.mediumText
                  //             .copyWith(fontSize: 14, color: Color(0xff000000)),
                  //       ),
                  //     ],
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ).withPadding(vertical: 12.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: AppBtn(
          title: LocaleKeys.login_as_guest.tr(),
          backgroundColor: Colors.transparent,
          textColor: Colors.black,
          onPressed: () => pushAndRemoveUntil(NamedRoutes.navbar),
          radius: 30.r,
        ),
      ),
    );
  }

  void _navigateToVerifyPhone() {
    push(
      NamedRoutes.verifyPhone,
      arg: {
        'type': VerifyType.login,
        'phone': cubit.phone.text,
        'phone_code': cubit.country!.phoneCode,
      },
    );
  }
}

class UserTypeModel {
  final String name;
  final UserType userType;
  final String icon;

  UserTypeModel({required this.name, required this.userType, required this.icon});
}
