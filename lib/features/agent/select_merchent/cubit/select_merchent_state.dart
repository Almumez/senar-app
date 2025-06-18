import '../../../../core/utils/enums.dart';

class SelectMerchentState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;

  SelectMerchentState({this.requestState = RequestState.initial, this.msg = '', this.errorType = ErrorType.none});

  SelectMerchentState copyWith({RequestState? requestState, String? msg, ErrorType? errorType}) => SelectMerchentState(
        requestState: requestState ?? this.requestState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
