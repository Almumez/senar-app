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
import '../../../shared/pages/navbar/cubit/navbar_cubit.dart';
import 'states.dart';

class ClientRefillCubit extends Cubit<ClientRefillState> {
  ClientRefillCubit() : super(ClientRefillState());

  String addressId = '';
  int count = 0;
  Future<void> refill() async {
    if (addressId == '') {
      FlashHelper.showToast(LocaleKeys.choose_address_first.tr());
      emit(state.copyWith(requestState: RequestState.error));
    } else {
      emit(state.copyWith(requestState: RequestState.loading));
      final result = await ServerGate.i.sendToServer(url: 'client/order/recharge', body: {
        "count": count,
        "address_id": addressId,
      });
      if (result.success) {
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
        emit(state.copyWith(requestState: RequestState.done));
      } else {
        FlashHelper.showToast(result.msg);
        emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
      }
    }
  }

  void incrementCount() {
    count = count + 1;
    emit(state.copyWith(updateCount: RequestState.done));
  }

  void decrementCount() {
    count = count - 1;
    emit(state.copyWith(updateCount: RequestState.done));
  }
}
