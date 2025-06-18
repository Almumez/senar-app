import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/error_widget.dart';

import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/extensions.dart';
import '../../../gen/locale_keys.g.dart';
import '../../shared/components/appbar.dart';
import '../orders/components/client_order_item.dart';
import '../orders/controller/orders/cubit.dart';
import '../orders/controller/orders/states.dart';

class ClientOrdersHistoryView extends StatefulWidget {
  const ClientOrdersHistoryView({super.key});

  @override
  State<ClientOrdersHistoryView> createState() => _ClientOrdersHistoryViewState();
}

class _ClientOrdersHistoryViewState extends State<ClientOrdersHistoryView> {
  final cubit = sl<ClientOrdersCubit>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    cubit.fetchOrders();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
        cubit.fetchOrders(isPagination: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await cubit.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.orders_history.tr()),
      body: BlocBuilder<ClientOrdersCubit, ClientOrdersCState>(
        bloc: cubit,
        builder: (context, state) {
          if (state.getOrdersState == RequestState.loading && cubit.items.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.getOrdersState == RequestState.error && cubit.items.isEmpty) {
            return Center(child: CustomErrorWidget(title: state.msg));
          }
          if (state.getOrdersState == RequestState.done && cubit.items.isEmpty) {
            return Center(child: Text(LocaleKeys.no_orders.tr()));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            color: Theme.of(context).primaryColor,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              controller: _scrollController,
              itemCount: cubit.items.length + (state.paginationState == RequestState.loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == cubit.items.length) {
                  return Center(child: CircularProgressIndicator());
                }
                return ClientOrderCard(data: cubit.items[index], onBack: () => cubit.fetchOrders()).withPadding(bottom: 20.h);
              },
            ),
          );
        },
      ),
    );
  }
}
