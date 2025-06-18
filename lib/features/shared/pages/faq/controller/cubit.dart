import '../../../../../models/faq.dart';

import '../../../../../core/services/server_gate.dart';
import '../../../../../core/utils/enums.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'states.dart';

class FaqCubit extends Cubit<FaqState> {
  FaqCubit() : super(FaqState());
  List<FaqModel> faq = [];

  Future<void> getFaq({bool openSheet = false, bool forceRefresh = false}) async {
    if (faq.isNotEmpty && !forceRefresh) {
      emit(state.copyWith(requestState: RequestState.done));
    } else {
      emit(state.copyWith(requestState: RequestState.loading));
      final result = await ServerGate.i.getFromServer(url: 'general/page/qa');
      if (result.success) {
        faq = List<FaqModel>.from((result.data['data'] ?? []).map((e) => FaqModel.fromJson(e)));
        emit(state.copyWith(requestState: RequestState.done));
      } else {
        emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
      }
    }
  }
}
