import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/flash_helper.dart';
import 'attachment_state.dart';

class UploadAttachmentCubit extends Cubit<UploadAttachmentState> {
  UploadAttachmentCubit() : super(UploadAttachmentState());

  XFile? file;

  Future<void> uploadAttachment({required String model, String type = 'image'}) async {
    emit(state.copyWith(requestState: RequestState.loading));
    CustomResponse response = await ServerGate.i.sendToServer(url: "general/attachment", formData: {
      "file": MultipartFile.fromFileSync(file!.path),
      "attachment_type": type,
      "model": model,
    });
    if (response.success) {
      emit(state.copyWith(requestState: RequestState.done, msg: response.msg, file: file, key: response.data?["data"]['path']));
    } else {
      FlashHelper.showToast(response.msg);
      emit(state.copyWith(requestState: RequestState.error, msg: response.msg, errorType: response.errType));
    }
  }

  void clear() {
    file = null;
    emit(state.copyWith(requestState: RequestState.initial));
  }
}
