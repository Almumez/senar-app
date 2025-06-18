import '../../../../core/utils/enums.dart';

class CancelReasonsState {
  final RequestState reasonsState;
  final String msg;
  final ErrorType errorType;
  final bool openSheet;

  CancelReasonsState({
    this.reasonsState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.openSheet = false,
  });

  CancelReasonsState copyWith({
    RequestState? reasonsState,
    String? msg,
    ErrorType? errorType,
    bool? openSheet,
  }) =>
      CancelReasonsState(
        reasonsState: reasonsState ?? this.reasonsState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        openSheet: openSheet ?? this.openSheet,
      );
}
