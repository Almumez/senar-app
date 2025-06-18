import '../../../../core/utils/enums.dart';

class CompleteDataState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;

  CompleteDataState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  CompleteDataState copyWith({
    RequestState? requestState,
    String? msg,
    ErrorType? errorType,
  }) =>
      CompleteDataState(
        requestState: requestState ?? this.requestState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
