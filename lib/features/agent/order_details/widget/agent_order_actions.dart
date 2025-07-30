import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../gen/locale_keys.g.dart';
import '../cubit/order_details_cubit.dart';
import '../cubit/order_details_state.dart';
import 'reject_reason_sheet.dart';

class AgentOrderActions extends StatefulWidget {
  final AgentOrderDetailsCubit cubit;
  const AgentOrderActions({super.key, required this.cubit});

  @override
  State<AgentOrderActions> createState() => _AgentOrderActionsState();
}

class _AgentOrderActionsState extends State<AgentOrderActions> {
  AgentOrderDetailsCubit get cubit => widget.cubit;
  
  // دالة لعرض نافذة سبب الرفض
  void _showRejectReasonSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: RejectReasonSheet(cubit: cubit),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: BlocBuilder<AgentOrderDetailsCubit, AgentOrderDetailsState>(
        bloc: cubit,
        buildWhen: (previous, current) => 
          previous.getOrderState != current.getOrderState || 
          previous.acceptState != current.acceptState ||
          previous.changeStatus != current.changeStatus,
        builder: (context, state) {
          // Print debug information for all statuses
          print("DEBUG: Current order status: ${cubit.order?.status}");
          print("DEBUG: Payment method: ${cubit.order?.paymentMethod}");
          print("DEBUG: Is paid: ${cubit.order?.isPaid}");
          print("DEBUG: Button should show: ${cubit.order?.status == "on_way" && (cubit.order!.isPaid || cubit.order!.paymentMethod == 'cash')}");
          
          if (cubit.order?.status == "pending") {
            return BlocBuilder<AgentOrderDetailsCubit, AgentOrderDetailsState>(
              bloc: cubit,
              builder: (context, state) {
                return AbsorbPointer(
                  absorbing: state.acceptState.isLoading || state.rejectOrder.isLoading,
                  child: Opacity(
                    opacity: state.acceptState.isLoading || state.rejectOrder.isLoading ? 0.4 : 1,
                    child: AppBtn(
                      onPressed: () {
                        // if (UserModel.i.accountType.isAgent) {
                        cubit.acceptOrder();
                        // } else {
                        //   push(NamedRoutes.selectMerchent).then((v) {
                        //     if (v != null) {
                        //       cubit.acceptOrder(v);
                        //     }
                        //   });
                        // }
                      },
                      title: LocaleKeys.accept.tr(),
                    ),
                  ),
                ).withPadding(vertical: 12.h, horizontal: 16.w);
              },
            );
          } else if (cubit.order?.status == 'on_way' && cubit.order?.price == 0) {
            return BlocBuilder<AgentOrderDetailsCubit, AgentOrderDetailsState>(
              bloc: cubit,
              buildWhen: (previous, current) => previous.changeStatus != current.changeStatus,
              builder: (context, state) {
                return AppBtn(
                  enable: cubit.bill != null,
                  loading: state.changeStatus.isLoading,
                  title: LocaleKeys.send.tr(),
                  onPressed: () => cubit.sendBill(),
                );
              },
            ).withPadding(horizontal: 16.w, vertical: 12.h);
          } else if (cubit.order?.status == "on_way") {
            return BlocBuilder<AgentOrderDetailsCubit, AgentOrderDetailsState>(
              bloc: cubit,
              buildWhen: (previous, current) => previous.changeStatus != current.changeStatus || previous.rejectOrder != current.rejectOrder,
              builder: (context, state) {
                return Row(
                  children: [
                    Expanded(
                      child: AppBtn(
                        loading: state.changeStatus.isLoading,
                        title: "btn_status_trans.${cubit.order?.status}".tr(),
                        onPressed: () => cubit.changeStatus(),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: AppBtn(
                        onPressed: _showRejectReasonSheet,
                        textColor: context.errorColor,
                        backgroundColor: Colors.transparent,
                        title: LocaleKeys.reject.tr(),
                      ),
                    ),
                  ],
                ).withPadding(horizontal: 16.w, vertical: 12.h);
              },
            );
          } else if (cubit.order?.status == "accepted") {
            print("DEBUG: Order status is ACCEPTED - Status: ${cubit.order?.status}");
            return BlocBuilder<AgentOrderDetailsCubit, AgentOrderDetailsState>(
              bloc: cubit,
              buildWhen: (previous, current) => previous.changeStatus != current.changeStatus || previous.acceptState != current.acceptState || previous.getOrderState != current.getOrderState,
              builder: (context, state) {
                return Row(
                  children: [
                    Expanded(
                      child: AppBtn(
                        loading: state.changeStatus.isLoading,
                        title: "btn_status_trans.${cubit.order?.status}".tr(),
                        onPressed: () => cubit.changeStatus(),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: AppBtn(
                        onPressed: _showRejectReasonSheet,
                        textColor: context.errorColor,
                        backgroundColor: Colors.transparent,
                        title: LocaleKeys.reject.tr(),
                      ),
                    ),
                  ],
                ).withPadding(horizontal: 16.w, vertical: 12.h);
              },
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
