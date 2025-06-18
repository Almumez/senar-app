import '../../../../core/utils/enums.dart';

class FreeAgentCarInfoState {
  final RequestState getState, editState;
  final String msg;
  final ErrorType errorType;

  FreeAgentCarInfoState({
    this.getState = RequestState.initial,
    this.editState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  FreeAgentCarInfoState copyWith({
    RequestState? getState,
    RequestState? editState,
    String? msg,
    ErrorType? errorType,
  }) =>
      FreeAgentCarInfoState(
        getState: getState ?? this.getState,
        editState: editState ?? this.editState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
