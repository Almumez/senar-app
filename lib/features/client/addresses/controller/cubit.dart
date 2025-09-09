import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../models/address.dart';
import 'state.dart';

class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit() : super(AddressesState());

  final placeTitle = TextEditingController();
  final placeDesc = TextEditingController();

  List<AddressModel> addresses = [];
  AddressModel? defaultAddress;

  String defaultAddressId = '';
  bool isLocationAvailable = false;

  Future<void> getAddresses({bool withLoading = true}) async {
    if (withLoading) emit(state.copyWith(getStateState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: 'general/address');
    if (result.success) {
      addresses = List<AddressModel>.from(result.data['data'].map((x) => AddressModel.fromJson(x)));
      getDefaultAddressId(addresses);
      emit(state.copyWith(getStateState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(getStateState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> checkZoneLocation(LatLng latLng) async {
    emit(state.copyWith(checkZoneState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'general/zones/check-location',
      body: {
        "lat": latLng.latitude,
        "lng": latLng.longitude,
      },
    );
    if (result.success) {
      isLocationAvailable = result.data['data']['is_valid_location'] == 1;
      emit(state.copyWith(checkZoneState: RequestState.done, msg: result.msg));
    } else {
      isLocationAvailable = false;
      emit(state.copyWith(checkZoneState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> addAddress(LatLng latLng) async {
    emit(state.copyWith(addStateState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'general/address',
      body: {
        "place_title": placeTitle.text,
        "place_description": placeDesc.text,
        "lng": latLng.longitude,
        "lat": latLng.latitude,
      },
    );
    if (result.success) {
      // reset();
      addresses.add(AddressModel.fromJson(result.data['data']));
      getDefaultAddressId(addresses);
      emit(state.copyWith(addStateState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(addStateState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> editAddress({required AddressModel data}) async {
    emit(state.copyWith(editStateState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(
      url: 'general/address/${data.id}/update',
      body: {
        "place_title": placeTitle.text,
        "place_description": placeDesc.text,
        "lng": data.lat,
        "lat": data.lng,
      },
    );
    if (result.success) {
      updataAddress(AddressModel.fromJson(result.data['data']));
      getDefaultAddressId(addresses);
      emit(state.copyWith(editStateState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(editStateState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> deleteAddress({required String id}) async {
    emit(state.copyWith(deleteStateState: RequestState.loading));
    final result = await ServerGate.i.deleteFromServer(url: 'general/address/$id');
    if (result.success) {
      Navigator.pop(navigator.currentContext!);
      addresses.removeWhere((element) => element.id == id);
      getDefaultAddressId(addresses);
      emit(state.copyWith(deleteStateState: RequestState.done, msg: result.msg));
    } else {
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(deleteStateState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  updataAddress(AddressModel newAddress) {
    addresses[addresses.indexWhere((element) => element.id == newAddress.id)] = newAddress;
  }

  Future<void> setDefaultAddress({required String id}) async {
    emit(state.copyWith(setDefaultStateState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/address/$id/set-default');
    if (result.success) {
      getAddresses(withLoading: false);
      emit(state.copyWith(setDefaultStateState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(setDefaultStateState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  void getDefaultAddressId(List<AddressModel> addresses) {
    AddressModel? defaultAddressModel = addresses.firstWhere(
      (element) => element.isDefault,
      orElse: () => addresses.isNotEmpty ? addresses.first : AddressModel.fromJson(),
    );

    defaultAddressId = defaultAddressModel.id;
    defaultAddress = defaultAddressModel;
  }
}
