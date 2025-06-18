import 'package:flutter/material.dart';

import '../../../../../core/utils/enums.dart';

class SettingsState {
  final RequestState changeLanguageState, allowNotificationsState, deleteAccountState;
  Locale? locale;
  final String msg;
  final ErrorType errorType;

  SettingsState({
    this.changeLanguageState = RequestState.initial,
    this.allowNotificationsState = RequestState.initial,
    this.deleteAccountState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.locale,
  });

  SettingsState copyWith({
    RequestState? changeLanguageState,
    RequestState? allowNotificationsState,
    RequestState? deleteAccountState,
    String? msg,
    ErrorType? errorType,
    Locale? locale,
  }) =>
      SettingsState(
        changeLanguageState: changeLanguageState ?? this.changeLanguageState,
        allowNotificationsState: allowNotificationsState ?? this.allowNotificationsState,
        deleteAccountState: deleteAccountState ?? this.deleteAccountState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        locale: locale ?? this.locale,
      );
}
