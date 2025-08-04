import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../views/rate_agent.dart';

import '../../../../../../../core/utils/enums.dart';
import '../../../../../core/services/server_gate.dart';
import '../../../../../core/widgets/flash_helper.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../../../models/cancel_reasons.dart';
import '../../../../../models/client_order.dart';
import 'states.dart';

class ClientOrderDetailsCubit extends Cubit<ClientOrderDetailsState> {
  ClientOrderDetailsCubit() : super(ClientOrderDetailsState());

  ClientOrderModel? data;
  String? paymentMethod;
  TextEditingController cancelReasonController = TextEditingController();
  String? paymentId = '';

  CancelReasonsModel? cancelReason;
  Future<void> getDetails({required String id, required String type}) async {
    getUrl() {
      if (["supply", "recharge", "distribution", "maintenance"].contains(type)) {
        return "client/order/$type/$id";
      } else {
        return "client/product-order/$id";
      }
    }

    emit(state.copyWith(detailsState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(
      url: getUrl(),
    );
    if (result.success) {
      data = ClientOrderModel.fromJson(result.data['data']);

      emit(state.copyWith(detailsState: RequestState.done));
    } else {
      emit(state.copyWith(detailsState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> pay() async {
    emit(state.copyWith(payState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'client/order/pay/${data?.id}',
      body: {
        "payment_method": paymentMethod,
        "total_price": data?.totalPrice,
        "transaction_id": paymentId,
        "gateway_response": paymentId != null && paymentId!.isNotEmpty && paymentMethod != 'cash' ? {
          'transaction_id': paymentId,
          'payment_method': paymentMethod,
          'amount': data?.totalPrice,
          'currency': 'SAR',
          'status': 'success'
        } : null,
      },
    );
    if (result.success) {
      FlashHelper.showToast(result.msg, type: MessageType.success);
      data?.paymentMethod = paymentMethod!;
      data?.isPaid = true;
      refreshOrder();
      emit(state.copyWith(payState: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(payState: RequestState.error));
    }
  }

  refreshOrder() {
    emit(state.copyWith(detailsState: RequestState.loading));
    emit(state.copyWith(detailsState: RequestState.done));
  }

  Future<void> cancel() async {
    emit(state.copyWith(cancelState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'client/order/cancel/${data?.id}',
      body: {
        "cancel_reason": cancelReasonController.text,
      },
    );
    if (result.success) {
      data?.status = 'canceled';
      refreshOrder();
      emit(state.copyWith(cancelState: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(cancelState: RequestState.error));
    }
  }

  Future<void> rate(RateData rateData) async {
    log(rateData.rateMsg);
    log(rateData.comment.text);
    log(rateData.rating.toString());
    emit(state.copyWith(rateState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'client/order/${data?.id}/rate',
      body: {
        "comment": rateData.rateMsg == LocaleKeys.another_comment ? rateData.comment.text : rateData.rateMsg.tr(),
        "rating": rateData.rating,
      },
    );
    if (result.success) {
      FlashHelper.showToast(result.msg, type: MessageType.success);
      data?.isRated = true;
      refreshOrder();
      emit(state.copyWith(rateState: RequestState.done));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(rateState: RequestState.error));
    }
  }
}
