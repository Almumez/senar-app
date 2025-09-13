import 'package:flutter/material.dart';

import '../core/utils/extensions.dart';
import 'address.dart';
import 'agent.dart';
import 'base.dart';
import 'order_product.dart';
import 'order_service.dart';
import 'order_item.dart';

class ClientOrderModel extends Model {
  late final AgentModel agent, merchant;
  late final AddressModel address;
  late String status, statusTrans, type, typeTrans, paymentMethod, daforaCount;
  late DateTime createdAt;
  late double price, tax, deliveryFee, totalPrice , checkFee;
  late int quantity;
  late bool isPaid, isRated;
  late List<OrderServiceModel> orderServices;
  late List<OrderProductModel> orderProducts;
  late List<OrderItemModel> items;
  late OrderSummaryModel summary;

  Color get color {
    switch (status) {
      case "pending":
        return "#C3A605".color;
      case "accepted":
        return "#12B347".color;
      case "on_way":
        return "#C3A605".color;
      case "completed" || "checked":
        return "#C35105".color;
      case "canceled":
        return "#EF233C".color;
      default:
        return "#12B347".color;
    }
  }

  ClientOrderModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    agent = AgentModel.fromJson(json?["agent"]);
    merchant = AgentModel.fromJson(json?["merchant"]);
    address = AddressModel.fromJson(json?["address"]);
    status = stringFromJson(json, "status");
    statusTrans = stringFromJson(json, "status_trans");
    type = stringFromJson(json, "type");
    typeTrans = stringFromJson(json, "type_trans");
    price = doubleFromJson(json, "price");
    tax = doubleFromJson(json, "tax");
    deliveryFee = doubleFromJson(json, "delivery_fee");
    totalPrice = doubleFromJson(json, "total_price");
    createdAt = dateFromJson(json, "created_at", parseingFormat: 'yyyy MMM dd - HH:mm');
    paymentMethod = stringFromJson(json, "payment_method");
    isPaid = boolFromJson(json, "is_paid");
    isRated = boolFromJson(json, "is_rated");
    daforaCount = stringFromJson(json, "dafora_counts");
    quantity = intFromJson(json, "quantity");
    orderServices = listFromJson(json, "details", callback: (e) => OrderServiceModel.fromJson(e));
    orderProducts = listFromJson(json, "details", callback: (e) => OrderProductModel.fromJson(e));
    items = listFromJson(json, "items", callback: (e) => OrderItemModel.fromJson(e));
    summary = OrderSummaryModel.fromJson(json?["summary"] ?? {});
    checkFee = doubleFromJson(json, "check_fee");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "agent": agent.toJson(),
        "merchant": merchant.toJson(),
        "address": address.toJson(),
        "status": status,
        "status_trans": statusTrans,
        "type": type,
        "type_trans": typeTrans,
        "price": price,
        "tax": tax,
        "delivery_fee": deliveryFee,
        "total_price": totalPrice,
        "created_at": createdAt,
        "is_paid": isPaid,
        "payment_method": paymentMethod,
        "dafora_counts": daforaCount,
        "quantity": quantity,
        if (orderServices.isNotEmpty) "details": orderServices.map((e) => e.toJson()).toList(),
        if (orderProducts.isNotEmpty) "details": orderProducts.map((e) => e.toJson()).toList(),
        "items": items.map((e) => e.toJson()).toList(),
        "summary": summary.toJson(),
        "check_fee": checkFee,
        "is_rated": isRated
      };
}



