import 'base.dart';

class OrderItemModel extends Model {
  late String subServiceId;
  late String subServiceName;
  late String subServiceDescription;
  late int quantity;
  late double unitPrice;
  late double lineTotal;
  late String createdAt;
  late String updatedAt;

  OrderItemModel.fromJson(Map<String, dynamic> json) {
    id = stringFromJson(json, "id");
    subServiceId = stringFromJson(json["sub_service"], "id");
    subServiceName = stringFromJson(json["sub_service"], "name");
    subServiceDescription = stringFromJson(json["sub_service"], "description");
    quantity = intFromJson(json, "quantity");
    unitPrice = doubleFromJson(json, "unit_price");
    lineTotal = doubleFromJson(json, "line_total");
    createdAt = stringFromJson(json, "created_at");
    updatedAt = stringFromJson(json, "updated_at");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "sub_service": {
          "id": subServiceId,
          "name": subServiceName,
          "description": subServiceDescription,
        },
        "quantity": quantity,
        "unit_price": unitPrice,
        "line_total": lineTotal,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class OrderSummaryModel extends Model {
  late int itemsCount;
  late double subtotal;
  late double tax;
  late double deliveryFee;
  late double total;

  OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    itemsCount = intFromJson(json, "items_count");
    subtotal = doubleFromJson(json, "subtotal");
    tax = doubleFromJson(json, "tax");
    deliveryFee = doubleFromJson(json, "delivery_fee");
    total = doubleFromJson(json, "total");
  }

  @override
  Map<String, dynamic> toJson() => {
        "items_count": itemsCount,
        "subtotal": subtotal,
        "tax": tax,
        "delivery_fee": deliveryFee,
        "total": total,
      };
}
