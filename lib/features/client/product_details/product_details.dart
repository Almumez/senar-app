import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_btn.dart';
import '../../../core/widgets/custom_grid.dart';
import '../../../core/widgets/custom_image.dart';
import '../../../core/widgets/custom_radius_icon.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading.dart';
import '../../../gen/locale_keys.g.dart';
import '../../../models/product.dart';
import '../../shared/components/increment_widget.dart';
import '../../shared/components/product_item.dart';
import 'controller/cubit.dart';
import 'controller/states.dart';

class ProductDetailsView extends StatefulWidget {
  final ProductModel data;
  const ProductDetailsView({super.key, required this.data});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  final cubit = sl<ProductDetailsCubit>();

  @override
  void initState() {
    super.initState();
    cubit.getDetails(id: widget.data.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      bloc: cubit,
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          bottomNavigationBar: Builder(
            builder: (context) {
              if (state.requestState.isDone) {
                return SafeArea(
                  child: AppBtn(
                    enable: cubit.productSelected(),
                    loading: state.addToCartState.isLoading,
                    onPressed: () => cubit.addToCart(id: widget.data.id),
                    title: LocaleKeys.add_to_cart.tr(),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ).withPadding(horizontal: 16.w, bottom: 16.h),
          body: Builder(
            builder: (context) {
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    snap: true,
                    floating: true,
                    expandedHeight: kToolbarHeight + 346.h,
                    backgroundColor: '#f5f5f5'.color,
                    // title: Text(widget.data.name),

                    centerTitle: true,
                    leading: CustomRadiusIcon(
                      size: 48.w,
                      onTap: () => Navigator.pop(context),
                      backgroundColor: context.primaryColorLight,
                      child: Icon(Icons.arrow_back),
                    ).toStart.withPadding(horizontal: 20.w),
                    leadingWidth: context.w,
                    flexibleSpace: FlexibleSpaceBar(
                      background: CustomImage(
                        widget.data.image,
                        width: context.w,
                        fit: BoxFit.contain,
                      ).center,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.data.name, style: context.mediumText.copyWith(fontSize: 20)),
                        Text.rich(
                          TextSpan(text: "${LocaleKeys.price.tr()}: ", style: context.mediumText.copyWith(fontSize: 14), children: [
                            TextSpan(
                              text: "${widget.data.price} ${LocaleKeys.currency.tr()}",
                              style: context.mediumText.copyWith(fontSize: 14),
                            ),
                          ]),
                        ),
                        Divider(height: 40.h),
                        Builder(
                          builder: (context) {
                            if (state.requestState == RequestState.done) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(LocaleKeys.specify_quantity.tr(), style: context.mediumText.copyWith(fontSize: 20)),
                                      IncrementWidget(
                                        count: cubit.count,
                                        increment: () {
                                          cubit.incrementCount();
                                        },
                                        decrement: () {
                                          cubit.decrementCount();
                                        },
                                      )
                                    ],
                                  ),
                                  Divider(height: 40.h),
                                  Text(LocaleKeys.product_delivery_charges.tr(), style: context.mediumText.copyWith(fontSize: 20)).withPadding(bottom: 8.h),
                                  Text("• ( ${cubit.data!.deliveryPrice} ${LocaleKeys.currency.tr()} )", style: context.mediumText.copyWith(fontSize: 14)),
                                  Divider(height: 40.h),
                                  Text("${LocaleKeys.description.tr()} : ", style: context.mediumText.copyWith(fontSize: 20)).withPadding(bottom: 8.h),
                                  Text("• ${cubit.data!.description}", style: context.mediumText.copyWith(fontSize: 14)),
                                  Divider(height: 40.h),
                                  if (cubit.similarProducts.isNotEmpty)
                                    Text(
                                      LocaleKeys.similar_products.tr(),
                                      style: context.boldText.copyWith(fontSize: 16),
                                    ),
                                ],
                              );
                            } else if (state.requestState == RequestState.error) {
                              return CustomErrorWidget(title: state.msg);
                            }
                            return Center(child: CustomProgress(size: 30.h));
                          },
                        ),
                      ],
                    ).withPadding(horizontal: 16.w, vertical: 16.h),
                  ),
                  Builder(
                    builder: (context) {
                      if (state.requestState == RequestState.done && cubit.similarProducts.isNotEmpty) {
                        return CustomSliverGrid(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          itemPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                          itemCount: cubit.similarProducts.length,
                          crossCount: 2,
                          itemBuilder: (context, index) => ProductItem(data: cubit.similarProducts[index]),
                        );
                      } else {
                        return const SliverToBoxAdapter(child: SizedBox.shrink());
                      }
                    },
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }
}
