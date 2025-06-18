import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/auth_back_button.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../gen/assets.gen.dart';
import '../controller/reset_password_cubit.dart';
import '../controller/reset_password_states.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/successfully_sheet.dart';
import '../../../../gen/locale_keys.g.dart';

class ResetPasswordView extends StatefulWidget {
  final String phone, phoneCode, code;
  const ResetPasswordView({super.key, required this.phone, required this.phoneCode, required this.code});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final form = GlobalKey<FormState>();

  final cubit = sl<ResetPasswordCubit>();
  @override
  void initState() {
    cubit.phone = widget.phone;
    cubit.phoneCode = widget.phoneCode;
    cubit.code = widget.code;
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
                  SizedBox(height: 80.h),
                  CustomImage(Assets.images.logo.path, height: 42.2.h),
                  SizedBox(height: 45.h),
                  Text(LocaleKeys.reset_password.tr(), style: context.mediumText.copyWith(fontSize: 20)),
                  SizedBox(height: 12.h),
                  Text(
                    LocaleKeys.the_password_must_not_be_less_than_8_numbers.tr(),
                    style: context.mediumText.copyWith(fontSize: 14, color: '#f5f5f5'.color),
                  ),
                  SizedBox(height: 24.h),
                  AppField(
                    controller: cubit.password,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.visiblePassword,
                    labelText: LocaleKeys.password.tr(),
                  ),
                  AppField(
                    validator: (v) {
                      if (v != cubit.password.text) {
                        return LocaleKeys.passwords_do_not_match.tr();
                      } else {
                        return null;
                      }
                    },
                    controller: cubit.passwordConfirmation,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    keyboardType: TextInputType.visiblePassword,
                    labelText: LocaleKeys.confirm_password.tr(),
                  ),
                  SizedBox(height: 24.h),
                  BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
                    bloc: cubit,
                    listener: (context, state) {
                      if (state.requestState.isDone) {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => SuccessfullySheet(
                            title: LocaleKeys.password_changed_successfully.tr(),
                            onLottieFinish: () => Navigator.popUntil(context, (route) => route.isFirst),
                          ),
                        );
                      } else if (state.requestState.isError) {
                        FlashHelper.showToast(state.msg);
                      }
                    },
                    builder: (context, state) {
                      return AppBtn(
                        loading: state.requestState.isLoading,
                        title: LocaleKeys.confirm.tr(),
                        onPressed: () => !state.requestState.isLoading ? cubit.resetPassword() : null,
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
