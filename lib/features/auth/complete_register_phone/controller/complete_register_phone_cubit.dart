import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../models/user_model.dart';
import 'complete_register_phone_state.dart';

class CompleteRegisterPhoneCubit extends Cubit<CompleteRegisterPhoneState> {
  CompleteRegisterPhoneCubit() : super(CompleteRegisterPhoneState());

  final nameController = TextEditingController();
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
  };

  Future<void> completeRegister() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'general/complete-register-phone',
      body: body
    );

    if (result.success) {
      // تحميل بيانات المستخدم إذا كانت موجودة في الاستجابة
      if (result.data['data'] != null) {
        UserModel.i.fromJson(result.data['data']);
        
        // تحديد نوع المستخدم من البيانات المستلمة
        if (UserModel.i.userType.isNotEmpty) {
          switch (UserModel.i.userType) {
            case "client":
              userType = UserType.client;
              break;
            case "free_agent":
              userType = UserType.freeAgent;
              break;
            case "agent":
              userType = UserType.agent;
              break;
            case "product_agent":
              userType = UserType.productAgent;
              break;
            case "technician":
              userType = UserType.technician;
              break;
          }
        }
        
        // حفظ بيانات المستخدم
        if (UserModel.i.isAuth) {
          UserModel.i.save();
          debugPrint('تم تسجيل المستخدم بنجاح: ${UserModel.i.fullname}');
          debugPrint('نوع المستخدم: ${UserModel.i.userType}');
        }
      }
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