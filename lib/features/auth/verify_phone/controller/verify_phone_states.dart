import '../../../../core/utils/enums.dart';

class VerifyPhoneState {
  RequestState verifyState, resendState, editEmailState;
  String msg;
  ErrorType errorType;
  String newPhone, newCode;

  VerifyPhoneState({
    this.verifyState = RequestState.initial,
    this.resendState = RequestState.initial,
    this.editEmailState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.newPhone = '',
    this.newCode = '',
  });

  VerifyPhoneState copyWith({
    RequestState? verifyState,
    RequestState? editEmailState,
    RequestState? resendState,
    String? msg,
    ErrorType? errorType,
    String? newPhone,
    String? newCode,
  }) =>
      VerifyPhoneState(
        verifyState: verifyState ?? this.verifyState,
        editEmailState: editEmailState ?? this.editEmailState,
        resendState: resendState ?? this.resendState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        newPhone: newPhone ?? this.newPhone,
        newCode: newCode ?? this.newCode,
      );
}
