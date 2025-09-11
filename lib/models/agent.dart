import 'base.dart';

class AgentModel extends Model {
  late String fullname, image, address, phoneNumber;
  late String phoneCode, phone;

  AgentModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, 'id');
    fullname = stringFromJson(json, 'full_name');
    image = stringFromJson(json, 'image');
    address = stringFromJson(json, 'address');
    // Support both legacy 'phone_number' and new 'phone_code' + 'phone'
    phoneCode = stringFromJson(json, 'phone_code');
    phone = stringFromJson(json, 'phone');
    final legacyPhone = stringFromJson(json, 'phone_number');
    if (legacyPhone.isNotEmpty) {
      phoneNumber = legacyPhone;
    } else if (phoneCode.isNotEmpty && phone.isNotEmpty) {
      phoneNumber = '+$phoneCode$phone';
    } else {
      phoneNumber = '';
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        "full_name": fullname,
        "image": image,
        "address": address,
        "phone_number": phoneNumber,
        "phone_code": phoneCode,
        "phone": phone,
      };
}
