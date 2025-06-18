class AttachmentModel {
  String? key;
  String? url;
  bool loading = false;
  AttachmentModel({
    this.key,
    this.url,
  });
  AttachmentModel.fromUrl(String? image) {
    key = image?.split('/').last;
    url = image;
  }
}