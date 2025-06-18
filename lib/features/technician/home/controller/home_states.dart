import '../../../../../../../core/utils/enums.dart';

class TechnicianHomeState {
  final RequestState getOrdersState;
  final RequestState paginationState;
  final RequestState acttiveState;

  final String msg;
  final ErrorType errorType;

  TechnicianHomeState({
    this.getOrdersState = RequestState.initial,
    this.paginationState = RequestState.initial,
    this.acttiveState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  TechnicianHomeState copyWith({
    RequestState? getOrdersState,
    RequestState? paginationState,
    RequestState? acttiveState,
    String? msg,
    ErrorType? errorType,
  }) =>
      TechnicianHomeState(
        getOrdersState: getOrdersState ?? this.getOrdersState,
        acttiveState: acttiveState ?? this.acttiveState,
        paginationState: paginationState ?? this.paginationState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
