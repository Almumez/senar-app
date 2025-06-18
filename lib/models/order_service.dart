import 'base.dart';

class OrderServiceModel extends Model {
  late final String title, description, image, type, count;
  late final double price;
  bool get isService => ["iron_cylinder_replacement", "iron_cylinder_buying", "fiber_cylinder_replacement", "fiber_cylinder_buying", 'recharge'].contains(type);

  OrderServiceModel.fromJson([Map<String, dynamic>? json]) {
    title = stringFromJson(json, "title", defaultValue: json?['sub_services_title'] ?? '');
    description = stringFromJson(json, "sub_services_desc");
    image = stringFromJson(json, "image");
    price = doubleFromJson(json, "price");
    type = stringFromJson(json, "type");
    count = stringFromJson(json, "count");
  }
  @override
  Map<String, dynamic> toJson() => {"title": title, "description": description, "image": image, "price": price, "type": type, "count": count};
}
