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
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/user_model.dart';
import '../../../shared/pages/navbar/cubit/navbar_cubit.dart';
import '../controller/complete_register_phone_cubit.dart';
import '../controller/complete_register_phone_state.dart';

class CompleteRegisterPhoneView extends StatefulWidget {
  final String phone, phoneCode;
  const CompleteRegisterPhoneView({super.key, required this.phone, required this.phoneCode});

  @override
  State<CompleteRegisterPhoneView> createState() => _CompleteRegisterPhoneViewState();
}

class _CompleteRegisterPhoneViewState extends State<CompleteRegisterPhoneView> {
  final form = GlobalKey<FormState>();
  final cubit = sl<CompleteRegisterPhoneCubit>();

  @override
  void initState() {
    super.initState();
    cubit.phone = widget.phone;
    cubit.phoneCode = widget.phoneCode;
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
                  SizedBox(height: 80.h),
                  Center(child: CustomImage("assets/images/splash.png", height: 100.2.h)),
                  SizedBox(height: 45.h),
                  Center(child: Text("إكمال التسجيل", style: context.mediumText.copyWith(fontSize: 20, color: Colors.black))),
                  SizedBox(height: 24.h),
                  AppField(
                    controller: cubit.nameController,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.text,
                    labelText: "الاسم",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال الاسم";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  // إضافة حقل العمر
                  AppField(
                    controller: cubit.ageController,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.number,
                    labelText: "العمر",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال العمر";
                      }
                      final age = int.tryParse(value);
                      if (age == null || age <= 0) {
                        return "الرجاء إدخال عمر صحيح";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "الجنس",
                    style: context.mediumText.copyWith(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(height: 8.h),
                  BlocBuilder<CompleteRegisterPhoneCubit, CompleteRegisterPhoneState>(
                    bloc: cubit,
                    builder: (context, state) {
                      return Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text("ذكر", style: context.mediumText.copyWith(fontSize: 14)),
                              value: 'male',
                              groupValue: cubit.gender,
                              onChanged: (value) {
                                if (value != null) cubit.setGender(value);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text("أنثى", style: context.mediumText.copyWith(fontSize: 14)),
                              value: 'female',
                              groupValue: cubit.gender,
                              onChanged: (value) {
                                if (value != null) cubit.setGender(value);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                  BlocConsumer<CompleteRegisterPhoneCubit, CompleteRegisterPhoneState>(
                    bloc: cubit,
                    listener: (context, state) {
                      if (state.requestState == RequestState.done) {
                        // التحقق من نوع المستخدم وتوجيهه إلى الصفحة المناسبة
                        if (cubit.userType == UserType.freeAgent) {
                          // إذا كان مندوب حر
                          if (!UserModel.i.completeRegistration) {
                            // إذا لم يكمل بيانات التسجيل الإضافية، توجيهه إلى صفحة استكمال البيانات
                            replacement(NamedRoutes.completeData, arg: {
                              'phone': widget.phone, 
                              'phone_code': widget.phoneCode
                            });
                          } else if (!UserModel.i.adminApproved) {
                            // إذا لم تتم الموافقة عليه من الإدارة بعد
                            push(NamedRoutes.successCompleteData);
                          } else {
                            // إذا تمت الموافقة عليه، توجيهه إلى الصفحة الرئيسية
                            sl<NavbarCubit>().changeTap(0);
                            pushAndRemoveUntil(NamedRoutes.navbar);
                          }
                        } else {
                          // إذا كان مستخدم عادي أو أي نوع آخر، توجيهه مباشرة إلى الصفحة الرئيسية
                          sl<NavbarCubit>().changeTap(0);
                          pushAndRemoveUntil(NamedRoutes.navbar);
                        }
                      } else if (state.requestState == RequestState.error) {
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
                          loading: state.requestState == RequestState.loading,
                          onPressed: () {
                            if (form.currentState!.validate()) {
                              cubit.completeRegister();
                            }
                          },
                          title: LocaleKeys.confirm.tr(),
                          backgroundColor: Colors.transparent,
                          textColor: Colors.white,
                          radius: 30.r,
                        ),
                      );
                    },
                  ),
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