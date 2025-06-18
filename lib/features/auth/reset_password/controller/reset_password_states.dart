import '../../../../core/utils/enums.dart';

class ResetPasswordState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;

  ResetPasswordState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  ResetPasswordState copyWith({
    RequestState? requestState,
    String? msg,
    ErrorType? errorType,
  }) =>
      ResetPasswordState(
        requestState: requestState ?? this.requestState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
