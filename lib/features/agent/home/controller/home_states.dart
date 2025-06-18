import '../../../../../../../core/utils/enums.dart';

class AgentHomeState {
  final RequestState getOrdersState;
  final RequestState paginationState;
  final RequestState activeState;

  final String msg;
  final ErrorType errorType;

  AgentHomeState({
    this.getOrdersState = RequestState.initial,
    this.paginationState = RequestState.initial,
    this.activeState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  AgentHomeState copyWith({
    RequestState? getOrdersState,
    RequestState? paginationState,
    RequestState? activeState,
    String? msg,
    ErrorType? errorType,
  }) =>
      AgentHomeState(
        getOrdersState: getOrdersState ?? this.getOrdersState,
        activeState: activeState ?? this.activeState,
        paginationState: paginationState ?? this.paginationState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
