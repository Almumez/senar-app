import '../../../../core/utils/enums.dart';

class ProductAgentOrdersState {
  final RequestState getOrdersState;
  final RequestState getOrdersPagingState;
  final String msg;
  final ErrorType errorType;

  ProductAgentOrdersState({
    this.getOrdersState = RequestState.initial,
    this.getOrdersPagingState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  ProductAgentOrdersState copyWith({
    RequestState? getOrdersState,
    RequestState? getOrdersPagingState,
    String? msg,
    ErrorType? errorType,
  }) =>
      ProductAgentOrdersState(
        getOrdersState: getOrdersState ?? this.getOrdersState,
        getOrdersPagingState: getOrdersPagingState ?? this.getOrdersPagingState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
