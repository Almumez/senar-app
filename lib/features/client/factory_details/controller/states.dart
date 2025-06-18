import '../../../../../../core/utils/enums.dart';

class FactoryDetailsState {
  final RequestState requestState;
  final RequestState completeOrderState;
  final String msg;
  final ErrorType errorType;

  FactoryDetailsState({
    this.requestState = RequestState.initial,
    this.completeOrderState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  FactoryDetailsState copyWith({
    RequestState? requestState,
    RequestState? completeOrderState,
    String? msg,
    ErrorType? errorType,
  }) =>
      FactoryDetailsState(
        requestState: requestState ?? this.requestState,
        completeOrderState: completeOrderState ?? this.completeOrderState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
