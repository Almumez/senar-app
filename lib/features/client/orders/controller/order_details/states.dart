import '../../../../../../../core/utils/enums.dart';

class ClientOrderDetailsState {
  final RequestState detailsState;
  final RequestState payState;
  final RequestState cancelState;
  final RequestState rateState;

  final String msg;
  final ErrorType errorType;

  ClientOrderDetailsState({
    this.detailsState = RequestState.initial,
    this.payState = RequestState.initial,
    this.cancelState = RequestState.initial,
    this.rateState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  ClientOrderDetailsState copyWith({
    RequestState? detailsState,
    RequestState? payState,
    RequestState? cancelState,
    RequestState? rateState,
    String? msg,
    ErrorType? errorType,
  }) =>
      ClientOrderDetailsState(
        detailsState: detailsState ?? this.detailsState,
        payState: payState ?? this.payState,
        cancelState: cancelState ?? this.cancelState,
        rateState: rateState ?? this.rateState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
