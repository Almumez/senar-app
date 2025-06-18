import 'base.dart';

class OrdersCountModel extends Model {
  late final String completed, current, rejected;

  OrdersCountModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    completed = stringFromJson(json, "completed_orders");
    current = stringFromJson(json, "pending_orders");
    rejected = stringFromJson(json, "rejected_orders");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "completed_orders": completed,
        "pending_orders": current,
        "rejected_orders": rejected,
      };
}
