import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routes/app_routes_fun.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/custom_radius_icon.dart';
import '../../../gen/locale_keys.g.dart';

import '../../../core/services/service_locator.dart';
import '../../../core/utils/enums.dart';
import '../../client/cart/controller/cubit.dart';
import '../../client/cart/controller/states.dart';

class ShowYourCartBtn extends StatelessWidget {
  const ShowYourCartBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
        bloc: sl<CartCubit>(),
        builder: (context, state) {
          if (state.requestState == RequestState.done && sl<CartCubit>().data!.products.isNotEmpty) {
            return SafeArea(
              child: InkWell(
                onTap: () => push(NamedRoutes.cart).then((_) => sl<CartCubit>().getCart()),
                child: Container(
                  height: 56.h,
                  width: context.w,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(28.r)),
                  ),
                  child: Row(
                    children: [
                      CustomRadiusIcon(
                        size: 24.h,
                        backgroundColor: context.primaryColorLight,
                        child: Text(
                          sl<CartCubit>().data!.products.length.toString(),
                          style: context.mediumText.copyWith(fontSize: 14, color: context.primaryColor),
                        ),
                      ).withPadding(end: 5.w),
                      Expanded(
                        child: Text(LocaleKeys.show_your_cart.tr(), style: context.mediumText.copyWith(color: context.primaryColorLight, fontSize: 14)),
                      ),
                      Text("${sl<CartCubit>().data!.invoice.totalPrice} ${LocaleKeys.currency.tr()}",
                          style: context.mediumText.copyWith(color: context.primaryColorLight, fontSize: 14))
                    ],
                  ),
                ).withPadding(horizontal: 16.w, bottom: 16.h),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
