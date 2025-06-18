import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/service_locator.dart';
import '../../cart/controller/cubit.dart';

import '../../../../../../core/services/server_gate.dart';
import '../../../../../../core/utils/enums.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/successfully_sheet.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/product.dart';
import 'states.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit() : super(ProductDetailsState());

  ProductModel? data;
  List<ProductModel> similarProducts = [];
  CompanyServiceType? type;
  int count = 0;

  Future<void> getDetails({required String id}) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.getFromServer(
      url: "client/services/product/$id",
    );
    if (result.success) {
      data = ProductModel.fromJson(result.data['data']['product']);
      similarProducts = List<ProductModel>.from(result.data['data']['similar_products'].map((x) => ProductModel.fromJson(x)));

      emit(state.copyWith(requestState: RequestState.done));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }

  void incrementCount() {
    if (count >= data!.quantity) {
      FlashHelper.showToast(LocaleKeys.this_product_is_out_of_stock.tr());
    } else {
      count = count + 1;
    }
    emit(state.copyWith(updateCount: RequestState.done));
  }

  void decrementCount() {
    count = count - 1;
    emit(state.copyWith(updateCount: RequestState.done));
  }

  Future<void> addToCart({required String id}) async {
    emit(state.copyWith(addToCartState: RequestState.loading));
    final response = await ServerGate.i.sendToServer(
      url: 'client/cart/add',
      body: {
        "product_id": id,
        "quantity": count,
      },
    );

    if (response.success) {
      showModalBottomSheet(
        elevation: 0,
        context: navigator.currentContext!,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context) => SuccessfullySheet(
          title: LocaleKeys.product_added_to_cart_successfully.tr(),
        ),
      );
      sl<CartCubit>().getCart();
      emit(state.copyWith(addToCartState: RequestState.done));
    } else {
      FlashHelper.showToast(response.msg);
      emit(state.copyWith(addToCartState: RequestState.error, msg: response.msg, errorType: response.errType));
    }
  }

  productSelected() {
    if (count > 0) {
      return true;
    } else {
      return false;
    }
  }
}
