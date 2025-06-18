import 'base.dart';

class AddressModel extends Model {
  late String placeTitle, name, placeDescription;
  late double lat, lng;
  late bool isDefault;
  AddressModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    placeTitle = stringFromJson(json, "place_title");
    placeDescription = stringFromJson(json, "place_description");
    name = stringFromJson(json, "name");
    lat = doubleFromJson(json, "lat");
    lng = doubleFromJson(json, "lng");
    isDefault = boolFromJson(json, "is_default");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "place_title": placeTitle,
        "place_description": placeDescription,
        "name": name,
        "lat": lat,
        "lng": lng,
        "is_default": isDefault,
      };
}
