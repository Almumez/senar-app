import '../../../../core/utils/enums.dart';

class TechnicianOrderDetailsState {
  final RequestState getOrderState;
  final RequestState acceptState;
  final RequestState rejectOrder;
  final RequestState checkNowStatus;
  final RequestState completeOrderState;
  final String msg;
  final ErrorType errorType;

  TechnicianOrderDetailsState({
    this.getOrderState = RequestState.initial,
    this.rejectOrder = RequestState.initial,
    this.acceptState = RequestState.initial,
    this.checkNowStatus = RequestState.initial,
    this.completeOrderState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  TechnicianOrderDetailsState copyWith({
    RequestState? getOrderState,
    RequestState? acceptState,
    RequestState? rejectOrder,
    RequestState? checkNowStatus,
    RequestState? completeOrderState,
    String? msg,
    ErrorType? errorType,
  }) =>
      TechnicianOrderDetailsState(
        getOrderState: getOrderState ?? this.getOrderState,
        rejectOrder: rejectOrder ?? this.rejectOrder,
        checkNowStatus: checkNowStatus ?? this.checkNowStatus,
        acceptState: acceptState ?? this.acceptState,
        completeOrderState: completeOrderState ?? this.completeOrderState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
