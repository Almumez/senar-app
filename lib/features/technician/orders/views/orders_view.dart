import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/extensions.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/appbar.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widgets/technician_order_widget.dart';

class TechnicianOrdersView extends StatefulWidget {
  const TechnicianOrdersView({super.key});

  @override
  State<TechnicianOrdersView> createState() => _TechnicianOrdersViewState();
}

class _TechnicianOrdersViewState extends State<TechnicianOrdersView> {
  final cubit = sl<TechnicianOrdersCubit>()..getOrders();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: LocaleKeys.orders.tr(),
        withBack: false,
      ),
      body: PullToRefresh(
        onRefresh: cubit.reload,
        child: BlocBuilder<TechnicianOrdersCubit, TechnicianOrdersState>(
          bloc: cubit,
          buildWhen: (previous, current) => previous.getOrdersState != current.getOrdersState,
          builder: (context, state) {
            if (state.getOrdersState.isDone) {
              if (cubit.orders.isEmpty) {
                return Center(
                  child: Text(
                    LocaleKeys.no_orders.tr(),
                    style: context.mediumText.copyWith(fontSize: 14),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                controller: cubit.scrollController,
                itemCount: cubit.orders.length,
                itemBuilder: (context, index) {
                  final item = cubit.orders[index];
                  return TechnicianOrderWidget(item: item, onBack: () => cubit.reload());
                },
              );
            } else if (state.getOrdersState.isError) {
              return CustomErrorWidget(
                title: LocaleKeys.orders.tr(),
                subtitle: state.msg,
                errType: state.errorType,
              );
            } else {
              return LoadingApp();
            }
          },
        ),
      ),
    );
  }
}
