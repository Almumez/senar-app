import '../../../../../../core/utils/enums.dart';

class WalletState {
  final RequestState getWaletState;
  final RequestState getTransactionsState;
  final RequestState getTransactionsPagingState;
  final RequestState withdrowState;
  final RequestState requestWithdrawalState;
  final RequestState getWithdrawalRequestsState;
  final String msg;
  final ErrorType? errorType;

  WalletState({
    this.getWaletState = RequestState.initial,
    this.getTransactionsState = RequestState.initial,
    this.getTransactionsPagingState = RequestState.initial,
    this.withdrowState = RequestState.initial,
    this.requestWithdrawalState = RequestState.initial,
    this.getWithdrawalRequestsState = RequestState.initial,
    this.msg = '',
    this.errorType,
  });

  WalletState copyWith({
    RequestState? getWaletState,
    RequestState? getTransactionsState,
    RequestState? getTransactionsPagingState,
    RequestState? withdrowState,
    RequestState? requestWithdrawalState,
    RequestState? getWithdrawalRequestsState,
    String? msg,
    ErrorType? errorType,
  }) {
    return WalletState(
      getWaletState: getWaletState ?? this.getWaletState,
      getTransactionsState: getTransactionsState ?? this.getTransactionsState,
      getTransactionsPagingState: getTransactionsPagingState ?? this.getTransactionsPagingState,
      withdrowState: withdrowState ?? this.withdrowState,
      requestWithdrawalState: requestWithdrawalState ?? this.requestWithdrawalState,
      getWithdrawalRequestsState: getWithdrawalRequestsState ?? this.getWithdrawalRequestsState,
      msg: msg ?? this.msg,
      errorType: errorType ?? this.errorType,
    );
  }
}
