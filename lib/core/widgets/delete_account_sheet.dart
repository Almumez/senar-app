import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/extensions.dart';
import 'flash_helper.dart';
import '../../features/shared/pages/settings/controller/cubit.dart';

import '../../../gen/locale_keys.g.dart';
import '../../features/shared/pages/settings/controller/state.dart';
import '../routes/app_routes_fun.dart';
import '../routes/routes.dart';
import '../services/service_locator.dart';
import 'app_btn.dart';
import 'app_sheet.dart';

class DeleteAccountSheet extends StatelessWidget {
  DeleteAccountSheet({super.key});

  final cubit = sl<SettingsCubit>();
  @override
  Widget build(BuildContext context) {
    return CustomAppSheet(
      title: LocaleKeys.delete_account.tr(),
      subtitle: LocaleKeys.account_deactivated_msg.tr(),
      children: [
        SafeArea(
          child: Row(
            children: [
              Expanded(
                child: BlocConsumer<SettingsCubit, SettingsState>(
                  bloc: cubit,
                  listener: (context, state) {
                    if (state.deleteAccountState.isDone) {
                      pushAndRemoveUntil(NamedRoutes.login);
                    } else if (state.deleteAccountState.isError) {
                      FlashHelper.showToast(state.msg);
                    }
                  },
                  builder: (context, state) {
                    return AppBtn(
                      loading: state.deleteAccountState.isLoading,
                      onPressed: () => cubit.deleteAccount(),
                      title: LocaleKeys.yes.tr(),
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppBtn(
                  textColor: context.primaryColor,
                  backgroundColor: Colors.transparent,
                  onPressed: () => Navigator.pop(context, true),
                  title: LocaleKeys.no.tr(),
                ),
              ),
            ],
          ).withPadding(vertical: 20.h),
        )
      ],
    );
  }
}
