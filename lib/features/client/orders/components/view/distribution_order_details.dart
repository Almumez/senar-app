import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/widgets/custom_image.dart';
import '../../../../../core/widgets/custom_radius_icon.dart';
import '../agnent_item.dart';
import '../payment_item.dart';

import '../../../../../core/utils/extensions.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../../../models/client_order.dart';
import '../../../../shared/components/address_item.dart';
import '../bill_widget.dart';

class ClientDistributionOrderDetails extends StatelessWidget {
  const ClientDistributionOrderDetails({
    super.key,
    required this.data,
  });

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
        return LocaleKeys.while_waiting_for_the_application_to_be_accepted.tr();
      case 'accepted':
        return LocaleKeys.while_waiting_for_the_application_to_be_accepted.tr();
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAgentInfoCard(context),
            
            // عرض الخدمات الجديدة من API
            if (data.items.isNotEmpty) ...[
              Container(
                width: MediaQuery.of(context).size.width - 32.w,
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "الخدمات",
                  style: context.semiboldText.copyWith(fontSize: 16.sp),
                ),
              ),
              ...List.generate(
                data.items.length,
                (index) => _buildNewServiceCard(context, data.items[index], isFirst: index == 0),
              ),
            ] else ...[
              // عرض الخدمات القديمة إذا لم تكن هناك خدمات جديدة
              ...List.generate(
                data.orderServices.length,
                (index) {
                  final service = data.orderServices[index];
                  if (!service.isService) return const SizedBox();
                  return _buildServiceCard(context, service, isFirst: index == 0);
                },
              ),
              if (data.orderServices.any((e) => !e.isService)) ...[
                ...List.generate(
                  data.orderServices.length,
                  (index) {
                    final service = data.orderServices[index];
                    if (service.isService) return const SizedBox();
                    return _buildAdditionalServiceCard(context, service);
                  },
                ),
              ],
            ],
            
            _buildAddressCard(context),

            OrderPaymentItem(data: data).withPadding(start: 16.w, end: 16.w, bottom: 16.h),
            ClientBillWidget(data: data),
           
          ],
        ),
      ),
    );
  }


  Widget _buildAgentInfoCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 32.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ClientOrderAgentItem(data: data),
    );
  }

  Widget _buildNewServiceCard(BuildContext context, dynamic item, {bool isFirst = false}) {
    return Container(
      width: MediaQuery.of(context).size.width - 32.w,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          if (isFirst)
            SvgPicture.asset(
              'assets/svg/orders_out.svg',
              height: 20.h,
              width: 20.w,
              colorFilter: ColorFilter.mode(
                context.primaryColor,
                BlendMode.srcIn,
              ),
            ).withPadding(end: 12.w),
          // عرض صورة الخدمة
          CustomImage(
            item.subServiceImage.isNotEmpty 
              ? 'https://stage.senar.me/${item.subServiceImage}'
              : '',
            height: 40.sp,
            width: 40.sp,
            borderRadius: BorderRadius.circular(8.r),
          ).withPadding(end: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.subServiceName,
                      style: context.mediumText.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "(${item.quantity}x)",
                      style: context.mediumText.copyWith(
                        fontSize: 14.sp,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (item.subServiceDescription.isNotEmpty)
                  Text(
                    item.subServiceDescription,
                    style: context.regularText.copyWith(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).withPadding(top: 2.h),
              ],
            ),
          ),
        ],
      ).withPadding(start: isFirst ? 15.w : 45.w),
    );
  }

  Widget _buildServiceCard(BuildContext context, dynamic service, {bool isFirst = false}) {
    return Container(
      width: MediaQuery.of(context).size.width - 32.w,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          if (isFirst)
            SvgPicture.asset(
              'assets/svg/orders_out.svg',
              height: 24.h,
              width: 24.w,
              colorFilter: ColorFilter.mode(
                context.primaryColor,
                BlendMode.srcIn,
              ),
            ).withPadding(end: 8.w),
          CustomImage(
            service.image,
            height: 45.sp,
            width: 45.sp,
            borderRadius: BorderRadius.circular(8.r),
          ).withPadding(end: 16.w,),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      service.title,
                      style: context.semiboldText.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "(${service.count}x)",
                      style: context.mediumText.copyWith(
                        fontSize: 14.sp,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ).withPadding(start: isFirst ? 15.w : 45.w),
    );
  }
  
  Widget _buildAdditionalServiceCard(BuildContext context, dynamic service) {
    return Container(
      width: MediaQuery.of(context).size.width - 32.w,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CustomImage(
            service.image,
            height: 48.sp,
            width: 48.sp,
            borderRadius: BorderRadius.circular(8.r),
          ).withPadding(end: 16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      service.title,
                      style: context.semiboldText.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "(${service.count}x)",
                      style: context.mediumText.copyWith(
                        fontSize: 14.sp,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).withPadding(start: 45.w);
  }
  
  Widget _buildAddressCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 32.w,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: OrderDetailsAddressItem(
        lable: "",
        title: data.address.placeTitle,
        description: data.address.placeDescription,
      ),
    );
  }

}
