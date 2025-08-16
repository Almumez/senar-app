import '../../../../core/utils/enums.dart';

class CompleteRegisterPhoneState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;
  final String genderValue;
  final int age;

  CompleteRegisterPhoneState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.genderValue = 'male',
    this.age = 0
  });

  CompleteRegisterPhoneState copyWith({
    RequestState? requestState,
    String? msg,
    ErrorType? errorType,
    String? genderValue,
    int? age
  }) => CompleteRegisterPhoneState(
    requestState: requestState ?? this.requestState,
    msg: msg ?? this.msg,
    errorType: errorType ?? this.errorType,
    genderValue: genderValue ?? this.genderValue,
    age: age ?? this.age,
  );
} 