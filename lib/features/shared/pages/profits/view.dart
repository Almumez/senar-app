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
                  
                  // زر المحفظة
                  if (UserModel.i.isAuth && UserModel.i.accountType == UserType.freeAgent)
                    InkWell(
                      onTap: () => push(NamedRoutes.wallet),
                      child: Container(
                        margin: EdgeInsets.only(top: 24.h, left: 16.h, right: 16.h),
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
