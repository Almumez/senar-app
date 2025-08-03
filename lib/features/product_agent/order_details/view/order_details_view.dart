import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/method.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/custom_image.dart';
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
import '../widget/bill_widget.dart';
import '../widget/product_service_type.dart';

class ProductAgentOrderDetailsView extends StatefulWidget {
  final String id;
  final String type;
  const ProductAgentOrderDetailsView({super.key, required this.id, required this.type});

  @override
  State<ProductAgentOrderDetailsView> createState() => _ProductAgentOrderDetailsViewState();
}

class _ProductAgentOrderDetailsViewState extends State<ProductAgentOrderDetailsView> {
  final cubit = sl<ProductAgentOrderDetailsCubit>();
  @override
  void initState() {
    super.initState();
    cubit.getOrderDetails(widget.id, widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductAgentOrderDetailsCubit, ProductAgentOrderDetailsState>(
      bloc: cubit,
      buildWhen: (previous, current) => previous.getOrderState != current.getOrderState,
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppbar(title: LocaleKeys.order_details.tr()),
          bottomNavigationBar: ProductAgentOrderActions(cubit: cubit),
          body: Builder(
            builder: (context) {
              if (cubit.order != null) {
                var item = cubit.order!;
                return PullToRefresh(
                  onRefresh: () => cubit.getOrderDetails(widget.id, widget.type),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${LocaleKeys.order_number.tr()} : ${cubit.order!.id}", style: context.mediumText.copyWith(fontSize: 20)),
                            StatusContainer(
                              title: cubit.order!.statusTrans,
                              color: cubit.order!.color,
                            )
                          ],
                        ),
                        SizedBox(height: 16.h),
                        ProductAgentServiceType(data: item),
                        AgentOrderClientItem(
                          data: item.client,
                          orderStatus: item.status,
                        ).withPadding(top: 8.h),
                        SizedBox(height: 5.h),
                        Text(
                          "• ${LocaleKeys.addresses.tr()}",
                          style: context.mediumText.copyWith(fontSize: 20),
                        ).withPadding(bottom: 10.h),
                        Container(
                          width: context.w,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: Color(0xfff5f5f5)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.client_location.tr(),
                                style: context.mediumText.copyWith(fontSize: 16),
                              ).withPadding(bottom: 8.h),
                              Row(
                                children: [
                                  CustomImage(
                                    Assets.svg.location,
                                    height: 20.h,
                                    width: 20.h,
                                  ).withPadding(end: 4.w),
                                  Expanded(
                                      child: Text(item.address.placeDescription, style: context.mediumText.copyWith(fontSize: 14)).withPadding(bottom: 5.h)),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => launchGoogleMaps(item.address.lat, item.address.lng),
                                child: Container(
                                  margin: EdgeInsets.only(top: 8.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: '#0404041A'.color.withValues(alpha: .1),
                                  ),
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomImage(
                                        Assets.svg.eye,
                                        height: 20.h,
                                        width: 20.h,
                                        color: context.primaryColorDark,
                                      ).withPadding(end: 4.w),
                                      Text(
                                        LocaleKeys.address_view.tr(),
                                        style: context.mediumText.copyWith(fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              if (item.merchentAddress.hasData) ...[
                                Divider(height: 32.h),
                                Text(
                                  LocaleKeys.store_address.tr(),
                                  style: context.mediumText.copyWith(fontSize: 16),
                                ).withPadding(bottom: 8.h),
                                Row(
                                  children: [
                                    CustomImage(
                                      Assets.svg.location,
                                      height: 20.h,
                                      width: 20.h,
                                    ).withPadding(end: 4.w),
                                    Expanded(
                                        child: Text(item.merchentAddress.placeDescription, style: context.mediumText.copyWith(fontSize: 14))
                                            .withPadding(bottom: 5.h)),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => launchGoogleMaps(item.merchentAddress.lat, item.merchentAddress.lng),
                                  child: Container(
                                    margin: EdgeInsets.only(top: 8.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: '#0404041A'.color.withValues(alpha: .1),
                                    ),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomImage(
                                          Assets.svg.eye,
                                          height: 20.h,
                                          width: 20.h,
                                          color: context.primaryColorDark,
                                        ).withPadding(end: 4.w),
                                        Text(
                                          LocaleKeys.address_view.tr(),
                                          style: context.mediumText.copyWith(fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ).withPadding(bottom: 16),
                        ProductAgentBillWidget(data: item),
                      ],
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
      },
    );
  }
}
