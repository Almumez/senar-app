import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import 'events.dart';
import 'model.dart';
import 'states.dart';

class PaymentInfoBloc extends Bloc<PaymentInfoEvent, PaymentInfoState> {
  PaymentInfoBloc() : super(PaymentInfoState()) {
    on<StartPaymentInfoEvent>(_fetch);
  }

  Future<void> _fetch(StartPaymentInfoEvent event, Emitter<PaymentInfoState> emit) async {
    emit(state.copyWith(state: RequestState.loading));

    final result = await ServerGate.i.getFromServer(url: 'https://gas-app-345b6-default-rtdb.firebaseio.com/.json', params: event.data, constantHeaders: false);
    if (result.success) {
      // print( '=--=--= res ${result.data.runtimeType}');
      // print( '=--=--= res ${result.data}');
      PaymentInfoModel data = PaymentInfoModel.fromJson(result.data);
      // print( '---=-= resp is ${data.toJson()}');

      emit(state.copyWith(state: RequestState.done, msg: result.msg, data: data));
    } else {
      emit(state.copyWith(state: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
