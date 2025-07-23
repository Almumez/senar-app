import '../../../../core/utils/enums.dart';

class CompleteRegisterPhoneState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;
  final String genderValue;

  CompleteRegisterPhoneState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.genderValue = 'male'
  });

  CompleteRegisterPhoneState copyWith({
    RequestState? requestState,
    String? msg,
    ErrorType? errorType,
    String? genderValue
  }) => CompleteRegisterPhoneState(
    requestState: requestState ?? this.requestState,
    msg: msg ?? this.msg,
    errorType: errorType ?? this.errorType,
    genderValue: genderValue ?? this.genderValue,
  );
} 