import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/country.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState());

  final phone = TextEditingController();
  CountryModel? country;

  Map<String, dynamic> get body => {
        "phone": phone.text,
        "phone_code": country?.phoneCode,
      };

  Future<void> requestOtp() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'general/request-otp', 
      body: body
    );
    
    if (result.success) {
      emit(state.copyWith(requestState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(
        requestState: RequestState.error, 
        msg: result.msg, 
        errorType: result.errType
      ));
    }
  }
}
