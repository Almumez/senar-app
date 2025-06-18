import '../../../../../core/utils/enums.dart';

class EditProfileState {
  final RequestState requestState, passwordState, phoneState, verifyState;
  final String msg;
  final ErrorType errorType;

  EditProfileState({
    this.requestState = RequestState.initial,
    this.passwordState = RequestState.initial,
    this.phoneState = RequestState.initial,
    this.verifyState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  EditProfileState copyWith({
    RequestState? requestState,
    RequestState? passwordState,
    RequestState? phoneState,
    RequestState? verifyState,
    String? msg,
    ErrorType? errorType,
  }) =>
      EditProfileState(
        requestState: requestState ?? this.requestState,
        passwordState: passwordState ?? this.passwordState,
        phoneState: phoneState ?? this.phoneState,
        verifyState: verifyState ?? this.verifyState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
