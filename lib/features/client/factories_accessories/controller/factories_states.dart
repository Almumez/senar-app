import '../../../../../../core/utils/enums.dart';

class ClientFactoriesAccessoriesState {
  final RequestState getListState;
  final RequestState paginationState;

  final String msg;
  final ErrorType errorType;

  ClientFactoriesAccessoriesState({
    this.getListState = RequestState.initial,
    this.paginationState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  ClientFactoriesAccessoriesState copyWith({
    RequestState? getListState,
    RequestState? paginationState,
    String? msg,
    ErrorType? errorType,
  }) =>
      ClientFactoriesAccessoriesState(
        getListState: getListState ?? this.getListState,
        paginationState: paginationState ?? this.paginationState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
