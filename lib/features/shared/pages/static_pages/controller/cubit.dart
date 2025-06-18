import '../../../../../models/static.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/server_gate.dart';
import '../../../../../core/utils/enums.dart';
import 'states.dart';

class StaticCubit extends Cubit<StaticState> {
  StaticCubit() : super(StaticState());

  Future<void> getStatic(String url) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: url);
    if (result.success) {
      emit(state.copyWith(requestState: RequestState.done, data: StaticModel.fromJson(result.data['data'])));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
