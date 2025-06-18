import '../../../../../../core/utils/enums.dart';
import '../../../../../models/orders_count.dart';

class OrderCountsState {
  final RequestState requestState, updateStatus;
  final String msg;
  final ErrorType errorType;
  OrdersCountModel? counts;

  final String type;

  OrderCountsState({
    this.requestState = RequestState.initial,
    this.updateStatus = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.counts,
    this.type = '',
  });

  OrderCountsState copyWith({
    RequestState? requestState,
    RequestState? updateStatus,
    String? msg,
    ErrorType? errorType,
    String? type,
    OrdersCountModel? counts,
  }) =>
      OrderCountsState(
        requestState: requestState ?? this.requestState,
        updateStatus: updateStatus ?? this.updateStatus,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        counts: counts ?? this.counts,
        type: type ?? this.type,
      );
}
