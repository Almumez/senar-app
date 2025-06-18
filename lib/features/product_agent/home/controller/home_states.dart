import '../../../../../../../core/utils/enums.dart';

class ProductAgentHomeState {
  final RequestState getOrdersState;
  final RequestState paginationState;
  final RequestState acttiveState;

  final String msg;
  final ErrorType errorType;

  ProductAgentHomeState({
    this.getOrdersState = RequestState.initial,
    this.paginationState = RequestState.initial,
    this.acttiveState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  ProductAgentHomeState copyWith({
    RequestState? getOrdersState,
    RequestState? paginationState,
    RequestState? activeState,
    String? msg,
    ErrorType? errorType,
  }) =>
      ProductAgentHomeState(
        getOrdersState: getOrdersState ?? this.getOrdersState,
        acttiveState: activeState ?? this.acttiveState,
        paginationState: paginationState ?? this.paginationState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
