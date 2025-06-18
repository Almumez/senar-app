import '../../../../core/utils/enums.dart';

class TechnicianOrdersState {
  final RequestState getOrdersState;
  final RequestState getOrdersPagingState;
  final String msg;
  final ErrorType errorType;

  TechnicianOrdersState({
    this.getOrdersState = RequestState.initial,
    this.getOrdersPagingState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  TechnicianOrdersState copyWith({
    RequestState? getOrdersState,
    RequestState? getOrdersPagingState,
    String? msg,
    ErrorType? errorType,
  }) =>
      TechnicianOrdersState(
        getOrdersState: getOrdersState ?? this.getOrdersState,
        getOrdersPagingState: getOrdersPagingState ?? this.getOrdersPagingState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
