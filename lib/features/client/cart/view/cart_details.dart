import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/components/dashed_divider.dart';
import '../../../shared/components/increment_widget.dart';
import '../components/invoice_row.dart';
import '../controller/cubit.dart';
import '../controller/states.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final cubit = sl<CartCubit>();
  @override
  void initState() {
    super.initState();
    cubit.getCart();
  }

  Future<void> _refresh() async {
    await cubit.getCart();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      bloc: cubit,
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppbar(title: LocaleKeys.cart.tr()),
          bottomNavigationBar: Builder(
            builder: (context) {
              if (state.requestState == RequestState.done && cubit.data!.products.isNotEmpty) {
                return SafeArea(
                  child: AppBtn(
                    title: LocaleKeys.complete_order.tr(),
                    onPressed: () => push(NamedRoutes.clientCreateProductOrder),
                  ).withPadding(horizontal: 16.w, bottom: 16.h),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          body: PullToRefresh(
            onRefresh: _refresh,
            child: Builder(
              builder: (context) {
                if (state.requestState == RequestState.done && cubit.data!.products.isNotEmpty) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("• ${LocaleKeys.service_type.tr()}", style: context.mediumText.copyWith(fontSize: 20)).withPadding(bottom: 10.h),
                        Column(
                          children: List.generate(
                            cubit.data!.products.length,
                            (index) => Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
                                child: Row(
                                  children: [
                                    CustomImage(cubit.data!.products[index].product.image, height: 80, width: 80.h).withPadding(end: 10.w),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: context.w * 0.6,
                                          child: Text(
                                            cubit.data!.products[index].product.name,
                                            style: context.mediumText,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ).withPadding(bottom: 15.h),
                                        ),
                                        IncrementWidget(
                                          count: cubit.data!.products[index].quantity,
                                          loadingType: cubit.loadingType,
                                          isLoading: state.productId == cubit.data!.products[index].product.id,
                                          increment: () {
                                            cubit.incrementCount(productId: cubit.data!.products[index].product.id);
                                          },
                                          decrement: () {
                                            cubit.decrementCount(productId: cubit.data!.products[index].product.id);
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                )),
                          ),
                        ).withPadding(bottom: 16.h),
                        Text("• ${LocaleKeys.discount_coupon.tr()}", style: context.mediumText.copyWith(fontSize: 20)).withPadding(bottom: 10.h),
                        AppField(
                          controller: cubit.couponController,
                          hintText: LocaleKeys.add_discount_coupon.tr(),
                          readOnly: state.hasCoupon,
                          suffixIcon: TextButton(
                            child: state.couponState.isLoading
                                ? CustomProgress(size: 20.h)
                                : Text(
                                    state.hasCoupon ? LocaleKeys.delete.tr() : LocaleKeys.apply.tr(),
                                    style: context.mediumText.copyWith(fontSize: 14, color: state.hasCoupon ? context.errorColor : null),
                                  ),
                            onPressed: () => cubit.coupon(),
                          ),
                        ).withPadding(bottom: 16.h),
                        Text("• ${LocaleKeys.total_product_value.tr()}", style: context.mediumText.copyWith(fontSize: 20)).withPadding(bottom: 10.h),
                        Container(
                          width: context.w,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
                          child: Column(
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cubit.data!.products.length,
                                separatorBuilder: (context, index) => const DashedDivider().withPadding(vertical: 10.h),
                                itemBuilder: (context, index) {
                                  return InvoiceRow(context: context, title: cubit.data!.products[index].product.name, price: cubit.data!.products[index].price);
                                },
                              ),
                              const DashedDivider().withPadding(vertical: 10.h),
                              InvoiceRow(context: context, title: LocaleKeys.delivery_price.tr(), price: cubit.data!.invoice.deliveryFee),
                              const DashedDivider().withPadding(vertical: 10.h),
                              InvoiceRow(context: context, title: LocaleKeys.tax.tr(), price: cubit.data!.invoice.tax),
                              if (cubit.data!.invoice.discountFee != 0) const DashedDivider().withPadding(vertical: 10.h),
                              if (cubit.data!.invoice.discountFee != 0)
                                InvoiceRow(context: context, title: LocaleKeys.discount_coupon.tr(), price: cubit.data!.invoice.discountFee, isDiscount: true),
                              Divider(height: 30.h),
                              InvoiceRow(context: context, title: LocaleKeys.total.tr(), price: cubit.data!.invoice.totalPrice),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                } else if (state.requestState == RequestState.done && cubit.data!.products.isEmpty) {
                  return Center(child: Text(LocaleKeys.no_products_in_cart.tr(), style: context.mediumText.copyWith(fontSize: 14)));
                } else if (state.requestState == RequestState.error) {
                  return Center(child: CustomErrorWidget(title: state.msg));
                } else {
                  return Center(child: CustomProgress(size: 30.h));
                }
              },
            ),
          ),
        );
      },
    );
  }
}
