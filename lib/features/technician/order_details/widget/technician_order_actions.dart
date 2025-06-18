import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../gen/locale_keys.g.dart';
import '../cubit/order_details_cubit.dart';
import '../cubit/order_details_state.dart';

class TechnicianOrderActions extends StatefulWidget {
  final TechnicianOrderDetailsCubit cubit;
  const TechnicianOrderActions({super.key, required this.cubit});

  @override
  State<TechnicianOrderActions> createState() => _TechnicianOrderActionsState();
}

class _TechnicianOrderActionsState extends State<TechnicianOrderActions> {
  TechnicianOrderDetailsCubit get cubit => widget.cubit;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TechnicianOrderDetailsCubit, TechnicianOrderDetailsState>(
      bloc: cubit,
      buildWhen: (previous, current) => previous.getOrderState != current.getOrderState,
      builder: (context, state) {
        if (cubit.order?.status == "pending") {
          return BlocBuilder<TechnicianOrderDetailsCubit, TechnicianOrderDetailsState>(
            bloc: cubit,
            builder: (context, state) {
              return AbsorbPointer(
                absorbing: state.acceptState.isLoading || state.rejectOrder.isLoading,
                child: Opacity(
                  opacity: state.acceptState.isLoading || state.rejectOrder.isLoading ? 0.4 : 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: AppBtn(
                          onPressed: () {
                            cubit.acceptOrder();
                          },
                          title: LocaleKeys.accept.tr(),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: AppBtn(
                          onPressed: () => cubit.rejectOrder(),
                          textColor: context.errorColor,
                          backgroundColor: Colors.transparent,
                          title: LocaleKeys.reject.tr(),
                        ),
                      )
                    ],
                  ),
                ),
              ).withPadding(vertical: 12.h, horizontal: 16.w);
            },
          );
        } else if (cubit.order?.status == 'accepted') {
          return BlocBuilder<TechnicianOrderDetailsCubit, TechnicianOrderDetailsState>(
            bloc: cubit,
            buildWhen: (previous, current) => previous.checkNowStatus != current.checkNowStatus,
            builder: (context, state) {
              return AppBtn(
                loading: state.checkNowStatus.isLoading,
                title: LocaleKeys.check_now.tr(),
                onPressed: () => cubit.checkNow(),
              );
            },
          ).withPadding(horizontal: 16.w, vertical: 12.h);
        } else if (cubit.order?.status == 'checking') {
          return BlocBuilder<TechnicianOrderDetailsCubit, TechnicianOrderDetailsState>(
            bloc: cubit,
            buildWhen: (previous, current) => previous.checkNowStatus != current.checkNowStatus,
            builder: (context, state) {
              return AppBtn(
                loading: state.checkNowStatus.isLoading,
                title: LocaleKeys.send_inspection_report.tr(),
                onPressed: () => cubit.sendReport(),
              );
            },
          ).withPadding(horizontal: 16.w, vertical: 12.h);
        } else if (cubit.order?.status == 'checked' && cubit.order?.paymentMethod != '') {
          return BlocBuilder<TechnicianOrderDetailsCubit, TechnicianOrderDetailsState>(
            bloc: cubit,
            buildWhen: (previous, current) => previous.completeOrderState != current.completeOrderState,
            builder: (context, state) {
              return AppBtn(
                loading: state.completeOrderState.isLoading,
                title: LocaleKeys.service_completed.tr(),
                onPressed: () => cubit.complete(),
              );
            },
          ).withPadding(horizontal: 16.w, vertical: 12.h);
        }
        return SizedBox.shrink();
      },
    );
  }
}
