import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/services/server_gate.dart';
import '../../../../../../core/utils/enums.dart';
import '../../../../../models/orders_count.dart';
import 'states.dart';

class OrderCountsCubit extends Cubit<OrderCountsState> {
  OrderCountsCubit() : super(OrderCountsState());

  Future<void> getProfits(String date) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(
      url: 'general/profile/agent-orders-history',
      params: {'date': date},
    );
    if (result.success) {
      emit(state.copyWith(requestState: RequestState.done, counts: OrdersCountModel.fromJson(result.data['data'])));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> updateProfits({required String date, required String type}) async {
    emit(state.copyWith(updateStatus: RequestState.loading, type: type));
    final result = await ServerGate.i.getFromServer(
      url: 'general/profile/agent-orders-history',
      params: {'date': date},
    );
    if (result.success) {
      emit(state.copyWith(updateStatus: RequestState.done, counts: OrdersCountModel.fromJson(result.data['data']), type: ''));
    } else {
      emit(state.copyWith(updateStatus: RequestState.error, msg: result.msg, errorType: result.errType, type: ''));
    }
  }
}
