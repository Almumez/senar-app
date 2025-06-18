import '../../../../../../core/utils/enums.dart';

class ProfitsState {
  final RequestState requestState, updateStatus;
  final String msg;
  final ErrorType errorType;
  final String type;

  ProfitsState({
    this.requestState = RequestState.initial,
    this.updateStatus = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.type = '',
  });

  ProfitsState copyWith({
    RequestState? requestState,
    RequestState? updateStatus,
    String? msg,
    ErrorType? errorType,
    String? type,
  }) =>
      ProfitsState(
        requestState: requestState ?? this.requestState,
        updateStatus: updateStatus ?? this.updateStatus,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        type: type ?? this.type,
      );
}
