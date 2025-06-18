import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import 'model.dart';
import 'states.dart';

class GoogleMapSearchBloc extends Cubit<GoogleMapSearchState> {
  GoogleMapSearchBloc() : super(GoogleMapSearchState());

  List<GoogleMapSearchModel> list = [];

  Future<void> search(String text) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final response = await ServerGate.i.getFromServer(
      url: "https://api.openrouteservice.org/geocode/search",
      constantHeaders: true,
      params: {
        "text": text,
        "api_key": '5b3ce3597851110001cf62489ad0f86a730849e39550f8d1f22758a4',
      },
    );
    if (response.success) {
      list = List<GoogleMapSearchModel>.from(response.data["features"].map((e) => GoogleMapSearchModel.fromJson(e)));
      emit(state.copyWith(requestState: RequestState.done));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: response.msg, errorType: response.errType));
    }
  }
}
