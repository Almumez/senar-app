import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/shared/pages/edit_profile/controller/edit_profile_cubit.dart';
import '../../features/shared/pages/edit_profile/controller/edit_profile_state.dart';
import '../../gen/locale_keys.g.dart';
import '../services/service_locator.dart';
import '../utils/extensions.dart';
import '../utils/phoneix.dart';
import 'app_btn.dart';
import 'app_sheet.dart';
import 'flash_helper.dart';
import 'pin_code.dart';
import 'successfully_sheet.dart';

class PinCodeSheet extends StatefulWidget {
  final String phone, phoneCode, code;
  const PinCodeSheet({super.key, required this.phone, required this.phoneCode, required this.code});

  @override
  State<PinCodeSheet> createState() => _PinCodeSheetState();
}

class _PinCodeSheetState extends State<PinCodeSheet> {
  final formKey = GlobalKey<FormState>();
  final cubit = sl<EditProfileCubit>();
  @override
  Widget build(BuildContext context) {
    return CustomAppSheet(
      title: LocaleKeys.update_phone.tr(),
      children: [
        SizedBox(height: 12.h),
        Form(
          key: formKey,
          child: CustomPinCode(controller: cubit.code),
        ),
        SizedBox(height: 12.h),
        BlocConsumer<EditProfileCubit, EditProfileState>(
          bloc: cubit,
          listener: (context, state) {
            if (state.verifyState.isDone) {
              Navigator.pop(context);
              showModalBottomSheet(
                elevation: 0,
                context: context,
                isScrollControlled: true,
                isDismissible: true,
                builder: (context) => SuccessfullySheet(
                  title: LocaleKeys.update_phone_successfully.tr(),
                  onLottieFinish: () {
                    Navigator.pop(context);
                    Phoenix.rebirth(context);
                  },
                ),
              );
            } else if (state.verifyState.isError) {
              FlashHelper.showToast(state.msg);
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: AppBtn(
                loading: state.verifyState.isLoading,
                title: LocaleKeys.confirm.tr(),
                onPressed: () {
                  if (formKey.currentState?.validate() == true) {
                    cubit.verifyPhone(phoneCode: widget.phoneCode, phone: widget.phone, code: cubit.code.text);
                  }
                },
              ).withPadding(bottom: 12.h),
            );
          },
        ),
      ],
    );
  }
}
