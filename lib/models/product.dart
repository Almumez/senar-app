import 'base.dart';

class ProductModel extends Model {
  late String name, type, price, image, description, deliveryPrice;
  late int quantity;
  late bool isActive;
  late SellerModel seller;

  ProductModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    name = stringFromJson(json, "name");
    type = stringFromJson(json, "type");
    price = stringFromJson(json, "price");
    quantity = intFromJson(json, "quantity");
    image = stringFromJson(json, "image");
    isActive = boolFromJson(json, "is_active");
    description = stringFromJson(json, "description");
    deliveryPrice = stringFromJson(json, "delivery_tax");
    seller = SellerModel.fromJson(json?["seller"] ?? {});
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "price": price,
        "quantity": quantity,
        "image": image,
        "is_active": isActive,
        "description": description,
        "delivery_tax": deliveryPrice,
        "seller": seller.toJson(),
      };
}

class SellerModel extends Model {
  late String fullname, image, phoneCode, phone, email, userType;
  SellerModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, "id");
    fullname = stringFromJson(json, "full_name");
    image = stringFromJson(json, "image");
    phoneCode = stringFromJson(json, "phone_code");
    phone = stringFromJson(json, "phone");
    email = stringFromJson(json, "email");
    userType = stringFromJson(json, "user_type");
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullname,
        "image": image,
        "phone_code": phoneCode,
        "phone": phone,
        "email": email,
        "user_type": userType,
      };
}
