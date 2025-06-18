import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/shared/pages/edit_profile/controller/edit_profile_cubit.dart';
import '../../features/shared/pages/edit_profile/controller/edit_profile_state.dart';
import '../../gen/locale_keys.g.dart';
import '../services/service_locator.dart';
import 'app_btn.dart';
import 'app_field.dart';
import 'app_sheet.dart';
import 'flash_helper.dart';
import 'successfully_sheet.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final cubit = sl<EditProfileCubit>();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: CustomAppSheet(
        title: LocaleKeys.change_password.tr(),
        children: [
          AppField(
            labelText: LocaleKeys.current_password.tr(),
            controller: cubit.oldPassword,
            keyboardType: TextInputType.visiblePassword,
          ),
          AppField(
            labelText: LocaleKeys.password.tr(),
            controller: cubit.password,
            keyboardType: TextInputType.visiblePassword,
          ),
          AppField(
            labelText: LocaleKeys.confirm_password.tr(),
            controller: cubit.confirmPassword,
            keyboardType: TextInputType.visiblePassword,
            validator: (v) {
              if (v != cubit.password.text) {
                return LocaleKeys.passwords_do_not_match.tr();
              }
              return null;
            },
          ),
          BlocConsumer<EditProfileCubit, EditProfileState>(
            bloc: cubit,
            listener: (context, state) {
              if (state.passwordState.isDone) {
                Navigator.pop(context);
                showModalBottomSheet(
                  elevation: 0,
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  builder: (context) => SuccessfullySheet(
                    title: LocaleKeys.password_changed_successfully.tr(),
                  ),
                );
              } else if (state.passwordState.isError) {
                FlashHelper.showToast(state.msg);
              }
            },
            builder: (context, state) {
              return AppBtn(
                loading: state.passwordState.isLoading,
                title: LocaleKeys.confirm.tr(),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    cubit.changePassword();
                  }
                },
              );
            },
          )
        ],
      ),
    );
  }
}
