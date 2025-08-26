import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widget/bill_widget.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/method.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/custom_radius_icon.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/agent_order_client_item.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/components/status_container.dart';
import '../cubit/order_details_cubit.dart';
import '../cubit/order_details_state.dart';
import '../widget/agent_order_actions.dart';
import 'package:flutter/rendering.dart';

class OrderDetailsView extends StatefulWidget {
  final String id;
  final String type;
  const OrderDetailsView({super.key, required this.id, required this.type});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  final cubit = sl<AgentOrderDetailsCubit>();
  @override
  void initState() {
    super.initState();
    cubit.getOrderDetails(widget.id, widget.type);
  }

  Future<void> _handleRefresh() async {
    cubit.getOrderDetails(widget.id, widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.order_details.tr()),
      bottomNavigationBar: AgentOrderActions(cubit: cubit),
      body: BlocBuilder<AgentOrderDetailsCubit, AgentOrderDetailsState>(
        bloc: cubit,
        buildWhen: (previous, current) => previous.getOrderState != current.getOrderState,
        builder: (context, state) {
          if (cubit.order != null) {
            var item = cubit.order!;
            return PullToRefresh(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section with order number and status
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 16.w),
                              child: Text(
                                "${cubit.order!.id}#", 
                                style: context.mediumText.copyWith(fontSize: 14.sp)
                              ),
                            ),
                            Container(
                              width: 105.w,
                              height: 30.h,
                              child: StatusContainer(
                                title: cubit.order!.statusTrans,
                                color: cubit.order!.color,
                              ),
                            )
                          ],
                        ),
                      ),

                      
                      // Client information section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: AgentOrderClientItem(
                          data: item.client,
                          orderStatus: item.status,
                        ),
                      ),
                      
                      // Services list - عرض الخدمات الجديدة من API
                      if (item.items.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            LocaleKeys.services.tr(),
                            style: context.semiboldText.copyWith(fontSize: 16.sp),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ...List.generate(
                          item.items.length,
                          (index) => _buildNewServiceCard(context, item.items[index], isFirst: index == 0),
                        ),
                      ] else ...[
                        // عرض الخدمات القديمة إذا لم تكن هناك خدمات جديدة
                        ...List.generate(
                          item.details.length,
                          (index) {
                            final service = item.details[index];
                            if (!service.isService) return SizedBox();
                            return _buildServiceCard(context, service, isFirst: index == 0);
                          },
                        ),
                      ],
                      
                      // Additional options section
                      if (item.details.any((e) => !e.isService)) ...[

                        SizedBox(height: 8.h),
                        ...List.generate(
                          item.details.length,
                          (index) {
                            final service = item.details[index];
                            if (service.isService) return SizedBox();
                            return _buildAdditionalServiceCard(context, service);
                          },
                        ),
                      ],
                      

                      
                      // Address section

                      _buildAddressCard(context, item),
                      
                      // Payment method section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        margin: EdgeInsets.only(bottom: 16.h, top: 8.h),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/payment.svg',
                              height: 20.h,
                              width: 20.w,
                              colorFilter: ColorFilter.mode(
                                context.primaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              LocaleKeys.payment_method.tr(),
                              style: context.semiboldText.copyWith(fontSize: 16.sp),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/svg/cash.svg',
                              height: 20.h,
                              width: 20.w,
                              colorFilter: ColorFilter.mode(
                                context.primaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              item.paymentMethod.toLowerCase() == 'cash' ? "كاش" : "الكتروني", 
                              style: context.mediumText.copyWith(fontSize: 14.sp)
                            ),
                            Spacer(),
                            if (item.isPaid)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  "تم الدفع",
                                  style: context.mediumText.copyWith(
                                    fontSize: 12.sp,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ).withPadding(horizontal: 16.w),
                      
                      // Bill section
                     
                      AgentBillWidget(cubit: cubit),
                    ],
                  ),
                ),
              ),
            );
          } else if (state.getOrderState.isError) {
            return CustomErrorWidget(title: state.msg, onTap: () => cubit.getOrderDetails(widget.id, widget.type));
          }
          return LoadingApp();
        },
      ),
    );
  }
  
  Widget _buildNewServiceCard(BuildContext context, dynamic item, {bool isFirst = false}) {
    return Container(
      width: context.w,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
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
          Expanded(
            child: Row(
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
          ),
        ],
      ).withPadding(start: isFirst ? 15.w : 45.w),
    );
  }

  Widget _buildServiceCard(BuildContext context, dynamic service, {bool isFirst = false}) {
    return Container(
      width: context.w,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
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
                      style: context.mediumText.copyWith(fontSize: 14.sp),
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
      width: context.w,
      margin: EdgeInsets.symmetric(vertical: 4.h),
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
                      style: context.mediumText.copyWith(fontSize: 14.sp),
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
  
  Widget _buildAddressCard(BuildContext context, dynamic item) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "موقع",
            style: context.mediumText.copyWith(fontSize: 14.sp),
          ).withPadding(bottom: 8.h),
          Row(
            children: [
              SvgPicture.asset(
                'assets/svg/location.svg',
                height: 20.h,
                width: 20.h,
                colorFilter: ColorFilter.mode(
                  context.primaryColor,
                  BlendMode.srcIn,
                ),
              ).withPadding(end: 8.w),
              Expanded(
                child: Text(
                  item.address.placeDescription, 
                  style: context.mediumText.copyWith(fontSize: 14.sp)
                ),
              ),
              GestureDetector(
                onTap: () => launchGoogleMaps(item.address.lat, item.address.lng),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LocaleKeys.view.tr(),
                      style: context.mediumText.copyWith(fontSize: 14.sp),
                    ).withPadding(bottom: 4.h),
                    SvgPicture.asset(
                      'assets/svg/eye.svg',
                      height: 16.h,
                      width: 16.w,
                      colorFilter: ColorFilter.mode(
                        context.primaryColorDark,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Merchant address section if available
          if (item.merchentAddress.hasData) ...[
            Divider(height: 32.h, thickness: 1),
            Text(
              LocaleKeys.store_address.tr(),
              style: context.mediumText.copyWith(fontSize: 14.sp),
            ).withPadding(bottom: 8.h),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/location.svg',
                  height: 20.h,
                  width: 20.h,
                  colorFilter: ColorFilter.mode(
                    context.primaryColor,
                    BlendMode.srcIn,
                  ),
                ).withPadding(end: 8.w),
                Expanded(
                  child: Text(
                    item.merchentAddress.placeDescription, 
                    style: context.mediumText.copyWith(fontSize: 14.sp)
                  ),
                ),
                GestureDetector(
                  onTap: () => launchGoogleMaps(item.merchentAddress.lat, item.merchentAddress.lng),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        LocaleKeys.view.tr(),
                        style: context.mediumText.copyWith(fontSize: 14.sp),
                      ).withPadding(bottom: 4.h),
                      SvgPicture.asset(
                        'assets/svg/eye.svg',
                        height: 16.h,
                        width: 16.w,
                        colorFilter: ColorFilter.mode(
                          context.primaryColorDark,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
