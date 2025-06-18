import 'package:flutter/material.dart';

import '../core/utils/enums.dart';
import '../core/utils/extensions.dart';
import '../gen/assets.gen.dart';
import 'address.dart';
import 'base.dart';
import 'client.dart';
import 'order_product.dart';
import 'order_service.dart';
import 'user_model.dart';

class AgentOrderModel extends Model {
  late String clientName,
      clientImage,
      status,
      statusTrans,
      type,
      typeTrans,
      createdAt,
      paymentMethod;
  late AddressModel address, merchentAddress;
  late double price, deliveryFee, tax, totalPrice;
  late final List<AgentOrderService> details;
  late List<OrderProductModel> orderProducts;
  late List<OrderServiceModel> orderServices;
  late bool isPaid;
  late ClientModel client;

  String get nextStatus {
    switch (status) {
      case "pending" || 'new':
        return "accepted";
      case "accepted":
        return "on_way";
      case "on_way":
        return "completed";
      default:
        return "pending";
    }
  }

  String get nextProductStatus {
    switch (status) {
      case "new" || 'pending':
        return "shipped";
      case "shipped":
        return "on_way";
      case "on_way":
        return "completed";
      default:
        return "new";
    }
  }

  Color get color {
    switch (status) {
      case "pending":
        return "#12B347".color;
      case "accepted":
        return "#12B347".color;
      case "on_way":
        return "#C3A605".color;
      case "completed":
        return "#C35105".color;
      case "canceled":
        return "#EF233C".color;
      default:
        return "#12B347".color;
    }
  }

  AgentOrderModel.fromJson(Map<String, dynamic> json) {
    id = stringFromJson(json, "id");
    clientName = stringFromJson(json, "client_name");
    clientImage = stringFromJson(json, "client_image");
    status = stringFromJson(json, "status");
    statusTrans = stringFromJson(json, "status_trans");
    type = stringFromJson(json, "type");
    typeTrans = stringFromJson(json, "type_trans");
    createdAt = stringFromJson(json, "created_at");
    address = AddressModel.fromJson(json["address"]);
    merchentAddress = AddressModel.fromJson(json["merchent_address"]);
    price = doubleFromJson(json, "price");
    tax = doubleFromJson(json, "tax");
    totalPrice = doubleFromJson(json, "total_price");
    deliveryFee = doubleFromJson(json, "delivery_fee");
    if (type == 'recharge') {
      details = [
        AgentOrderService(
          id: stringFromJson(json, 'type'),
          count: intFromJson(json, 'dafora_counts'),
          price: doubleFromJson(json, 'price'),
          title: stringFromJson(json, 'type_trans'),
          image: Assets.svg.clientRefill,
        )
      ];
    } else {
      details = List<AgentOrderService>.from(
          (json["details"] ?? []).map((x) => AgentOrderService.fromJson(x)));
    }
    orderProducts = List<OrderProductModel>.from(
        (json["details"] ?? []).map((x) => OrderProductModel.fromJson(x)));
    orderServices = List<OrderServiceModel>.from(
        (json["details"] ?? []).map((x) => OrderServiceModel.fromJson(x)));
    isPaid = boolFromJson(json, "is_paid");
    paymentMethod = stringFromJson(json, "payment_method");
    client = ClientModel.fromJson(json["client"]);
  }
  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "client_name": clientName,
        "client_image": clientImage,
        "status": status,
        "status_trans": statusTrans,
        "type": type,
        "type_trans": typeTrans,
        "created_at": createdAt,
        "address": address.toJson(),
        "price": price,
        "tax": tax,
        "total_price": totalPrice,
        "delivery_fee": deliveryFee,
        if (UserModel.i.accountType != UserType.productAgent)
          "details": details.map((e) => e.toJson()).toList(),
        if (UserModel.i.accountType == UserType.productAgent &&
            orderProducts.isNotEmpty)
          "details": orderProducts.map((e) => e.toJson()).toList(),
        if (UserModel.i.accountType == UserType.productAgent &&
            orderServices.isNotEmpty)
          "details": orderServices.map((e) => e.toJson()).toList(),
        "is_paid": isPaid,
        "payment_method": paymentMethod,
        "client": client.toJson(),
      };
}

class AgentOrderService extends Model {
  late final String title;
  late final String image;
  late final int count;
  late final double price;
  bool get isService => [
        "iron_cylinder_replacement",
        "iron_cylinder_buying",
        "fiber_cylinder_replacement",
        "fiber_cylinder_buying",
        'recharge'
      ].contains(id);
  AgentOrderService(
      {required super.id,
      required this.image,
      required this.count,
      required this.price,
      required this.title});
  AgentOrderService.fromJson(Map<String, dynamic>? json) {
    id = stringFromJson(json, 'type');
    image = stringFromJson(json, 'image');
    title = stringFromJson(json, 'title');
    count = intFromJson(json, 'count');
    price = doubleFromJson(json, 'price');
  }

  @override
  Map<String, dynamic> toJson() => {
        "type": "iron_cylinder_replacement",
        "count": null,
        "price": null,
        "title": "استبدال اسطوانة الحديد"
      };
}

//  {
//             "id": 50,
//             "client_name": "Client 1",
//             "client_image": "https://gas.azmy.aait-d.com/storage/images/User/v9YxHdWeBWA6snD8f3ie0x7RTCuwPcr9jCKmJUFM.jpg",
//             "status": "pending",
//             "status_trans": "قيد الانتظار",
//             "type": "recharge",
//             "type_trans": "اعاده",
//             "created_at": "2025 Jan 30 - 16:04",
//             "address": {
//                 "id": 20,
//                 "name": "Work",
//                 "place_title": "Mansoura, Egypt",
//                 "place_description": "my work place",
//                 "lng": "31.393993534148",
//                 "lat": "31.035303155244"
//             },
//             "price": 0
//         },
