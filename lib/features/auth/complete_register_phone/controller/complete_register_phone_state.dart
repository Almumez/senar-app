import '../../../../core/utils/enums.dart';

class CompleteRegisterPhoneState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;

  CompleteRegisterPhoneState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none
  });

  CompleteRegisterPhoneState copyWith({
    RequestState? requestState,
    String? msg,
    ErrorType? errorType
  }) => CompleteRegisterPhoneState(
    requestState: requestState ?? this.requestState,
    msg: msg ?? this.msg,
    errorType: errorType ?? this.errorType,
  );
} 