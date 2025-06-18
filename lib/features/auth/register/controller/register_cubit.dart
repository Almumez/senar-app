import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../models/country.dart';
import 'register_states.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterState());

  final fullName = TextEditingController();
  final phone = TextEditingController();
  // final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  CountryModel? country;
  UserType? userType;

  Map<String, dynamic> get body => {
        'full_name': fullName.text,
        'phone_code': country?.phoneCode,
        'phone': phone.text,
        // 'email': email.text,
        'password': password.text,
        'password_confirmation': confirmPassword.text,
        "user_type": userType == UserType.client ? "client" : "free_agent",
      };

  Future<void> register() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/register', body: body);
    if (result.success) {
      emit(state.copyWith(requestState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
