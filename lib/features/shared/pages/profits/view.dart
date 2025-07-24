import 'package:easy_localization/easy_localization.dart' as lang;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading.dart';
import '../../components/appbar.dart';
import '../../../../gen/assets.gen.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../models/user_model.dart';
import '../../../../gen/locale_keys.g.dart';
import 'controller/cubit.dart';
import 'controller/states.dart';

class ProfitsView extends StatefulWidget {
  const ProfitsView({super.key});

  @override
  State<ProfitsView> createState() => _ProfitsViewState();
}

class _ProfitsViewState extends State<ProfitsView> {
  final cubit = sl<ProfitsCubit>();
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
      appBar: CustomAppbar(title: LocaleKeys.profits.tr()),
      body: PullToRefresh(
        onRefresh: _refresh,
        child: BlocBuilder<ProfitsCubit, ProfitsState>(
          bloc: cubit,
          builder: (context, state) {
            if (state.requestState.isError) {
              return Center(child: CustomErrorWidget(title: state.msg));
            } else if (state.requestState.isDone) {
              return SingleChildScrollView(
                child: Column(
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
                    
                    // كارد المبلغ الإجمالي
                    Container(
                      decoration: BoxDecoration(color: context.canvasColor, borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.all(24.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(LocaleKeys.profits_for_that_day.tr(), style: context.regularText.copyWith(fontSize: 16)),
                          CustomImage(Assets.svg.dailyProfits),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: cubit.profits,
                                  style: context.boldText.copyWith(fontSize: 24),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: LocaleKeys.currency.tr(),
                                  style: context.regularText,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ).withPadding(horizontal: 16.h),
                    
                    SizedBox(height: 20.h),
                    
                    // كاردات البيانات الإضافية
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.h),
                      child: Column(
                        children: [
                          // صف أول من الكاردات
                          Row(
                            children: [
                              // كارد عدد الطلبات
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: "عدد الطلبات",
                                  value: cubit.ordersCount.toString(),
                                  icon: Assets.svg.ordersCountIcon,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // كارد عدد الخدمات
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: "عدد الخدمات",
                                  value: cubit.servicesCount.toString(),
                                  icon: Assets.svg.star,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 12.h),
                          
                          // صف ثاني من الكاردات
                          Row(
                            children: [
                              // كارد الخدمات الإضافية
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: "الخدمات الإضافية",
                                  value: cubit.additionalCount.toString(),
                                  icon: Assets.svg.bill,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // كارد عدد العملاء
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: "عدد العملاء",
                                  value: cubit.clientsCount.toString(),
                                  icon: Assets.svg.profileOut,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // زر المحفظة
                    if (UserModel.i.isAuth && UserModel.i.accountType == UserType.freeAgent)
                      InkWell(
                        onTap: () => push(NamedRoutes.wallet),
                        child: Container(
                          margin: EdgeInsets.only(top: 4.h, left: 16.h, right: 16.h),
                          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.h),
                          decoration: BoxDecoration(
                            color: context.canvasColor,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: context.primaryColorLight.withOpacity(0.3), width: 1)
                          ),
                          child: Row(
                            children: [
                              CustomImage(
                                Assets.svg.walletIcon,
                                height: 24.h,
                                width: 24.h,
                                color: context.primaryColorDark,
                              ).withPadding(end: 16.w),
                              Expanded(
                                child: Text(
                                  LocaleKeys.wallet.tr(),
                                  style: context.mediumText.copyWith(fontSize: 16),
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 16.h, color: context.primaryColorDark)
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return Center(child: CustomProgress(size: 30.h));
            }
          },
        ),
      ),
    );
  }
  
  // دالة لإنشاء كارد إحصائي
  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    required String icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: context.canvasColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomImage(
                icon,
                height: 24.h,
                width: 24.h,
                color: context.primaryColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: context.regularText.copyWith(
                    fontSize: 14.sp,

                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: context.boldText.copyWith(
              fontSize: 20.sp,
              color: context.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
