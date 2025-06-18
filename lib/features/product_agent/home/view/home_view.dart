import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/user_model.dart';
import '../../orders/widget/product_agent_order_widget.dart';
import '../controller/home_cubit.dart';
import '../controller/home_states.dart';

class ProductAgentHomeView extends StatefulWidget {
  const ProductAgentHomeView({super.key});

  @override
  State<ProductAgentHomeView> createState() => _ProductAgentHomeViewState();
}

class _ProductAgentHomeViewState extends State<ProductAgentHomeView> {
  final cubit = sl<ProductAgentHomeCubit>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    cubit.fetchOrders();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
        cubit.fetchOrders(isPagination: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90.h,
        actions: [
          Text(
            "متاح",
            style: context.semiboldText.copyWith(fontSize: 16),
          ),
          SizedBox(width: 12.w),
          BlocBuilder<ProductAgentHomeCubit, ProductAgentHomeState>(
            bloc: cubit,
            builder: (context, state) {
              return SizedBox(
                height: 32.h,
                child: Switch.adaptive(
                  value: UserModel.i.isAvailable,
                  onChanged: (v) {
                    if (state.acttiveState.isLoading) return;
                    cubit.changeAvailability();
                  },
                ),
              );
            },
          ),
          SizedBox(width: 16.w),
        ],
        leading: CustomImage(
          UserModel.i.image,
          height: 56.w,
          width: 56.w,
          borderRadius: BorderRadius.circular(28.w),
          fit: BoxFit.cover,
        ).withPadding(start: 20.w, vertical: 10.w),
        leadingWidth: 76.w,
        title: Text.rich(
          TextSpan(
            text: "${LocaleKeys.welcome_you.tr()}, ",
            style: context.regularText.copyWith(color: context.hintColor),
            children: [
              TextSpan(text: UserModel.i.fullname, style: context.mediumText.copyWith(fontSize: 16)),
            ],
          ),
        ).withPadding(bottom: 20.w),
      ),
      body: PullToRefresh(
        onRefresh: cubit.reload,
        child: BlocBuilder<ProductAgentHomeCubit, ProductAgentHomeState>(
          bloc: cubit,
          builder: (context, state) {
            if (state.getOrdersState == RequestState.loading && cubit.items.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            if (state.getOrdersState == RequestState.error && cubit.items.isEmpty) {
              return Center(child: CustomErrorWidget(title: state.msg));
            }
            if (state.getOrdersState == RequestState.done && cubit.items.isEmpty) {
              return Center(child: Text(LocaleKeys.no_orders.tr()));
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: cubit.items.length + (state.paginationState == RequestState.loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == cubit.items.length) {
                  return Center(child: CircularProgressIndicator());
                }
                final item = cubit.items[index];
                return ProductAgentOrderWidget(item: item, onBack: () => cubit.reload());
              },
            );
          },
        ),
      ),
    );
  }
}
