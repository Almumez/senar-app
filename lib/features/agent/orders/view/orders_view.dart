import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gasapp/core/utils/extensions.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/appbar.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widget/agent_order_widget.dart';

class AgentOrdersView extends StatefulWidget {
  const AgentOrdersView({super.key});

  @override
  State<AgentOrdersView> createState() => _AgentOrdersViewState();
}

class _AgentOrdersViewState extends State<AgentOrdersView> {
  final cubit = sl<AgentOrdersCubit>()..getOrders();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: LocaleKeys.orders.tr(),
        withBack: false,
      ),
      body: BlocBuilder<AgentOrdersCubit, AgentOrdersState>(
        bloc: cubit,
        buildWhen: (previous, current) => previous.getOrdersState != current.getOrdersState,
        builder: (context, state) {
          if (state.getOrdersState.isDone) {
            return PullToRefresh(
              onRefresh: cubit.reload,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                controller: cubit.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: cubit.orders.length,
                itemBuilder: (context, index) {
                  final item = cubit.orders[index];
                  return AgentOrderWidget(item: item, onBack: () => cubit.reload()).withPadding(bottom: 20.h);
                },
              ),
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
    );
  }
}
