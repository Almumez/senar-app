import '../../../../core/utils/enums.dart';
import '../../../../models/country.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/server_gate.dart';

import 'states.dart';

class CountriesCubit extends Cubit<CountriesState> {
  CountriesCubit() : super(CountriesState());
  List<CountryModel> counties = [];

  Future<void> getCountries({bool openSheet = false}) async {
    if (counties.isNotEmpty) {
      emit(state.copyWith(countriesState: RequestState.done, openSheet: openSheet));
    } else {
      emit(state.copyWith(countriesState: RequestState.loading));
      final result = await ServerGate.i.getFromServer(url: 'general/list-countries');
      if (result.success) {
        counties = List<CountryModel>.from((result.data['data'] ?? []).map((e) => CountryModel.fromJson(e)));
        emit(state.copyWith(countriesState: RequestState.done, openSheet: openSheet));
      } else {
        emit(state.copyWith(countriesState: RequestState.error, msg: result.msg, errorType: result.errType));
      }
    }
  }
}
