import '../../../../core/utils/enums.dart';

class GoogleMapSearchState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;

  GoogleMapSearchState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  GoogleMapSearchState copyWith({
    RequestState? requestState,
    String? msg,
    ErrorType? errorType,
  }) =>
      GoogleMapSearchState(
        requestState: requestState ?? this.requestState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
