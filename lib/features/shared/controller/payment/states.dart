import '../../../../core/utils/enums.dart';
import 'model.dart';

class PaymentInfoState {
  final RequestState state;
  final String msg;
  final ErrorType errorType;

  final PaymentInfoModel? data;

  PaymentInfoState({
    this.state = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.data,
  });

  PaymentInfoState copyWith({
    RequestState? state,
    String? msg,
    ErrorType? errorType,
    PaymentInfoModel? data,
  }) =>
      PaymentInfoState(
        state: state ?? this.state,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        data: data ?? this.data,
      );
}