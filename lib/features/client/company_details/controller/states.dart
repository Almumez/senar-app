import '../../../../../../core/utils/enums.dart';

class CompanyDetailsState {
  final RequestState requestState;
  final RequestState completeOrderState;
  final String msg;
  final ErrorType errorType;

  CompanyDetailsState({
    this.requestState = RequestState.initial,
    this.completeOrderState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  CompanyDetailsState copyWith({
    RequestState? requestState,
    RequestState? completeOrderState,
    String? msg,
    ErrorType? errorType,
  }) =>
      CompanyDetailsState(
        requestState: requestState ?? this.requestState,
        completeOrderState: completeOrderState ?? this.completeOrderState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
