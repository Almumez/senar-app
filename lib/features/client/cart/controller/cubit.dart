import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/services/server_gate.dart';
import '../../../../../../core/utils/enums.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/cart.dart';
import 'states.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState());

  String addressId = '';
  CartModel? data;
  String loadingType = '';
  String paymentMethod = '';

  TextEditingController couponController = TextEditingController();

  Future<void> getCart() async {
    emit(state.copyWith(
      requestState: RequestState.loading,
      updateCount: RequestState.initial,
      couponState: RequestState.initial,
      hasCoupon: false,
    ));
    final result = await ServerGate.i.getFromServer(
      url: "client/cart",
    );
    if (result.success) {
      reset();
      data = CartModel.fromJson(result.data['data']);
      emit(state.copyWith(requestState: RequestState.done));
    } else {
      emit(state.copyWith(
          requestState: RequestState.error,
          msg: result.msg,
          errorType: result.errType));
    }
  }

  Future<void> updateCart(
      {required String productId, required int quantity}) async {
    emit(state.copyWith(
        updateCount: RequestState.loading, productId: productId));
    final result = await ServerGate.i.sendToServer(
      url: quantity == 0 ? "client/cart/remove" : "client/cart/add",
      body: {
        "product_id": productId,
        if (quantity != 0) "quantity": quantity,
      },
    );
    if (result.success) {
      loadingType = "";
      data = CartModel.fromJson(result.data['data']);
      emit(state.copyWith(updateCount: RequestState.done, msg: result.msg));
    } else {
      loadingType = "";
      FlashHelper.showToast(result.msg);
      emit(state.copyWith(
          updateCount: RequestState.error,
          msg: result.msg,
          errorType: result.errType));
    }
  }

  void incrementCount({required String productId}) {
    int quantity = data!.products
        .firstWhere((product) => product.product.id == productId)
        .quantity;
    loadingType = "add";
    updateCart(productId: productId, quantity: quantity + 1);
  }

  void decrementCount({required String productId}) {
    int quantity = data!.products
        .firstWhere((product) => product.product.id == productId)
        .quantity;
    loadingType = "sub";
    updateCart(productId: productId, quantity: quantity - 1);
  }

  Future<void> coupon() async {
    if (couponController.text.isNotEmpty) {
      emit(state.copyWith(couponState: RequestState.loading));
      final result = await ServerGate.i.sendToServer(
        url: "client/cart/apply-coupon",
        body: {
          "coupon": state.hasCoupon ? '' : couponController.text,
        },
      );
      if (result.success) {
        data = CartModel.fromJson(result.data['data']);
        if (state.hasCoupon) couponController.clear();
        emit(state.copyWith(
            couponState: RequestState.done,
            msg: result.msg,
            hasCoupon: !state.hasCoupon));
      } else {
        FlashHelper.showToast(result.msg);
        emit(state.copyWith(
            couponState: RequestState.error,
            msg: result.msg,
            errorType: result.errType));
      }
    } else {
      FlashHelper.showToast(LocaleKeys.please_enter_coupon_code.tr());
    }
  }

  Future<void> createOrder() async {
    if (addressId.isNotEmpty) {
      emit(state.copyWith(createOrderState: RequestState.loading));
      final result = await ServerGate.i.sendToServer(
        url: "client/product-order",
        body: {
          "address_id": addressId,
          "price_before_discount": data?.invoice.priceBeforeDiscount,
          "price": data?.invoice.price,
          "tax": data?.invoice.tax,
          "delivery_fee": data?.invoice.deliveryFee,
          "total_price": data?.invoice.totalPrice,
          "coupon": couponController.text,
          "payment_method": paymentMethod,
        },
      );
      if (result.success) {
        reset();
        emit(state.copyWith(
            createOrderState: RequestState.done,
            msg: result.msg,
            hasCoupon: false));
      } else {
        FlashHelper.showToast(result.msg);
        emit(state.copyWith(
            createOrderState: RequestState.error,
            msg: result.msg,
            errorType: result.errType));
      }
    } else {
      FlashHelper.showToast(LocaleKeys.select_your_location.tr());
    }
  }

  reset() {
    addressId = '';
    loadingType = "";
    couponController.clear();
  }
}
