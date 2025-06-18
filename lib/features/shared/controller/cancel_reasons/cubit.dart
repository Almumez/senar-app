import '../../../../models/cancel_reasons.dart';

import '../../../../core/utils/enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/server_gate.dart';

import 'states.dart';

class CancelReasonsCubit extends Cubit<CancelReasonsState> {
  CancelReasonsCubit() : super(CancelReasonsState());
  List<CancelReasonsModel> reasons = [];

  Future<void> getReasons() async {
    if (reasons.isNotEmpty) {
      emit(state.copyWith(reasonsState: RequestState.done));
    } else {
      emit(state.copyWith(reasonsState: RequestState.loading));
      final result = await ServerGate.i.getFromServer(url: 'general/cancel-reasons');
      if (result.success) {
        reasons = List<CancelReasonsModel>.from((result.data['data'] ?? []).map((e) => CancelReasonsModel.fromJson(e)));
        emit(state.copyWith(reasonsState: RequestState.done));
      } else {
        emit(state.copyWith(reasonsState: RequestState.error, msg: result.msg, errorType: result.errType));
      }
    }
  }
}
