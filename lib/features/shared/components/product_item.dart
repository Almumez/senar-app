import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/routes/app_routes_fun.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_btn.dart';
import '../../../core/widgets/custom_image.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/locale_keys.g.dart';
import '../../../models/product.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key, required this.data});

  final ProductModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: Color(0xfff5f5f5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImage(
            data.image,
            height: 150.h,
            width: 160.w,
            borderRadius: BorderRadius.circular(8.r),
            fit: BoxFit.cover,
          ),
          Text(data.name, style: context.mediumText.copyWith(fontSize: 14)).withPadding(top: 4.h),
          Text("${data.price} ${LocaleKeys.currency.tr()}", style: context.mediumText.copyWith(fontSize: 14)).withPadding(top: 4.h),
          AppBtn(
            height: 32.h,
            title: LocaleKeys.add_to_cart.tr(),
            icon: CustomImage(Assets.svg.cartIcon, color: context.primaryColorLight),
            onPressed: () => push(NamedRoutes.productDetails, arg: {"data": data}),
          )
        ],
      ),
    );
  }
}
