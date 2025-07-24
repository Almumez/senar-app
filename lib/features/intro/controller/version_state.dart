import '../../../core/utils/enums.dart';

class VersionState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;
  final bool updateAvailable;

  VersionState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.updateAvailable = false,
  });

  VersionState copyWith({
    RequestState? requestState,
    String? msg,
    ErrorType? errorType,
    bool? updateAvailable,
  }) =>
      VersionState(
        requestState: requestState ?? this.requestState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        updateAvailable: updateAvailable ?? this.updateAvailable,
      );
} 