import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../models/user_model.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/successfully_sheet.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/agent_order.dart';
import 'order_details_state.dart';

class AgentOrderDetailsCubit extends Cubit<AgentOrderDetailsState> {
  AgentOrderDetailsCubit() : super(AgentOrderDetailsState());
  AgentOrderModel? order;
  getOrderDetails(String id, String type) async {
    emit(state.copyWith(getOrderState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: '${UserModel.i.accountType.isFreeAgent ? "free-" : ""}agent/order/$type/$id');
    if (result.success) {
      order = AgentOrderModel.fromJson(result.data['data']);
      emit(state.copyWith(getOrderState: RequestState.done));
    } else {
      order = null;
      emit(state.copyWith(getOrderState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  acceptOrder([String? merchantId]) async {
    emit(state.copyWith(acceptState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: '${UserModel.i.accountType.isFreeAgent ? "free-" : ""}agent/order/accept/${order?.id}',
      body: {"merchant_id": merchantId},
    );
    if (result.success) {
      FlashHelper.showToast(result.msg, type: MessageType.success);
      
      if (result.data != null && result.data['data'] != null) {
        order = AgentOrderModel.fromJson(result.data['data']);
        print("DEBUG: Order accepted - new status: ${order?.status}");
      } else {
        await getOrderDetails(order!.id, order!.type);
      }
      
      emit(state.copyWith(acceptState: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(acceptState: RequestState.error));
    }
  }

  rejectOrder([String? reason]) async {
    emit(state.copyWith(acceptState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: '${UserModel.i.accountType.isFreeAgent ? "free-" : ""}agent/order/reject/${order?.id}',
      body: {'reason': reason ?? ''},
    );
    if (result.success) {
      FlashHelper.showToast(result.msg, type: MessageType.success);
      Navigator.pop(navigator.currentContext!);
      emit(state.copyWith(acceptState: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(acceptState: RequestState.error));
    }
  }

  changeStatus() async {
    emit(state.copyWith(changeStatus: RequestState.loading));
    final result = await ServerGate.i.putToServer(
      url: '${UserModel.i.accountType.isFreeAgent ? "free-" : ""}agent/order/${order?.id}/change-status',
      body: {'status': order?.nextStatus},
    );
    if (result.success) {
      FlashHelper.showToast(result.msg, type: MessageType.success);
      order = AgentOrderModel.fromJson(result.data['data']);

      refreshOrder();
      if (order!.status == 'completed') {
        showModalBottomSheet(
          elevation: 0,
          context: navigator.currentContext!,
          isScrollControlled: true,
          isDismissible: true,
          builder: (context) => SuccessfullySheet(
            title: LocaleKeys.order_delivered_successfully.tr(),
          ),
        );
      }
      emit(state.copyWith(changeStatus: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(changeStatus: RequestState.error));
    }
  }

  String? bill;
  sendBill() async {
    emit(state.copyWith(changeStatus: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: '${UserModel.i.accountType.isFreeAgent ? "free-" : ""}agent/order/recharge/${order?.id}/send-bill',
      body: {'price': bill},
    );
    if (result.success) {
      FlashHelper.showToast(result.msg, type: MessageType.success);
      order = AgentOrderModel.fromJson(result.data['data']);
      refreshOrder();
      emit(state.copyWith(changeStatus: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(changeStatus: RequestState.error));
    }
  }

  refreshOrder() {
    emit(state.copyWith(getOrderState: RequestState.loading));
    Future.delayed(Duration(milliseconds: 50), () {
      emit(state.copyWith(getOrderState: RequestState.done));
    });
  }
}
