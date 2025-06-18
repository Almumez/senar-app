import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/country.dart';

import '../../../../core/services/local_notifications_service.dart';
import '../../../../core/services/location_tracking_service.dart';
import '../../../../core/services/server_gate.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../models/user_model.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState());

  final phone = TextEditingController();
  final password = TextEditingController();
  CountryModel? country;

  Future<Map<String, dynamic>> get body async => {
        "phone_code": country?.phoneCode,
        "phone": phone.text,
        "password": password.text,
        "device_type": Platform.operatingSystem,
        "device_token": kDebugMode && Platform.isIOS ? 'test device token' : await GlobalNotification.getFcmToken(),
      };

  Future<void> login() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/login', body: await body);
    if (result.success) {
      try {
        UserModel.i.fromJson(result.data['data']);
        UserModel.i.save();
        
        // التحقق والتشخيص
        debugPrint('تسجيل دخول المستخدم: ${UserModel.i.fullname}');
        debugPrint('نوع المستخدم: ${UserModel.i.userType}');
        debugPrint('نوع الحساب: ${UserModel.i.accountType}');
        
        // التأكد من أن نوع الحساب يتم تعيينه بشكل صحيح قبل بدء التتبع
        if (UserModel.i.userType == 'free_agent') {
          debugPrint('بدء تتبع الموقع للمندوب الحر...');
          try {
            await sl<LocationTrackingService>().startTracking();
            debugPrint('تم بدء تتبع الموقع بنجاح');
          } catch (e) {
            debugPrint('خطأ في بدء تتبع الموقع: $e');
          }
        } else {
          debugPrint('المستخدم ليس مندوب حر، لن يتم بدء تتبع الموقع');
        }
        
        emit(state.copyWith(requestState: RequestState.done, msg: result.msg));
      } catch (e) {
        debugPrint('خطأ عند معالجة بيانات المستخدم: $e');
        emit(state.copyWith(requestState: RequestState.error, msg: e.toString(), errorType: ErrorType.unknown));
      }
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
