import '../../../../../../core/utils/enums.dart';

class WalletState {
  final RequestState getWaletState;
  final RequestState getTransactionsState;
  final RequestState getTransactionsPagingState;
  final RequestState withdrowState;
  final String msg;
  final ErrorType errorType;

  WalletState({
    this.getWaletState = RequestState.initial,
    this.withdrowState = RequestState.initial,
    this.getTransactionsPagingState = RequestState.initial,
    this.getTransactionsState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  WalletState copyWith({
    RequestState? getWaletState,
    RequestState? getTransactionsPagingState,
    RequestState? withdrowState,
    RequestState? getTransactionsState,
    String? msg,
    ErrorType? errorType,
  }) =>
      WalletState(
        withdrowState: withdrowState ?? this.withdrowState,
        getWaletState: getWaletState ?? this.getWaletState,
        getTransactionsState: getTransactionsState ?? this.getTransactionsState,
        getTransactionsPagingState: getTransactionsPagingState ?? this.getTransactionsPagingState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
