import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_notifications_service.dart';
import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../models/user_model.dart';
import 'complete_register_phone_state.dart';

class CompleteRegisterPhoneCubit extends Cubit<CompleteRegisterPhoneState> {
  CompleteRegisterPhoneCubit() : super(CompleteRegisterPhoneState());

  final nameController = TextEditingController();
  final ageController = TextEditingController(); // إضافة حقل العمر
  String? phone, phoneCode;
  String gender = 'male'; // القيمة الافتراضية للجنس
  UserType userType = UserType.client; // القيمة الافتراضية لنوع المستخدم

  void setGender(String value) {
    gender = value;
    // Emitir un nuevo estado con el género actualizado para notificar a la UI
    emit(state.copyWith(genderValue: value));
  }

  Map<String, dynamic> get body => {
    "name": nameController.text,
    "phone": phone,
    "phone_code": phoneCode,
    "gender": gender,
    "age": int.tryParse(ageController.text) ?? 0, // إضافة العمر إلى الطلب
  };

  Future<void> completeRegister() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'general/complete-register-phone',
      body: body,
    );

    if (result.success) {
      if (result.data['data'] != null) {
        UserModel.i.fromJson(result.data['data']);
        UserModel.i.save();
        
        // إرسال توكن الجهاز إلى الخادم بعد اكتمال التسجيل بنجاح
        await GlobalNotification.sendTokenToServer();
      }
      emit(state.copyWith(requestState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(
        requestState: RequestState.error,
        msg: result.msg,
        errorType: result.errType,
      ));
    }
  }
} 