// import 'package:image_picker/image_picker.dart';

// class UploadAtachmentState {

// }

// class LoadingUploadAtachmentState extends UploadAtachmentState {}

// class FaildUploadAtachmentState extends UploadAtachmentState {
//   @override
//   String msg;
//   int errType;
//   FaildUploadAtachmentState({required this.errType, required this.msg});
// }

// class DoneUploadAtachmentState extends UploadAtachmentState {
//   @override
//   final String msg, key;
//   final XFile file;

//   DoneUploadAtachmentState(this.msg, this.key, this.file);
// }

import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/enums.dart';

class UploadAttachmentState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;
  final String key;
  XFile? file;

  UploadAttachmentState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
    this.key = '',
    this.file,
  });

  UploadAttachmentState copyWith({
    RequestState? countriesState,
    String? msg,
    ErrorType? errorType,
    String? key,
    XFile? file, required requestState,
  }) =>
      UploadAttachmentState(
        requestState: countriesState ?? requestState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
        key: key ?? this.key,
        file: file ?? this.file,
      );
}
