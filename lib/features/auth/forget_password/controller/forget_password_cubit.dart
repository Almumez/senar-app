import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../models/country.dart';
import 'forget_password_states.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit() : super(const ForgetPasswordState()) {
    // Inicializar con el código de país de Arabia Saudita por defecto
    country = CountryModel.fromJson({
      'name': 'Saudi Arabia',
      'phone_code': '966',
      'flag': '',
      'short_name': 'SA',
      'phone_limit': 9
    });
  }

  final phone = TextEditingController();
  CountryModel? country;
  Map<String, dynamic> get body => {"phone": phone.text, "phone_code": country?.phoneCode ?? '966'};
  Future<void> forgotPassword() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/forget-password', body: body);
    if (result.success) {
      emit(state.copyWith(requestState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
