import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/services/server_gate.dart';
import '../../../../../../core/utils/enums.dart';
import 'states.dart';

class ProfitsCubit extends Cubit<ProfitsState> {
  ProfitsCubit() : super(ProfitsState());

  String? profits;

  Future<void> getProfits(String date) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(
      url: 'general/profile/earnings',
      params: {'date': date},
    );
    if (result.success) {
      profits = result.data['data'].toString();
      emit(state.copyWith(requestState: RequestState.done));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> updateProfits({required String date, required String type}) async {
    emit(state.copyWith(updateStatus: RequestState.loading, type: type));
    final result = await ServerGate.i.getFromServer(
      url: 'general/profile/earnings',
      params: {'date': date},
    );
    if (result.success) {
      profits = result.data['data'].toString();

      emit(state.copyWith(updateStatus: RequestState.done, type: ''));
    } else {
      emit(state.copyWith(updateStatus: RequestState.error, msg: result.msg, errorType: result.errType, type: ''));
    }
  }
}
