import '../../../../../core/utils/enums.dart';
import '../../../../../models/static.dart';

class StaticState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;

  StaticModel? data;

  StaticState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.data,
  });

  StaticState copyWith({
    RequestState? requestState,
    String? msg,
    ErrorType? errorType,
    StaticModel? data,
  }) =>
      StaticState(
        requestState: requestState ?? this.requestState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        data: data ?? this.data,
      );
}
