import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/utils/extensions.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../../../models/client_order.dart';
import '../../../../shared/components/address_item.dart';
import '../agnent_item.dart';
import '../bill_widget.dart';
import '../payment_item.dart';
import '../product_service_type.dart';

class ClientProductOrderDetails extends StatelessWidget {
  const ClientProductOrderDetails({super.key, required this.data});

  final ClientOrderModel data;
  Color get color {
    switch (data.status) {
      case 'pending':
        return "#CE6518".color;
      case 'accepted':
        return "#168836".color;
      default:
        return "#CE6518".color;
    }
  }

  String get title {
    switch (data.status) {
      case 'pending':
        return LocaleKeys.wait_for_agent_to_take_cylinder_and_refill.tr();
      case 'accepted':
        return LocaleKeys.refilling_a_small_cylinder_now_see_cost.tr();
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInstructionsSection(context).withPadding(bottom: 25.h),
          
          _buildSectionHeader(context, LocaleKeys.delivery_person.tr(), 'assets/svg/delivery.svg'),
          _buildComponentCard(
            context, 
            child: ClientOrderAgentItem(data: data)
          ),
          
          _buildSectionHeader(context, LocaleKeys.products.tr(), 'assets/svg/clean.svg'),
          _buildComponentCard(
            context, 
            child: ProductServiceType(data: data)
          ),
          
          _buildSectionHeader(context, LocaleKeys.site_address.tr(), 'assets/svg/door.svg'),
          _buildComponentCard(
            context, 
            child: OrderDetailsAddressItem(
              title: data.address.placeTitle,
              description: data.address.placeDescription,
            )
          ),
          
          _buildSectionHeader(context, LocaleKeys.payment_method.tr(), 'assets/svg/payment.svg'),
          _buildComponentCard(
            context, 
            child: OrderPaymentItem(data: data)
          ),
          
          _buildSectionHeader(context, LocaleKeys.service_price.tr(), 'assets/svg/price.svg'),
          _buildComponentCard(
            context, 
            child: ClientBillWidget(data: data)
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstructionsSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildVerticalInstructionItem(
          context: context,
          svgAsset: 'assets/svg/clean.svg',
          text: "اسطوانة نظيفة",
        ),
        _buildVerticalInstructionItem(
          context: context,
          svgAsset: 'assets/svg/door.svg',
          text: "توصل للباب",
        ),
        _buildVerticalInstructionItem(
          context: context,
          svgAsset: 'assets/svg/warning.svg',
          text: "استلامك مسوؤليتك",
        ),
      ],
    );
  }
  
  Widget _buildVerticalInstructionItem({
    required BuildContext context, 
    required String svgAsset, 
    required String text
  }) {
    List<String> words = text.split(' ');
    
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgAsset,
            height: 24.h,
            width: 24.h,
            colorFilter: ColorFilter.mode(
              context.primaryColor,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 8.h),
          Column(
            children: words.map((word) => 
              Text(
                word,
                textAlign: TextAlign.center,
                style: context.mediumText.copyWith(
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              )
            ).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title, String svgAsset) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          SvgPicture.asset(
            svgAsset,
            height: 20.h,
            width: 20.w,
            colorFilter: ColorFilter.mode(
              context.primaryColor,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: context.semiboldText.copyWith(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
  
  Widget _buildComponentCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: child,
    );
  }
}
