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
  bool userExists = true;

  String get url {
    switch (type) {
      case VerifyType.register:
        return 'general/verify-otp';
      case VerifyType.login:
        return 'general/verify-otp';
      default:
        return 'general/check-code';
    }
  }
  
  Map<String, dynamic> get body => {
        "phone": phone,
        "phone_code": phoneCode,
        "otp": code.text,
      };

  Future<void> verify() async {
    emit(state.copyWith(verifyState: RequestState.loading));

    final result = await ServerGate.i.sendToServer(url: url, body: body);

    if (result.success) {
      // Verificar si el usuario existe o no basado en la respuesta de la API
      if (result.data['data'] != null) {
        // Comprobar si la API devolvió user_exists: false
        if (result.data['data']['user_exists'] != null) {
          userExists = result.data['data']['user_exists'];
          debugPrint('API devolvió user_exists: $userExists');
        } else {
          // Si no hay campo user_exists, asumimos que el usuario existe y sus datos están en la respuesta
          userExists = true;
          
          // Cargar los datos del usuario directamente desde la respuesta
          UserModel.i.fromJson(result.data['data']);
          
          // Guardar los datos del usuario si está autenticado
          if (UserModel.i.isAuth) {
            UserModel.i.save();
            debugPrint('Usuario autenticado y datos guardados: ${UserModel.i.fullname}');
            debugPrint('Tipo de usuario: ${UserModel.i.userType}');
            
            // إرسال توكن الجهاز إلى الخادم بعد تسجيل الدخول بنجاح
            await GlobalNotification.sendTokenToServer();
          }
        }
      }
      
      emit(state.copyWith(verifyState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(verifyState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> resend() async {
    emit(state.copyWith(resendState: RequestState.loading));
    final url = type == VerifyType.login ? 'general/request-otp' : 'general/forget-password';
    final result = await ServerGate.i.sendToServer(url: url, body: {
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
