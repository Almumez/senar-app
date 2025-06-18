import 'base.dart';
import 'product.dart';

class FactoryModel extends Model {
  late String fullname, image, city, country, description;
  late List<ProductModel> products;

  String get address => [
        if (city.isNotEmpty) city,
        if (country.isNotEmpty) country,
      ].join(', ');

  FactoryModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    fullname = stringFromJson(json, "full_name");
    image = stringFromJson(json, "image");
    city = stringFromJson(json, "city");
    country = stringFromJson(json, "country");
    description = stringFromJson(json, "description");
    products = listFromJson(json, "products", callback: (e) => ProductModel.fromJson(e));
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullname,
        "image": image,
        "city": city,
        "country": country,
        "description": description,
      };
}
