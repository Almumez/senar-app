import 'base.dart';

class OrderPricesModel extends Model {
  late final double servicesTotal, additionalTotal, deliveryPrice, tax, total;

  OrderPricesModel.fromJson([Map<String, dynamic>? json]) {
    servicesTotal = doubleFromJson(json, "ServicesTotal");
    additionalTotal = doubleFromJson(json, "additionalTotal");
    deliveryPrice = doubleFromJson(json, "deliveryPrice");
    tax = doubleFromJson(json, "tax");
    total = doubleFromJson(json, "total");
  }

  @override
  Map<String, dynamic> toJson() => {
        "ServicesTotal": servicesTotal,
        "additionalTotal": additionalTotal,
        "deliveryPrice": deliveryPrice,
        "tax": tax,
        "total": total,
      };
}
