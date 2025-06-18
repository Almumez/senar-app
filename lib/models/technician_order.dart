import 'package:flutter/material.dart';

import '../core/utils/extensions.dart';
import 'address.dart';
import 'base.dart';
import 'client.dart';

class TechnicianOrderModel extends Model {
  late final AddressModel address;
  late final String status, statusTranslation, createdAt, paymentMethod;

  late List<TechnicianOrdersServicesModel> services;
  late double checkFee, tax, totalPrice, price;
  late ClientModel client;

  // String get formattedDate => DateFormat("d MMMM yyyy - hh:mm a", navigator.currentContext!.locale.languageCode).format(DateTime.parse(createdAt));

  String get nextStatus {
    switch (status) {
      case "pending":
        return "accepted";
      case "accepted":
        return "on_way";
      case "on_way":
        return "completed";
      case "completed":
        return "canceled";
      case "canceled":
        return "canceled";
      default:
        return "pending";
    }
  }

  Color get color {
    switch (status) {
      case "pending":
        return "#12B347".color;
      case "accepted":
        return "#C35105".color;
      case "completed" || "checked" || "checking":
        return "#C35105".color;
      case "canceled":
        return "#EF233C".color;
      default:
        return "#12B347".color;
    }
  }

  TechnicianOrderModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    address = AddressModel.fromJson(json!["address"]);
    status = stringFromJson(json, "status");
    statusTranslation = stringFromJson(json, "status_trans");
    client = ClientModel.fromJson(json["client"]);
    createdAt = stringFromJson(json, "created_at");
    services = listFromJson(json, "details", callback: (e) => TechnicianOrdersServicesModel.fromJson(e));
    paymentMethod = stringFromJson(json, "payment_method");
    checkFee = doubleFromJson(json, "check_fee");
    price = doubleFromJson(json, "price");
    tax = doubleFromJson(json, "tax");
    totalPrice = doubleFromJson(json, "total_price");

  }
  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "address": address.toJson(),
        "status": status,
        "status_trans": statusTranslation,
        "client": client.toJson(),
        "created_at": createdAt,
        "details": services.map((e) => e.toJson()).toList(),
        "payment_method": paymentMethod,
        "check_fee": checkFee,
        "tax": tax,
        "price": price,
        "total_price": totalPrice,

      };
}

class TechnicianOrdersServicesModel extends Model {
  late final String title, description;
  TechnicianOrdersServicesModel.fromJson([Map<String, dynamic>? json]) {
    title = stringFromJson(json, "title");
    description = stringFromJson(json, "description");
  }
  @override
  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
      };
}
