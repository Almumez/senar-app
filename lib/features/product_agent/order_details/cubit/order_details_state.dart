import '../../../../core/utils/enums.dart';

class ProductAgentOrderDetailsState {
  final RequestState getOrderState;
  final RequestState acceptState;
  final RequestState rejectOrder;
  final RequestState changeStatus;
  final String msg;
  final ErrorType errorType;

  ProductAgentOrderDetailsState({
    this.getOrderState = RequestState.initial,
    this.rejectOrder = RequestState.initial,
    this.acceptState = RequestState.initial,
    this.changeStatus = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  ProductAgentOrderDetailsState copyWith({
    RequestState? getOrderState,
    RequestState? acceptState,
    RequestState? rejectOrder,
    RequestState? changeStatus,
    String? msg,
    ErrorType? errorType,
  }) =>
      ProductAgentOrderDetailsState(
        getOrderState: getOrderState ?? this.getOrderState,
        rejectOrder: rejectOrder ?? this.rejectOrder,
        changeStatus: changeStatus ?? this.changeStatus,
        acceptState: acceptState ?? this.acceptState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
