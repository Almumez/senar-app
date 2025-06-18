import '../../../../../../core/utils/enums.dart';

class ClientRefillState {
  final RequestState requestState;
  final RequestState updateCount;
  final String msg;
  final ErrorType errorType;

  ClientRefillState({
    this.requestState = RequestState.initial,
    this.updateCount = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  ClientRefillState copyWith({
    RequestState? requestState,
    RequestState? updateCount,
    String? msg,
    ErrorType? errorType,
  }) =>
      ClientRefillState(
        requestState: requestState ?? this.requestState,
        updateCount: updateCount ?? this.updateCount,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
