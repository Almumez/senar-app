import 'base.dart';
import 'product.dart';

class OrderProductModel extends Model {
  late final ProductModel product;
  late final int quantity;
  late final double price;
  late final String title;

  OrderProductModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    product = ProductModel.fromJson(json?["product"]);
    quantity = intFromJson(json, "quantity");
    title = stringFromJson(json, 'title');
    price = doubleFromJson(json, "price");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "product": product.toJson(),
        "quantity": quantity,
        "price": price,
      };
}
