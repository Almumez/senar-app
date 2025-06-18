import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../models/technician_order.dart';
import 'orders_state.dart';

class TechnicianOrdersCubit extends Cubit<TechnicianOrdersState> {
  TechnicianOrdersCubit() : super(TechnicianOrdersState());

  List<TechnicianOrderModel> orders = [];
  String? next;
  final scrollController = ScrollController();

  getOrders() async {
    emit(state.copyWith(getOrdersState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: 'technician/order');
    if (result.success) {
      orders = List<TechnicianOrderModel>.from(result.data['data'].map((x) => TechnicianOrderModel.fromJson(x)));
      next = result.data?['links']?['next'];
      addListener();
      emit(state.copyWith(getOrdersState: RequestState.done));
    } else {
      emit(state.copyWith(getOrdersState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  getNotificationsPaging() async {
    emit(state.copyWith(getOrdersPagingState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: next!);
    if (result.success) {
      final list = List<TechnicianOrderModel>.from(result.data['data'].map((x) => TechnicianOrderModel.fromJson(x)));
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
    orders.clear();
    next = null;
    await getOrders();
  }
}
