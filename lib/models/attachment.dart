import 'package:image_picker/image_picker.dart';

class AttachmentModel {
  String? key;
  String? url;
  bool loading = false;
  XFile? file; // إضافة حقل الملف
  
  AttachmentModel({
    this.key,
    this.url,
    this.file,
  });
  
  AttachmentModel.fromUrl(String? image) {
    key = image?.split('/').last;
    url = image;
  }
}