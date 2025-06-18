import 'base.dart';

class ServiceModel extends Model {
  late String title, description, type, price;
  late bool isSelected;

  ServiceModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    title = stringFromJson(json, "title");
    description = stringFromJson(json, "description");
    type = stringFromJson(json, "type");
    price = stringFromJson(json, "price");
    isSelected = false;
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "type": type,
        "price": price,
        "is_selected": isSelected,
      };
}
