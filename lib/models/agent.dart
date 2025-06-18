import 'base.dart';

class AgentModel extends Model {
  late String fullname, image, address, phoneNumber;

  AgentModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, 'id');
    fullname = stringFromJson(json, 'full_name');
    image = stringFromJson(json, 'image');
    address = stringFromJson(json, 'address');
    phoneNumber = stringFromJson(json, 'phone_number');
  }

  @override
  Map<String, dynamic> toJson() => {
        "full_name": fullname,
        "image": image,
        "address": address,
        "phone_number": phoneNumber,
      };
}
