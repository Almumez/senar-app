import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes_fun.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../models/technician_order.dart';
import 'order_details_state.dart';

class TechnicianOrderDetailsCubit extends Cubit<TechnicianOrderDetailsState> {
  TechnicianOrderDetailsCubit() : super(TechnicianOrderDetailsState());
  TechnicianOrderModel? order;

  List<InspectionReport> inspectionReports = [
    InspectionReport(
      description: TextEditingController(),
      price: TextEditingController(),
    )
  ];
  getOrderDetails(String id, bool isOffer) async {
    emit(state.copyWith(getOrderState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: isOffer ? 'technician/order/offer/$id' : 'technician/order/$id');
    if (result.success) {
      order = TechnicianOrderModel.fromJson(result.data['data']);
      emit(state.copyWith(getOrderState: RequestState.done));
    } else {
      emit(state.copyWith(getOrderState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  acceptOrder([String? merchantId]) async {
    emit(state.copyWith(acceptState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'technician/order/accept/${order?.id}',
      body: {"merchant_id": merchantId},
    );
    if (result.success) {
      FlashHelper.showToast(result.msg, type: MessageType.success);
      getOrderDetails(order!.id, false);
      emit(state.copyWith(acceptState: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(acceptState: RequestState.error));
    }
  }

  rejectOrder() async {
    emit(state.copyWith(acceptState: RequestState.loading));
    final result = await ServerGate.i.deleteFromServer(
      url: 'technician/order/reject/${order?.id}',
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

  checkNow() async {
    emit(state.copyWith(checkNowStatus: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'technician/order/${order?.id}/checking',
    );
    if (result.success) {
      FlashHelper.showToast(result.msg, type: MessageType.success);
      order = TechnicianOrderModel.fromJson(result.data['data']);
      refrishOrder();
      emit(state.copyWith(checkNowStatus: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(checkNowStatus: RequestState.error));
    }
  }

  // String? bill;
  sendReport() async {
    emit(state.copyWith(checkNowStatus: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'technician/order/${order?.id}/send-report',
      body: {
        'issue': inspectionReports.map((e) => {"problem_description": e.description.text, "price": e.price.text}).toList()
      },
    );
    if (result.success) {
      FlashHelper.showToast(result.msg, type: MessageType.success);
      order = TechnicianOrderModel.fromJson(result.data['data']);
      refrishOrder();
      emit(state.copyWith(checkNowStatus: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(checkNowStatus: RequestState.error));
    }
  }

  refrishOrder() {
    emit(state.copyWith(getOrderState: RequestState.loading));
    emit(state.copyWith(getOrderState: RequestState.done));
  }

  addInspectionReport() {
    if (isReportCompleted()) {
      inspectionReports.add(InspectionReport(
        description: TextEditingController(),
        price: TextEditingController(),
      ));
      emit(state.copyWith(getOrderState: RequestState.loading));
      emit(state.copyWith(getOrderState: RequestState.done));
    } else {
      FlashHelper.showToast("من فضلك اكمل التقرير");
    }
  }

  isReportCompleted() {
    for (var element in inspectionReports) {
      if (element.description.text.isEmpty || element.price.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  void removeInspectionReport() {
    if (inspectionReports.length > 1) {
      inspectionReports.removeLast();
      emit(state.copyWith(getOrderState: RequestState.loading));
      emit(state.copyWith(getOrderState: RequestState.done));
    }
  }

  complete() async {
    emit(state.copyWith(completeOrderState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'technician/order/${order?.id}/complete',
    );
    if (result.success) {
      FlashHelper.showToast(result.msg, type: MessageType.success);
      order = TechnicianOrderModel.fromJson(result.data['data']);
      refrishOrder();
      emit(state.copyWith(completeOrderState: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(completeOrderState: RequestState.error));
    }
  }
}

class InspectionReport {
  final TextEditingController description;
  final TextEditingController price;

  InspectionReport({
    required this.description,
    required this.price,
  });
}
