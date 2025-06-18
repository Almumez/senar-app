import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_notifications_service.dart';
import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../models/user_model.dart';
import 'verify_phone_states.dart';

class VerifyPhoneCubit extends Cubit<VerifyPhoneState> {
  VerifyPhoneCubit() : super(VerifyPhoneState());

  VerifyType? type;
  String? phone, phoneCode;
  final code = TextEditingController();

  String get url => type == VerifyType.register ? 'general/verify' : 'general/check-code';
  Future<Map<String, dynamic>> get body async => {
        "phone": phone,
        "phone_code": phoneCode,
        "otp": code.text,
        if (type == VerifyType.register) "device_type": Platform.operatingSystem,
        if (type == VerifyType.register) "device_token": kDebugMode && Platform.isIOS ? 'test device token' : await GlobalNotification.getFcmToken(),
      };

  Future<void> verify() async {
    emit(state.copyWith(verifyState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: url, body: await body);
    if (result.success) {
      if (type == VerifyType.register) {
        UserModel.i.fromJson(result.data['data']);
        if (UserModel.i.isAuth) UserModel.i.save();
      }
      emit(state.copyWith(verifyState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(verifyState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> resend() async {
    emit(state.copyWith(resendState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/forget-password', body: {
      "phone": phone,
      "phone_code": phoneCode,
    });
    if (result.success) {
      emit(state.copyWith(resendState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(resendState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  FutureOr<void> editEmail(String newCode, String newPhone) async {
    emit(state.copyWith(editEmailState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'general/modify-phone-number',
      body: {"old_phone_code": phoneCode, "old_phone": phone, "new_phone_code": newCode, "new_phone": newPhone},
    );
    if (result.success) {
      phone = newPhone;
      phoneCode = newCode;
      emit(state.copyWith(editEmailState: RequestState.done, msg: result.msg, newPhone: newPhone, newCode: newCode));
    } else {
      FlashHelper.showToast(result.msg);
      emit(
        state.copyWith(
          editEmailState: RequestState.error,
          msg: result.msg,
          errorType: result.errType,
        ),
      );
    }
  }
}
