import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/services/server_gate.dart';
import '../../../../../../core/utils/enums.dart';
import '../../../../models/buy_cylinder.dart';
import '../../../../models/order_prices.dart';
import '../../../../core/services/service_locator.dart';
import '../../addresses/controller/cubit.dart';
import 'states.dart';

class ClientDistributeGasCubit extends Cubit<ClientDistributeGasState> {
  ClientDistributeGasCubit() : super(ClientDistributeGasState());

  List<BuyCylinderServiceModel> services = [];
  List<BuyCylinderSubServiceModel> selectedSubServices = [];
  List<BuyCylinderSubServiceModel> selectedAdditionalServices = [];

  String addressId = '';
  String paymentMethod = '';
  String paymentId = ''; // معرف معاملة الدفع

  // Initialize by checking for default address
  Future<void> init() async {
    await fetchServices();
    await loadDefaultAddress();
  }

  // Load default address if available
  Future<void> loadDefaultAddress() async {
    if (addressId.isEmpty) {
      final addressesCubit = sl<AddressesCubit>();
      
      // If addresses haven't been loaded yet, load them
      if (addressesCubit.addresses.isEmpty) {
        await addressesCubit.getAddresses();
      }
      
      // Check if we have any addresses
      if (addressesCubit.addresses.isNotEmpty) {
        // Use default address or first address
        addressId = addressesCubit.defaultAddressId.isNotEmpty 
            ? addressesCubit.defaultAddressId 
            : addressesCubit.addresses.first.id;
      }
    }
  }

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
    // Reset selected services
    selectedAdditionalServices.clear();
    selectedSubServices.clear();
    
    // Build services object for request
    final servicesMap = <String, dynamic>{};
    for (final service in services) {
      for (final subService in service.sub) {
        if (subService.count > 0) {
          servicesMap[subService.type] = subService.count;
          if (service.key == 'additional') {
            selectedAdditionalServices.add(subService);
          } else {
            selectedSubServices.add(subService);
          }
        }
      }
    }

    // Get address ID - if not set, try to get default address
    String currentAddressId = addressId;
    if (currentAddressId.isEmpty) {
      await loadDefaultAddress();
      currentAddressId = addressId;
    }

    // Check if we have a valid address ID
    if (currentAddressId.isEmpty) {
      emit(state.copyWith(calculationsState: RequestState.error, msg: 'يرجى إضافة عنوان أولاً'));
      return;
    }

    // Create the request body
    final body = {
      'address_id': int.tryParse(currentAddressId) ?? 0,
      'services': servicesMap,
    };

    emit(state.copyWith(calculationsState: RequestState.loading));
    final response = await ServerGate.i.sendToServer(
      url: 'client/order/distribution-calculations',
      body: body,
    );

    if (response.success) {
      final orderPrices = OrderPricesModel.fromJson(response.data['data']);
      emit(state.copyWith(calculationsState: RequestState.done, orderPrices: orderPrices));
    } else {
      emit(state.copyWith(calculationsState: RequestState.error, msg: response.msg, errorType: response.errType));
    }
  }

  // Método para establecer si estamos solicitando una orden nueva
  void setRequestingOrder(bool value) {
    emit(state.copyWith(isRequestingOrder: value));
  }

  Future<void> completeOrder() async {
    final servicesMap = <String, dynamic>{};
    for (final service in services) {
      for (final subService in service.sub) {
        if (subService.count > 0) {
          servicesMap[subService.type] = subService.count;
        }
      }
    }

    // التأكد من وجود بيانات الأسعار
    if (state.orderPrices == null) {
      emit(state.copyWith(createOrderState: RequestState.error, msg: "لم يتم حساب السعر بشكل صحيح"));
      return;
    }

    final body = <String, dynamic>{
      'address_id': int.tryParse(addressId) ?? 0,
      'payment_method': paymentMethod,
      'services': servicesMap,
      'station_id': state.orderPrices?.stationId ?? 0,
      // إضافة الحقول الجديدة من الحسابات
      'services_total': state.orderPrices?.servicesTotal ?? 0,
      'additional_total': state.orderPrices?.additionalTotal ?? 0,
      'delivery_fee': state.orderPrices?.deliveryPrice ?? 0,
      'tax': state.orderPrices?.tax ?? 0,
      'total': state.orderPrices?.total ?? 0,
    };

    // إذا كانت طريقة الدفع ليست نقداً، أضف المبلغ المدفوع
    if (paymentMethod != 'cash') {
      body['paid_amount'] = state.orderPrices?.total ?? 0;
      
      // إضافة معرف المعاملة كمعامل منفصل
      if (paymentId.isNotEmpty) {
        body['transaction_code'] = paymentId;
        
        // إرسال استجابة البوابة كاملة
        body['gateway_response'] = {
          'transaction_id': paymentId,
          'payment_method': paymentMethod,
          'amount': state.orderPrices?.total ?? 0,
          'currency': 'SAR',
          'status': 'success'
        };
      }
    }

    emit(state.copyWith(createOrderState: RequestState.loading, calculationsState: RequestState.initial));
    final response = await ServerGate.i.sendToServer(url: 'client/order/distribution', body: body);

    if (response.success) {
      emit(state.copyWith(createOrderState: RequestState.done));
    } else {
      emit(state.copyWith(createOrderState: RequestState.error, msg: response.msg, errorType: response.errType));
    }
  }

  void _resetOrderDetails() {
    // Don't reset addressId here anymore since we need it for calculations
    paymentMethod = '';
    selectedAdditionalServices.clear();
    selectedSubServices.clear();
  }
}
