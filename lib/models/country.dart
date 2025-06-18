import 'base.dart';

class CountryModel extends Model {
  late final String name, phoneCode, image, shortName;
  late final int phoneNumberLimit;

  CountryModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    name = stringFromJson(json, "name");
    phoneCode = stringFromJson(json, "phone_code");
    image = stringFromJson(json, "flag");
    shortName = stringFromJson(json, "short_name");
    phoneNumberLimit = intFromJson(json, "phone_limit");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone_code": phoneCode,
        "flag": image,
        "short_name": shortName,
        "phone_limit": phoneNumberLimit,
      };
}
