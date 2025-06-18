import 'base.dart';
import 'product.dart';

class CartModel extends Model {
  late CartInvoiceModel invoice;
  late List<CartProductModel> products;
  CartModel.fromJson([Map<String, dynamic>? json]) {
    invoice = CartInvoiceModel.fromJson(json!['pricings']);
    products = List<CartProductModel>.from(json['cart_products'].map((x) => CartProductModel.fromJson(x)));
  }

  @override
  Map<String, dynamic> toJson() => {
        "pricings": invoice.toJson(),
        "cart_products": products.map((e) => e.toJson()).toList(),
      };
}

class CartProductModel extends Model {
  late ProductModel product;
  late int quantity;
  late double price;
  CartProductModel.fromJson([Map<String, dynamic>? json]) {
    id = stringFromJson(json, 'id');
    product = ProductModel.fromJson(json!['product']);
    quantity = intFromJson(json, 'quantity');
    price = doubleFromJson(json, 'price');
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "product": product.toJson(),
        "quantity": quantity,
        "price": price,
      };
}

class CartInvoiceModel extends Model {
  late double priceBeforeDiscount, price, tax, deliveryFee, totalPrice, discountFee;
  CartInvoiceModel.fromJson([Map<String, dynamic>? json]) {
    priceBeforeDiscount = doubleFromJson(json, "price_before_discount");

    price = doubleFromJson(json, "price");
    tax = doubleFromJson(json, "tax");
    deliveryFee = doubleFromJson(json, "delivery_fee");
    totalPrice = doubleFromJson(json, "total_price");
    discountFee = doubleFromJson(json, "discount");
  }

  @override
  Map<String, dynamic> toJson() => {
        "price_before_discount": priceBeforeDiscount,
        "price": price,
        "tax": tax,
        "delivery_fee": deliveryFee,
        "total_price": totalPrice,
        "discount": discountFee,
      };
}
