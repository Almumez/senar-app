import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
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
  AttachmentModel identity = AttachmentModel(); // إضافة حقل الهوية

  Map<String, dynamic> get body => {
        'license': license.key,
        'vehicle_form': vehicleForm.key,
        'identity': identity.key,
        '_method': 'PUT',
      };

  Map<String, dynamic> get formData {
    Map<String, dynamic> data = {};
    
    // إضافة الملفات الجديدة فقط إذا كانت موجودة
    if (license.file != null) {
      data['license'] = MultipartFile.fromFileSync(license.file!.path);
    }
    
    if (vehicleForm.file != null) {
      data['vehicle_form'] = MultipartFile.fromFileSync(vehicleForm.file!.path);
    }
    
    if (identity.file != null) {
      data['identity'] = MultipartFile.fromFileSync(identity.file!.path);
    }
    
    return data;
  }

  bool get hasNewFiles => license.file != null || vehicleForm.file != null || identity.file != null;

  //https://gas.azmy.aait-d.com/storage/

  Future<void> editCarInfo() async {
    emit(state.copyWith(editState: RequestState.loading));
    
    // تغيير المسار إلى المسار الجديد وإرسال كـ formData فقط
    final result = await ServerGate.i.sendToServer(
      url: 'general/complete-register-free-agent', 
      formData: formData
    );
      
    if (result.success) {
      emit(state.copyWith(editState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(editState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  Future<void> getCarInfo() async {
    emit(state.copyWith(getState: RequestState.loading));
    // تغيير المسار إلى المسار الجديد
    final result = await ServerGate.i.getFromServer(url: 'general/complete-register-free-agent');
    if (result.success) {
      license = AttachmentModel.fromUrl(result.data?['data']?['license']);
      vehicleForm = AttachmentModel.fromUrl(result.data?['data']?['vehicle_form']);
      identity = AttachmentModel.fromUrl(result.data?['data']?['identity']); // إضافة حقل الهوية
      
      emit(state.copyWith(getState: RequestState.done));
    } else {
      emit(state.copyWith(getState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  bool get validateSave {
    // التحقق من وجود ملفات جديدة فقط
    bool hasLicense = license.file != null;
    bool hasVehicleForm = vehicleForm.file != null;
    bool hasIdentity = identity.file != null;
    
    if (!hasLicense || !hasVehicleForm || !hasIdentity) {
      FlashHelper.showToast(LocaleKeys.please_upload_all_images.tr());
      return false;
    } else if ([license.loading, vehicleForm.loading, identity.loading].contains(true)) {
      FlashHelper.showToast(LocaleKeys.uploading_images.tr());
      return false;
    } else {
      return true;
    }
  }
}
