import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import 'select_merchent_state.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/factory.dart';

class SelectMerchentCubit extends Cubit<SelectMerchentState> {
  SelectMerchentCubit() : super(SelectMerchentState());
  List<FactoryModel> factories = [];
  getMerchent() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: 'free-agent/order/neareast-merchantes');
    if (result.success) {
      factories = List<FactoryModel>.from(result.data['data'].map((x) => FactoryModel.fromJson(x)));

      if (factories.isEmpty) {
        return emit(state.copyWith(
          requestState: RequestState.error,
          errorType: ErrorType.empty,
          msg: LocaleKeys.no_nearby_stores.tr(),
        ));
      }
      emit(state.copyWith(requestState: RequestState.done));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
