import 'base.dart';
import 'service.dart';

class CompanyModel extends Model {
  late String fullname, image, city, country, description;
  late List<ServiceModel> services;

  String get address => "$city, $country";

  CompanyModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    fullname = stringFromJson(json, "full_name");
    image = stringFromJson(json, "image");
    city = stringFromJson(json, "city");
    country = stringFromJson(json, "country");
    services = listFromJson(json, "services", callback: (e) => ServiceModel.fromJson(e));
    description = stringFromJson(json, "description");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullname,
        "image": image,
        "city": city,
        "country": country,
        "services": services.map((e) => e.toJson()).toList(),
        "description": description,
      };
}
