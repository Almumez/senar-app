import 'base.dart';

class ClientModel extends Model {
  late String fullname, image, address, phoneCode, phone;

  ClientModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, 'id');
    fullname = stringFromJson(json, 'full_name');
    image = stringFromJson(json, 'image');
    address = stringFromJson(json, 'address');
    phoneCode = stringFromJson(json, 'phone_code');
    phone = stringFromJson(json, 'phone');
  }

  @override
  Map<String, dynamic> toJson() => {
        "full_name": fullname,
        "image": image,
        "address": address,
        "phone_code": phoneCode,
        "phone": phone,
      };
}
