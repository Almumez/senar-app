import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../models/user_model.dart';

import '../../../../../core/services/server_gate.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../models/country.dart';
import 'state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState());

  CountryModel? country;
  Locale? locale;

  Future<void> changeLanguage(String url) async {
    emit(state.copyWith(changeLanguageState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: url);
    if (result.success) {
      UserModel.i.locale = result.data['data']['locale'];
      UserModel.i.save();
      emit(state.copyWith(changeLanguageState: RequestState.done, msg: result.msg, locale: locale));
    } else {
      emit(state.copyWith(changeLanguageState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> allowNotifications() async {
    emit(state.copyWith(allowNotificationsState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/profile/toggle-notify');
    if (result.success) {
      UserModel.i.isNotified = result.data['data']['is_notified'];
      UserModel.i.save();
      emit(state.copyWith(allowNotificationsState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(allowNotificationsState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> deleteAccount() async {
    emit(state.copyWith(deleteAccountState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/profile/delete-account');
    if (result.success) {
      emit(state.copyWith(deleteAccountState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(deleteAccountState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
