import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../cubit/order_details_cubit.dart';
import '../cubit/order_details_state.dart';

class ProductAgentOrderActions extends StatefulWidget {
  final ProductAgentOrderDetailsCubit cubit;
  const ProductAgentOrderActions({super.key, required this.cubit});

  @override
  State<ProductAgentOrderActions> createState() => _ProductAgentOrderActionsState();
}

class _ProductAgentOrderActionsState extends State<ProductAgentOrderActions> {
  ProductAgentOrderDetailsCubit get cubit => widget.cubit;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductAgentOrderDetailsCubit, ProductAgentOrderDetailsState>(
        bloc: cubit,
        buildWhen: (previous, current) => previous.getOrderState != current.getOrderState,
        builder: (context, state) {
          if (cubit.state.getOrderState.isDone && cubit.order?.status != 'completed' && cubit.order?.status != 'canceled' && cubit.order?.status != 'on_way') {
            return BlocBuilder<ProductAgentOrderDetailsCubit, ProductAgentOrderDetailsState>(
                bloc: cubit,
                buildWhen: (previous, current) => previous.changeStatus != current.changeStatus,
                builder: (context, state) {
                  return AppBtn(
                    loading: state.changeStatus.isLoading,
                    title: "btn_status_trans.${cubit.order?.status}".tr(),
                    onPressed: () => cubit.changeStatus(),
                  );
                }).withPadding(horizontal: 16.w, vertical: 12.h);
          }
          if (cubit.order?.status == 'on_way' && (cubit.order!.isPaid || cubit.order!.paymentMethod == 'cash')) {
            return BlocBuilder<ProductAgentOrderDetailsCubit, ProductAgentOrderDetailsState>(
                bloc: cubit,
                buildWhen: (previous, current) => previous.changeStatus != current.changeStatus,
                builder: (context, state) {
                  return AppBtn(
                    loading: state.changeStatus.isLoading,
                    title: "btn_status_trans.${cubit.order?.status}".tr(),
                    onPressed: () => cubit.changeStatus(),
                  );
                }).withPadding(horizontal: 16.w, vertical: 12.h);
          }
          return const SizedBox.shrink();
        });
  }
}
