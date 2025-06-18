import '../../../../../core/utils/enums.dart';

class FaqState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;

  FaqState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  FaqState copyWith({
    RequestState? requestState,
    String? msg,
    ErrorType? errorType,
  }) =>
      FaqState(
        requestState: requestState ?? this.requestState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
