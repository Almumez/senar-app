import '../../../../../../core/utils/enums.dart';
import '../../../../models/order_prices.dart';

class ClientDistributeGasState {
  final RequestState requestState, updateState, calculationsState, createOrderState;
  final String msg;
  final ErrorType errorType;
  bool? serviceChosen;
  OrderPricesModel? orderPrices;

  ClientDistributeGasState({
    this.requestState = RequestState.initial,
    this.updateState = RequestState.initial,
    this.calculationsState = RequestState.initial,
    this.createOrderState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.serviceChosen = false,
    this.orderPrices,
  });

  ClientDistributeGasState copyWith({
    RequestState? requestState,
    RequestState? updateState,
    RequestState? calculationsState,
    RequestState? createOrderState,
    String? msg,
    ErrorType? errorType,
    bool? serviceChosen,
    OrderPricesModel? orderPrices,
  }) =>
      ClientDistributeGasState(
        requestState: requestState ?? this.requestState,
        updateState: updateState ?? this.updateState,
        calculationsState: calculationsState ?? this.calculationsState,
        createOrderState: createOrderState ?? this.createOrderState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        serviceChosen: serviceChosen ?? this.serviceChosen,
        orderPrices: orderPrices ?? this.orderPrices,
      );
}
