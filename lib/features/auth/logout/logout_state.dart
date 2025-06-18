import '../../../../core/utils/enums.dart';

class LogoutState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;

  LogoutState({this.requestState = RequestState.initial, this.msg = '', this.errorType = ErrorType.none});

  LogoutState copyWith({RequestState? requestState, String? msg, ErrorType? errorType}) => LogoutState(
        requestState: requestState ?? this.requestState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
