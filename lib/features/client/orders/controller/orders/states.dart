import '../../../../../../../core/utils/enums.dart';

class ClientOrdersCState {
  final RequestState getOrdersState;
  final RequestState paginationState;

  final String msg;
  final ErrorType errorType;

  ClientOrdersCState({
    this.getOrdersState = RequestState.initial,
    this.paginationState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  ClientOrdersCState copyWith({
    RequestState? getOrdersState,
    RequestState? paginationState,
    String? msg,
    ErrorType? errorType,
  }) =>
      ClientOrdersCState(
        getOrdersState: getOrdersState ?? this.getOrdersState,
        paginationState: paginationState ?? this.paginationState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
