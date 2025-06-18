import 'package:easy_localization/easy_localization.dart';
import '../gen/locale_keys.g.dart';

import 'base.dart';

class BuyCylinderServiceModel extends Model {
  late final String image;
  late final String key;
  late final List<BuyCylinderSubServiceModel> sub;


  String get title {
    switch (key) {
      case "iron":
        return LocaleKeys.iron_cylinder.tr();
      case "fiber":
        return LocaleKeys.fiber_cylinder.tr();
      case "additional":
        return LocaleKeys.additional_options.tr();
      default:
        return LocaleKeys.iron_cylinder.tr();
    }
  }

  String get subTitle {
    switch (key) {
      case "iron":
        return LocaleKeys.iron_cylinder_service_subtitle.tr();
      case "fiber":
        return LocaleKeys.fiber_cylinder_service_subtitle.tr();
      case "additional":
        return '';
      default:
        return LocaleKeys.iron_cylinder_service_subtitle.tr();
    }
  }


  BuyCylinderServiceModel.fromJson([Map<String, dynamic>? json]) {
    image = stringFromJson(json, "image");
    key = stringFromJson(json, "key");
    sub = listFromJson<BuyCylinderSubServiceModel>(json, "sub", callback: BuyCylinderSubServiceModel.fromJson);
  }
  @override
  Map<String, dynamic> toJson() => {"image": image, "key": key, "sub": sub.map((e) => e.toJson()).toList()};
}



class BuyCylinderSubServiceModel extends Model {
  late final String type, price, title, description, image;
  late int count;

  BuyCylinderSubServiceModel.fromJson([Map<String, dynamic>? json]) {
    type = stringFromJson(json, "type");
    price = stringFromJson(json, "price");
    title = stringFromJson(json, "title");
    image = stringFromJson(json, "image");
    description = stringFromJson(json, "description");
    count = 0;
  }
  @override
  Map<String, dynamic> toJson() => {"type": type, "price": price, "title": title, "image": image, "description": description, "count": count};
}
