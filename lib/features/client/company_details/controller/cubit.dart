import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/services/server_gate.dart';
import '../../../../../../core/utils/enums.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/successfully_sheet.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/company.dart';
import '../../../shared/pages/navbar/cubit/navbar_cubit.dart';
import 'states.dart';

class CompanyDetailsCubit extends Cubit<CompanyDetailsState> {
  CompanyDetailsCubit() : super(CompanyDetailsState());

  String addressId = '';

  CompanyModel? data;
  CompanyServiceType? type;

  Future<void> getDetails({required String id}) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(
      url: type == CompanyServiceType.supply ? "client/services/supply/$id" : "client/services/maintenance/$id",
    );
    if (result.success) {
      data = CompanyModel.fromJson(result.data['data']);
      emit(state.copyWith(requestState: RequestState.done));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  selectService(String id) {
    data?.services.firstWhere((service) => service.id == id).isSelected = !data!.services.firstWhere((service) => service.id == id).isSelected;
    emit(state.copyWith(requestState: RequestState.done));
  }

  servicesSelected() {
    return data?.services.any((service) => service.isSelected == true);
  }

  chooseAddress(String id) {
    addressId = id;
    emit(state.copyWith(requestState: RequestState.done));
  }

  addressSelected() {
    return addressId.isNotEmpty;
  }

  Future<void> completeOrder() async {
    final body = <String, dynamic>{
      'address_id': addressId,
      'merchant_id': data?.id,
      'sub_services': data?.services.where((service) => service.isSelected == true).map((service) => service.id).toList(),
    };

    emit(state.copyWith(completeOrderState: RequestState.loading));
    final response = await ServerGate.i.sendToServer(
      url: type == CompanyServiceType.maintenance ? 'client/order/maintenance' : 'client/order/supply',
      body: body,
    );

    if (response.success) {
      showModalBottomSheet(
        elevation: 0,
        context: navigator.currentContext!,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context) => SuccessfullySheet(
          title: LocaleKeys.order_created_successfully.tr(),
          onLottieFinish: () {
            sl<NavbarCubit>().changeTap(1);
            Navigator.popUntil(context, (s) => s.isFirst);
          },
        ),
      );
      emit(state.copyWith(completeOrderState: RequestState.done));
    } else {
      FlashHelper.showToast(response.msg);
      emit(state.copyWith(completeOrderState: RequestState.error, msg: response.msg, errorType: response.errType));
    }
  }
}
