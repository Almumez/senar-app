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
import '../widget/product_agent_order_widget.dart';

class ProductAgentOrdersView extends StatefulWidget {
  const ProductAgentOrdersView({super.key});

  @override
  State<ProductAgentOrdersView> createState() => _ProductAgentOrdersViewState();
}

class _ProductAgentOrdersViewState extends State<ProductAgentOrdersView> {
  final cubit = sl<ProductAgentOrdersCubit>()..getOrders();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: LocaleKeys.orders.tr(),
        withBack: false,
      ),
      body: BlocBuilder<ProductAgentOrdersCubit, ProductAgentOrdersState>(
        bloc: cubit,
        buildWhen: (previous, current) => previous.getOrdersState != current.getOrdersState,
        builder: (context, state) {
          if (state.getOrdersState.isDone && cubit.orders.isEmpty) {
            return Center(child: Text(LocaleKeys.no_orders.tr(), style: context.mediumText.copyWith(fontSize: 14)));
          }
          if (state.getOrdersState.isDone && cubit.orders.isNotEmpty) {
            return PullToRefresh(
              onRefresh: cubit.reload,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                controller: cubit.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: cubit.orders.length,
                itemBuilder: (context, index) {
                  final item = cubit.orders[index];
                  return ProductAgentOrderWidget(item: item, onBack: () => cubit.reload());
                },
              ),
            );
          }
          if (state.getOrdersState.isError) {
            return CustomErrorWidget(
              title: LocaleKeys.orders.tr(),
              subtitle: state.msg,
              errType: state.errorType,
            );
          }
          return LoadingApp();
        },
      ),
    );
  }
}
