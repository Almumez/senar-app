import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/successfully_sheet.dart';
import '../../../shared/pages/navbar/cubit/navbar_cubit.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/components/dashed_divider.dart';
import '../../addresses/components/my_addresses.dart';
import '../components/invoice_row.dart';
import '../controller/cubit.dart';
import '../controller/states.dart';

class ClientCreateProductOrderView extends StatefulWidget {
  const ClientCreateProductOrderView({super.key});

  @override
  State<ClientCreateProductOrderView> createState() => _ClientCreateProductOrderViewState();
}

class _ClientCreateProductOrderViewState extends State<ClientCreateProductOrderView> {
  final cubit = sl<CartCubit>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.complete_order.tr()),
      bottomNavigationBar: BlocConsumer<CartCubit, CartState>(
        bloc: cubit,
        buildWhen: (previous, current) => previous.createOrderState != current.createOrderState,
        listenWhen: (previous, current) => previous.createOrderState != current.createOrderState,
        listener: (context, state) {
          if (state.createOrderState.isDone) {
            showModalBottomSheet(
              elevation: 0,
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              builder: (context) => SuccessfullySheet(
                title: LocaleKeys.order_created_successfully.tr(),
                onLottieFinish: () {
                  sl<NavbarCubit>().changeTap(1);
                  Navigator.of(context).popUntil((v) => v.isFirst);
                },
              ),
            );
          }
        },
        builder: (context, state) {
          return AppBtn(
            loading: state.createOrderState.isLoading,
            title: LocaleKeys.complete_order.tr(),
            onPressed: () {
              // cubit.createOrder();
              push(NamedRoutes.clientCreateOrderSelectPayment, arg: {"cubit": cubit}).then((value) {
                if (cubit.paymentMethod != '') {
                  cubit.createOrder();
                }
              });
            },
          );
        },
      ).withPadding(horizontal: 16.w, bottom: 16.h),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyAddressWidgets(callback: (val) {
              cubit.addressId = val;
            }).withPadding(bottom: 16.h),
            Text("• ${LocaleKeys.service_type.tr()}", style: context.semiboldText.copyWith(fontSize: 16)).withPadding(bottom: 10.h),
            Column(
              children: List.generate(
                cubit.data!.products.length,
                (index) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
                  child: Row(
                    children: [
                      CustomImage(
                        cubit.data!.products[index].product.image,
                        height: 80,
                        width: 80.h,
                      ).withPadding(end: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: context.w * 0.6,
                            child: Text(cubit.data!.products[index].product.name, style: context.mediumText, maxLines: 2, overflow: TextOverflow.ellipsis)
                                .withPadding(bottom: 10.h),
                          ),
                          Text(
                            '${LocaleKeys.quantity.tr()} : ${cubit.data!.products[index].quantity.toString()}',
                            style: context.mediumText.copyWith(color: context.hintColor),
                          ),
                        ],
                      )
                    ],
                  ).withPadding(bottom: 10.h),
                ),
              ),
            ).withPadding(bottom: 16.h),
            Text("• ${LocaleKeys.total_product_value.tr()}", style: context.semiboldText.copyWith(fontSize: 16)).withPadding(bottom: 10.h),
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
      ),
    );
  }
}
