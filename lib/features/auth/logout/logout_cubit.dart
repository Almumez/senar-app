import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_notifications_service.dart';
import '../../../../core/services/location_tracking_service.dart';
import '../../../../core/services/server_gate.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../models/user_model.dart';
import 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutState());

  Future<Map<String, dynamic>> get body async => {
        "device_type": Platform.operatingSystem,
        "device_token": kDebugMode && Platform.isIOS ? 'test device token' : await GlobalNotification.getFcmToken(),
      };

  Future<void> logout() async {
    emit(state.copyWith(requestState: RequestState.loading));
    
    // Stop location tracking if it was running
    if (UserModel.i.accountType == UserType.freeAgent) {
      sl<LocationTrackingService>().stopTracking();
    }
    
    final result = await ServerGate.i.sendToServer(url: 'general/logout', body: await body);
    if (result.success) {
      UserModel.i.clear();
      UserModel.i.save();
      emit(state.copyWith(requestState: RequestState.done, msg: result.msg));
    } else {
      UserModel.i.clear();
      UserModel.i.save();
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
