import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../models/agent_order.dart';
import 'orders_state.dart';

class ProductAgentOrdersCubit extends Cubit<ProductAgentOrdersState> {
  ProductAgentOrdersCubit() : super(ProductAgentOrdersState());

  List<AgentOrderModel> orders = [];
  String? next;
  final scrollController = ScrollController();

  getOrders({bool withLoading = true}) async {
    if (withLoading) emit(state.copyWith(getOrdersState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: 'product-agent/order');
    if (result.success) {
      orders = List<AgentOrderModel>.from(result.data['data'].map((x) => AgentOrderModel.fromJson(x)));
      next = result.data?['links']?['next'];
      addListener();
      if (!withLoading) emit(state.copyWith(getOrdersState: RequestState.loading));
      emit(state.copyWith(getOrdersState: RequestState.done));
    } else {
      emit(state.copyWith(getOrdersState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  getNotificationsPaging() async {
    emit(state.copyWith(getOrdersPagingState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: next!);
    if (result.success) {
      final list = List<AgentOrderModel>.from(result.data['data'].map((x) => AgentOrderModel.fromJson(x)));
      orders = orders + list;
      next = result.data?['links']?['next'];
      refreshList();
      emit(state.copyWith(getOrdersPagingState: RequestState.done));
    } else {
      emit(state.copyWith(getOrdersPagingState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  refreshList() {
    emit(state.copyWith(getOrdersState: RequestState.loading));
    emit(state.copyWith(getOrdersState: RequestState.done));
  }

  addListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (next == null) return;
        if ([state.getOrdersState, state.getOrdersPagingState].contains(RequestState.loading)) return;
        getNotificationsPaging();
      }
    });
  }

  Future<void> reload() async {
    reset();
    getOrders(withLoading: false);
  }

  reset() {
    orders.clear();
    next = null;
  }
}
