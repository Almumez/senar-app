import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/attachment.dart';
import 'complete_data_states.dart';

class CompleteDataCubit extends Cubit<CompleteDataState> {
  CompleteDataCubit() : super(CompleteDataState());

  String phone = '', phoneCode = '';

  AttachmentModel license = AttachmentModel();
  AttachmentModel vehicleForm = AttachmentModel();
  // AttachmentModel healthCertificate = AttachmentModel();

  final civilStatusNumber = TextEditingController();

  Map<String, dynamic> get body => {
        'phone_code': phoneCode,
        'phone': phone,
        'civil_status_number': civilStatusNumber.text,
        'license': license.key,
        'vehicle_form': vehicleForm.key,
        // 'health_certificate': healthCertificate.key,
      };

  Future<void> completeData() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/complete-register', body: body);
    if (result.success) {
      emit(state.copyWith(requestState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  bool get validateSave {
    if ([license.url, vehicleForm.url].contains(null)) {
      FlashHelper.showToast(LocaleKeys.please_upload_all_images.tr());
      return false;
    } else if ([license.loading, vehicleForm.loading].contains(true)) {
      FlashHelper.showToast(LocaleKeys.uploading_images.tr());
      return false;
    } else if ([license.key, vehicleForm.key].contains(null)) {
      FlashHelper.showToast(LocaleKeys.there_are_images_not_uploaded.tr());
      return false;
    } else {
      return true;
    }
  }
}
