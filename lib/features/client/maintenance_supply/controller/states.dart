import '../../../../../../core/utils/enums.dart';

class ClientMaintenanceSupplyState {
  final RequestState getCompaniesState;
  final RequestState paginationState;


  final String msg;
  final ErrorType errorType;

  ClientMaintenanceSupplyState({
    this.getCompaniesState = RequestState.initial,
    this.paginationState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  ClientMaintenanceSupplyState copyWith({
    RequestState? getCompaniesState,
    RequestState? paginationState,
    String? msg,
    ErrorType? errorType,
  }) =>
      ClientMaintenanceSupplyState(
        getCompaniesState: getCompaniesState ?? this.getCompaniesState,
        paginationState: paginationState ?? this.paginationState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
