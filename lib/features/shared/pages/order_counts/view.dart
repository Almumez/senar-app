import 'package:easy_localization/easy_localization.dart' as lang;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../components/appbar.dart';
import 'controller/cubit.dart';
import 'controller/states.dart';

class OrdersCountView extends StatefulWidget {
  const OrdersCountView({super.key});

  @override
  State<OrdersCountView> createState() => _OrdersCountViewState();
}

class _OrdersCountViewState extends State<OrdersCountView> {
  final cubit = sl<OrderCountsCubit>();
  DateTime selectedDay = DateTime.now(); // Initially set to today

  void getPreviousDay() {
    setState(() {
      selectedDay = selectedDay.subtract(Duration(days: 1));
      cubit.updateProfits(date: lang.DateFormat('yyyy-MM-dd', 'en').format(selectedDay), type: 'b');
    });
  }

  void getNextDay() {
    setState(() {
      if (!isToday(selectedDay)) {
        selectedDay = selectedDay.add(Duration(days: 1));
        cubit.updateProfits(date: lang.DateFormat('yyyy-MM-dd', 'en').format(selectedDay), type: 'f');
      }
    });
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> _refresh() async {
    await cubit.getProfits(lang.DateFormat('yyyy-MM-dd', 'en').format(selectedDay));
  }

  @override
  void initState() {
    super.initState();
    cubit.getProfits(lang.DateFormat('yyyy-MM-dd', 'en').format(selectedDay));
  }

  @override
  Widget build(BuildContext context) {
    String formattedDay = lang.DateFormat('dd MMM , yyyy', context.locale.languageCode).format(selectedDay);
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.orders_count.tr()),
      body: PullToRefresh(
        onRefresh: _refresh,
        child: BlocBuilder<OrderCountsCubit, OrderCountsState>(
          bloc: cubit,
          builder: (context, state) {
            if (state.requestState.isError) {
              return Center(child: CustomErrorWidget(title: state.msg));
            } else if (state.requestState.isDone) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: (state.updateStatus == RequestState.loading && state.type == 'b') ? CustomProgress(size: 20) : Icon(Icons.arrow_back),
                        onPressed: () {
                          if (state.updateStatus != RequestState.loading) {
                            getPreviousDay();
                          }
                        },
                      ),
                      Text(
                        formattedDay,
                        style: TextStyle(fontSize: 24),
                      ),
                      IconButton(
                        icon: (state.updateStatus == RequestState.loading && state.type == 'f')
                            ? CustomProgress(size: 20)
                            : Icon(Icons.arrow_forward, color: isToday(selectedDay) ? Colors.grey : Colors.black),
                        onPressed: () {
                          if (state.updateStatus != RequestState.loading) {
                            getNextDay();
                          }
                        },
                      ),
                    ],
                  ).withPadding(bottom: 16.h),
                  OrdersCountItem(
                    title: LocaleKeys.order_count_completed_order.tr(),
                    image: Assets.svg.completedOrdersCount,
                    count: state.counts?.completed.toString() ?? '',
                  ).withPadding(horizontal: 16.h, bottom: 20.h),
                  OrdersCountItem(
                    title: LocaleKeys.order_count_current_order.tr(),
                    image: Assets.svg.currentOrdersCount,
                    count: state.counts?.current.toString() ?? '',
                  ).withPadding(horizontal: 16.h, bottom: 20.h),
                  OrdersCountItem(
                    title: LocaleKeys.order_count_rejected_order.tr(),
                    image: Assets.svg.rejectedOrdersCount,
                    count: state.counts?.rejected.toString() ?? '',
                  ).withPadding(horizontal: 16.h, bottom: 20.h),
                ],
              );
            } else {
              return Center(child: CustomProgress(size: 30.h));
            }
          },
        ),
      ),
    );
  }
}

class OrdersCountItem extends StatelessWidget {
  final String title, image, count;
  const OrdersCountItem({
    super.key,
    required this.title,
    required this.image,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: context.canvasColor, borderRadius: BorderRadius.circular(8.r)),
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 35.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: context.regularText.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          CustomImage(
            image,
            width: 56.w,
            height: 56.h,
          ),
          Text('$count ${LocaleKeys.order.tr()}', style: context.mediumText.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}
