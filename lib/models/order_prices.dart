import 'base.dart';

class OrderPricesModel extends Model {
  late final String price, tax, deliveryFees, totalPrice, additionalServicesFees;

  OrderPricesModel.fromJson([Map<String, dynamic>? json]) {
    price = stringFromJson(json, "price");
    tax = stringFromJson(json, "tax");
    deliveryFees = stringFromJson(json, "delivery_fee");
    totalPrice = stringFromJson(json, "total_price");
    additionalServicesFees = stringFromJson(json, "additional_services_price");
  }

  @override
  Map<String, dynamic> toJson() => {
        "price": price,
        "tax": tax,
        "delivery_fee": deliveryFees,
        "total_price": totalPrice,
        "additional_services_price": additionalServicesFees,
      };
}
