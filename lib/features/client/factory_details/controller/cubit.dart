import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/services/server_gate.dart';
import '../../../../../../core/utils/enums.dart';
import '../../../../models/factory.dart';
import 'states.dart';

class FactoryDetailsCubit extends Cubit<FactoryDetailsState> {
  FactoryDetailsCubit() : super(FactoryDetailsState());

  FactoryModel? data;
  FactoryServiceType? type;

  Future<void> getDetails({required String id}) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(
      url: type == FactoryServiceType.factory ? "client/services/factory/$id/products" : "client/services/accessory/$id/products",
    );
    if (result.success) {
      data = FactoryModel.fromJson(result.data['data']['merchant']);

      emit(state.copyWith(requestState: RequestState.done));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
