import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../gen/locale_keys.g.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../models/attachment.dart';
import 'state.dart';

class FreeAgentCarInfoCubit extends Cubit<FreeAgentCarInfoState> {
  FreeAgentCarInfoCubit() : super(FreeAgentCarInfoState());

  AttachmentModel license = AttachmentModel();
  AttachmentModel vehicleForm = AttachmentModel();
  AttachmentModel healthCertificate = AttachmentModel();

  Map<String, dynamic> get body => {
        'license': license.key,
        'vehicle_form': vehicleForm.key,
        'health_certificate': healthCertificate.key,
      };

  //https://gas.azmy.aait-d.com/storage/

  Future<void> editCarInfo() async {
    emit(state.copyWith(editState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/profile/car-info', body: body);
    if (result.success) {
      emit(state.copyWith(editState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(editState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> getCarInfo() async {
    emit(state.copyWith(getState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(url: 'general/profile/car-info');
    if (result.success) {
      license = AttachmentModel.fromUrl(result.data?['data']?['license']);
      vehicleForm = AttachmentModel.fromUrl(result.data?['data']?['vehicle_form']);
      healthCertificate = AttachmentModel.fromUrl(result.data?['data']?['health_certificate']);

      emit(state.copyWith(getState: RequestState.done));
    } else {
      emit(state.copyWith(getState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  bool get validateSave {
    if ([license.url, vehicleForm.url, healthCertificate.url].contains(null)) {
      FlashHelper.showToast(LocaleKeys.please_upload_all_images.tr());
      return false;
    } else if ([license.loading, vehicleForm.loading, healthCertificate.loading].contains(true)) {
      FlashHelper.showToast(LocaleKeys.uploading_images.tr());
      return false;
    } else if ([license.key, vehicleForm.key, healthCertificate.key].contains(null)) {
      FlashHelper.showToast(LocaleKeys.there_are_images_not_uploaded.tr());
      return false;
    } else {
      return true;
    }
  }
}
