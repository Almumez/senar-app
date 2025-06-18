import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/services/server_gate.dart';
import '../../../../../../core/utils/enums.dart';
import '../../../../models/buy_cylinder.dart';
import '../../../../models/order_prices.dart';
import 'states.dart';

class ClientDistributeGasCubit extends Cubit<ClientDistributeGasState> {
  ClientDistributeGasCubit() : super(ClientDistributeGasState());

  List<BuyCylinderServiceModel> services = [];
  List<BuyCylinderSubServiceModel> selectedSubServices = [];
  List<BuyCylinderSubServiceModel> selectedAdditionalServices = [];

  String addressId = '';
  String paymentMethod = '';

  Future<void> fetchServices() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final response = await ServerGate.i.getFromServer(url: 'client/services/distributions');

    if (response.success) {
      services = (response.data['data'] as List<dynamic>).map((json) => BuyCylinderServiceModel.fromJson(json)).toList();

      emit(state.copyWith(requestState: RequestState.done, serviceChosen: hasChosenServices()));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: response.msg, errorType: response.errType));
    }
  }

  void incrementService({required String key, required BuyCylinderSubServiceModel model}) {
    _updateServiceCount(key, model, increment: true);
  }

  void decrementService({required String key, required BuyCylinderSubServiceModel model}) {
    _updateServiceCount(key, model, increment: false);
  }

  void _updateServiceCount(String key, BuyCylinderSubServiceModel model, {required bool increment}) {
    emit(state.copyWith(updateState: RequestState.loading));

    final service = services.firstWhere((service) => service.key == key);
    final subService = service.sub.firstWhere((sub) => sub.type == model.type);

    subService.count += increment ? 1 : -1;
    subService.count = subService.count.clamp(0, subService.count); // Prevent negative counts

    emit(state.copyWith(updateState: RequestState.done, serviceChosen: hasChosenServices()));
  }

  bool hasChosenServices() {
    return services.any((service) => service.sub.any((sub) => sub.count > 0));
  }

  Future<void> calculateOrder() async {
    _resetOrderDetails();
    final params = <String, dynamic>{};
    for (final service in services) {
      for (final subService in service.sub) {
        if (subService.count > 0) {
          params[subService.type] = subService.count;
          if (service.key == 'additional') {
            selectedAdditionalServices.add(subService);
          } else {
            selectedSubServices.add(subService);
          }
        }
      }
    }

    emit(state.copyWith(calculationsState: RequestState.loading));
    final response = await ServerGate.i.getFromServer(
      url: 'client/order/distribution-calculations',
      params: params,
    );

    if (response.success) {
      final orderPrices = OrderPricesModel.fromJson(response.data['data']);
      emit(state.copyWith(calculationsState: RequestState.done, orderPrices: orderPrices));
    } else {
      emit(state.copyWith(calculationsState: RequestState.error, msg: response.msg, errorType: response.errType));
    }
  }

  Future<void> completeOrder() async {
    final body = <String, dynamic>{
      'address_id': addressId,
      'payment_method': paymentMethod,
      ..._buildOrderParams(),
    };

    emit(state.copyWith(createOrderState: RequestState.loading, calculationsState: RequestState.initial));
    final response = await ServerGate.i.sendToServer(url: 'client/order/distribution', body: body);

    if (response.success) {
      emit(state.copyWith(createOrderState: RequestState.done));
    } else {
      emit(state.copyWith(createOrderState: RequestState.error, msg: response.msg, errorType: response.errType));
    }
  }

  Map<String, dynamic> _buildOrderParams() {
    final params = <String, dynamic>{};
    for (final service in services) {
      for (final subService in service.sub) {
        if (subService.count > 0) {
          params[subService.type] = subService.count;
        }
      }
    }
    return params;
  }

  void _resetOrderDetails() {
    addressId = '';
    paymentMethod = '';
    selectedAdditionalServices.clear();
    selectedSubServices.clear();
  }
}
