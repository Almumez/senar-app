import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/locale_keys.g.dart';
import '../../features/auth/logout/logout_cubit.dart';
import '../../features/auth/logout/logout_state.dart';
import '../routes/app_routes_fun.dart';
import '../routes/routes.dart';
import '../services/service_locator.dart';
import '../utils/extensions.dart';
import 'app_btn.dart';
import 'app_sheet.dart';

class LogoutSheet extends StatelessWidget {
  LogoutSheet({super.key});

  final cubit = sl<LogoutCubit>();
  @override
  Widget build(BuildContext context) {
    return CustomAppSheet(
      title: LocaleKeys.logout.tr(),
      children: [
        SafeArea(
          child: Row(
            children: [
              Expanded(
                child: BlocConsumer<LogoutCubit, LogoutState>(
                  bloc: cubit,
                  listener: (context, state) {
                    pushAndRemoveUntil(NamedRoutes.login);
                  },
                  builder: (context, state) {
                    return AppBtn(
                      loading: state.requestState.isLoading,
                      onPressed: () => cubit.logout(),
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
