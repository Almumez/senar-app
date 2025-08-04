import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../gen/locale_keys.g.dart';
import '../controller/cubit.dart';

class ServicePriceWidget extends StatefulWidget {
  const ServicePriceWidget({
    super.key,
  });

  @override
  State<ServicePriceWidget> createState() => _ServicePriceWidgetState();
}

class _ServicePriceWidgetState extends State<ServicePriceWidget> {
  final cubit = sl<ClientDistributeGasCubit>();

  @override
  Widget build(BuildContext context) {
    // Check if orderPrices is null
    if (cubit.state.orderPrices == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/svg/orders_out.svg',
              height: 22.h,
              width: 22.w,
              color: Colors.black,
            ),
            SizedBox(width: 8.w),
            Text(
              LocaleKeys.order_price.tr(), 
              style: context.semiboldText.copyWith(fontSize: 16)
            ),
          ],
        ).withPadding(bottom: 12.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: context.borderColor.withOpacity(0.3)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              ServiceItem(
                title: LocaleKeys.service_price.tr(), 
                price: cubit.state.orderPrices!.servicesTotal.toStringAsFixed(2)
              ),
              ServiceItem(
                title: LocaleKeys.additional_options.tr(), 
                price: cubit.state.orderPrices!.additionalTotal.toStringAsFixed(2)
              ),
              ServiceItem(
                title: LocaleKeys.delivery.tr(), 
                price: (cubit.state.orderPrices!.deliveryPrice).toStringAsFixed(2)
              ),
              ServiceItem(
                title: LocaleKeys.tax.tr(), 
                price: cubit.state.orderPrices!.tax.toStringAsFixed(2)
              ),
              // ServiceItem(
              //   title: "المسافة", 
              //   price: cubit.state.orderPrices!.kilometers.toStringAsFixed(2),
              //   unit: "كم"
              // ),
              // ServiceItem(
              //   title: "رقم المحطة", 
              //   price: cubit.state.orderPrices!.stationId.toString(),
              // ),
              Divider(height: 24.h, thickness: 1, color: context.borderColor.withOpacity(0.3)),
              ServiceItem(
                title: LocaleKeys.total.tr(), 
                price: cubit.state.orderPrices!.total.toStringAsFixed(2),
                isTotal: true
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ServiceItem extends StatelessWidget {
  final String title, price;
  final String? unit;
  final bool isTotal;
  
  const ServiceItem({
    super.key, 
    required this.title, 
    required this.price, 
    this.unit,
    this.isTotal = false
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title, 
            style: isTotal 
              ? context.semiboldText.copyWith(fontSize: 14.sp) 
              : context.regularText.copyWith(fontSize: 14.sp, color: Colors.black87)
          ),
          Text.rich(
            TextSpan(
              text: price,
              style: isTotal 
                ? context.semiboldText.copyWith(fontSize: 14.sp, color: context.primaryColor) 
                : context.regularText.copyWith(fontSize: 14.sp, color: Colors.black),
              children: [
                TextSpan(
                  text: ' ${unit ?? LocaleKeys.currency.tr()}', 
                  style: isTotal 
                    ? context.semiboldText.copyWith(fontSize: 14.sp, color: context.primaryColor)
                    : context.regularText.copyWith(fontSize: 14.sp, color: Colors.black)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// 
// 