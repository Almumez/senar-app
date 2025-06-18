import '../../../../core/utils/enums.dart';

class AgentOrdersState {
  final RequestState getOrdersState;
  final RequestState getOrdersPagingState;
  final String msg;
  final ErrorType errorType;

  AgentOrdersState({
    this.getOrdersState = RequestState.initial,
    this.getOrdersPagingState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  AgentOrdersState copyWith({
    RequestState? getOrdersState,
    RequestState? getOrdersPagingState,
    String? msg,
    ErrorType? errorType,
  }) =>
      AgentOrdersState(
        getOrdersState: getOrdersState ?? this.getOrdersState,
        getOrdersPagingState: getOrdersPagingState ?? this.getOrdersPagingState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
