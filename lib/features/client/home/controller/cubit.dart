import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/services/server_gate.dart';
import '../../../../../../core/utils/enums.dart';
import '../../../../models/client_home.dart';
import 'states.dart';

class ClientHomeCubit extends Cubit<ClientHomeState> {
  ClientHomeCubit() : super(ClientHomeState());
  ClientHomeModel? data;
  Future<void> getHome() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: 'client/home');
    if (result.success) {
      data = ClientHomeModel.fromJson(result.data['data']);
      emit(state.copyWith(requestState: RequestState.done));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
