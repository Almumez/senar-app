import '../../../../../../core/utils/enums.dart';

class ClientHomeState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;

  ClientHomeState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  ClientHomeState copyWith({
    RequestState? requestState,
    String? msg,
    ErrorType? errorType,
  }) =>
      ClientHomeState(
        requestState: requestState ?? this.requestState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
