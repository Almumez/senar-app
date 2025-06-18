import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/enums.dart';

import '../../controller/upload_attachment/attachment_cubit.dart';
import '../../controller/upload_attachment/attachment_state.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/phoneix.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../core/widgets/pin_code_sheet.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/user_model.dart';
import '../../components/appbar.dart';
import 'controller/edit_profile_cubit.dart';
import 'controller/edit_profile_state.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final cubit = sl<EditProfileCubit>();
  final attachmentCubit = sl<UploadAttachmentCubit>();
  final _buttonStream = StreamController<bool>();
  final _phoneStream = StreamController<bool>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordStream = StreamController<bool>();

  @override
  void initState() {
    super.initState();
    cubit.name.addListener(() => _buttonStream.add(cubit.canUpdate));
    cubit.email.addListener(() => _buttonStream.add(cubit.canUpdate));
    cubit.phone.addListener(() => _phoneStream.add(cubit.canUpdatePhone));
    cubit.oldPassword.addListener(() => _validatePasswords());
    cubit.password.addListener(() => _validatePasswords());
    cubit.confirmPassword.addListener(() => _validatePasswords());
  }

  void _validatePasswords() {
    if (cubit.oldPassword.text.isNotEmpty && cubit.password.text.isNotEmpty && cubit.confirmPassword.text.isNotEmpty) {
      _passwordStream.add(cubit.password.text == cubit.confirmPassword.text);
    } else {
      _passwordStream.add(false);
    }
  }

  @override
  void dispose() {
    _buttonStream.close();
    _phoneStream.close();
    _passwordStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "تعديل"),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            AppField(labelText: LocaleKeys.name.tr(), controller: cubit.name).withPadding(bottom: 16.h),
            if (UserModel.i.accountType != UserType.client)
              AppField(labelText: LocaleKeys.email.tr(), controller: cubit.email, isRequired: false).withPadding(bottom: 16.h),
            BlocConsumer<EditProfileCubit, EditProfileState>(
              bloc: cubit,
              listener: (context, state) {
                if (state.phoneState.isDone) {
                  showModalBottomSheet(
                    elevation: 0,
                    context: context,
                    isScrollControlled: true,
                    isDismissible: true,
                    builder: (context) => PinCodeSheet(
                      phone: cubit.phone.text,
                      phoneCode: cubit.country!.phoneCode,
                      code: cubit.code.text,
                    ),
                  );
                } else if (state.phoneState.isError) {
                  FlashHelper.showToast(state.msg);
                }
              },
              builder: (context, state) {
                return AppField(
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
                          style: context.regularText.copyWith(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 30.h),
            StreamBuilder<bool>(
              stream: _buttonStream.stream,
              builder: (context, snapshot) {
                return BlocConsumer<EditProfileCubit, EditProfileState>(
                  bloc: cubit,
                  listener: (context, state) {
                    if (state.requestState.isDone) {
                      Phoenix.rebirth(context);
                      _buttonStream.add(cubit.canUpdate);
                      FlashHelper.showToast(state.msg, type: MessageType.success);
                    }
                  },
                  builder: (context, state) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: AppBtn(
                        enable: snapshot.data ?? false,
                        title: "تعديل",
                        loading: state.requestState.isLoading,
                        backgroundColor: Colors.transparent,
                        textColor: Colors.white,
                        radius: 30.r,
                        onPressed: () {
                          cubit.updateProfile();
                        },
                      ),
                    );
                  }
                );
              }
            ),
            
            SizedBox(height: 40.h),
            Text(
              "تغيير كلمة المرور",
              style: context.mediumText.copyWith(fontSize: 18),
            ).withPadding(bottom: 16.h),
            
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  AppField(
                    controller: cubit.oldPassword,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.visiblePassword,
                    labelText: "كلمة المرور الحالية",
                  ),
                  AppField(
                    controller: cubit.password,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.visiblePassword,
                    labelText: "كلمة المرور الجديدة",
                  ),
                  AppField(
                    controller: cubit.confirmPassword,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.visiblePassword,
                    labelText: "تأكيد كلمة المرور الجديدة",
                    validator: (v) {
                      if (v != cubit.password.text) {
                        return LocaleKeys.passwords_do_not_match.tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  
                  StreamBuilder<bool>(
                    stream: _passwordStream.stream,
                    builder: (context, snapshot) {
                      return BlocConsumer<EditProfileCubit, EditProfileState>(
                        bloc: cubit,
                        listener: (context, state) {
                          if (state.passwordState.isDone) {
                            FlashHelper.showToast(state.msg, type: MessageType.success);
                            cubit.passwordsClean();
                          } else if (state.passwordState.isError) {
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
                              enable: snapshot.data ?? false,
                              title: "تغيير كلمة المرور",
                              loading: state.passwordState.isLoading,
                              backgroundColor: Colors.transparent,
                              textColor: Colors.white,
                              radius: 30.r,
                              onPressed: () {
                                if (_passwordFormKey.currentState!.validate()) {
                                  cubit.changePassword();
                                }
                              },
                            ),
                          );
                        }
                      );
                    }
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
