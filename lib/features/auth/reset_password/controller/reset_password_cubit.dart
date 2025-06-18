import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import 'reset_password_states.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super(ResetPasswordState());

  late String phone, phoneCode, code;
  final password = TextEditingController();
  final passwordConfirmation = TextEditingController();

  Map<String, dynamic> get body => {
        "phone": phone,
        "phone_code": phoneCode,
        "code": code,
        "password": password.text,
        "password_confirmation": passwordConfirmation.text,
      };

  Future<void> resetPassword() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/reset-forgotten-password', body: body);
    if (result.success) {
      emit(state.copyWith(requestState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
