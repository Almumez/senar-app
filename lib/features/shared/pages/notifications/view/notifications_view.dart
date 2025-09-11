import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/widgets/confirmation_sheet.dart';
import '../../../../../core/widgets/successfully_sheet.dart';

import '../../../../../core/routes/app_routes_fun.dart';
import '../../../../../core/routes/routes.dart';
import '../../../../../core/services/service_locator.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/utils/pull_to_refresh.dart';
import '../../../../../core/widgets/app_btn.dart';
import '../../../../../core/widgets/custom_image.dart';
import '../../../../../core/widgets/custom_radius_icon.dart';
import '../../../../../core/widgets/error_widget.dart';
import '../../../../../core/widgets/loading.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../../../models/user_model.dart';
import '../../../components/appbar.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final cubit = sl<NotificationsCubit>();

  @override
  void initState() {
    super.initState();
    if (UserModel.i.isAuth) {
      cubit.getNotifications();
    }
  }

  Future<void> _refresh() async {
    await cubit.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        actions: [
          BlocConsumer<NotificationsCubit, NotificationsState>(
            bloc: cubit,
            listenWhen: (previous, current) => previous.deleteAllNotifications != current.deleteAllNotifications,
            listener: (context, state) {
              if (state.deleteAllNotifications.isDone) {
                showModalBottomSheet(
                  context: context,
                  isDismissible: false,
                  enableDrag: false,
                  builder: (context) => SuccessfullySheet(
                    title: LocaleKeys.notification_deleted_successfully.tr(),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (UserModel.i.isAuth && cubit.notifications.isNotEmpty) {
                return CustomRadiusIcon(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (c) => ConfirmationSheet(
                        title: LocaleKeys.delete_notifications.tr(),
                        subTitle: LocaleKeys.confirmation_message.tr(),
                      ),
                    ).then((v) {
                      if (v == true) {
                        cubit.deleteAll();
                      }
                    });
                  },
                  size: 50.sp,
                  backgroundColor: '#F4F4F8'.color,
                  child: CustomImage(
                    Assets.svg.deleteNotifications,
                    height: 24.sp,
                    width: 24.sp,
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ).withPadding(horizontal: 16.w),
        ],
        title: LocaleKeys.notifications.tr(),
        withBack: false,
      ),
      body: !UserModel.i.isAuth 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: AppBtn(
                    title: LocaleKeys.login.tr(),
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                    radius: 30.r,
                    onPressed: () => push(NamedRoutes.login),
                  ),
                ),
              ],
            ),
          )
        : PullToRefresh(
            onRefresh: _refresh,
            child: BlocBuilder<NotificationsCubit, NotificationsState>(
              bloc: cubit,
              buildWhen: (previous, current) => previous.getNotifications != current.getNotifications,
              builder: (context, state) {
                if (cubit.notifications.isNotEmpty) {
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                    controller: cubit.scrollController,
                    itemCount: cubit.notifications.length,
                    itemBuilder: (context, index) {
                      final item = cubit.notifications[index];
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          color:  Color(0xfff5f5f5),
                        ),
                        child: Row(
                          children: [
                            CustomRadiusIcon(
                              borderRadius: BorderRadius.circular(10.r),
                              backgroundColor: '#ffffff'.color,
                              size: 48.sp,
                              child: CustomImage(
                                Assets.svg.notificationsIn,
                                height: 28.sp,
                                width: 28.sp,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.body,
                                    style: context.mediumText.copyWith(fontSize: 14.sp, color: Colors.black),
                                  ),
                                ],
                              ).withPadding(horizontal: 15.w),
                            ),
                            CustomRadiusIcon(
                              size: 32.sp,
                              onTap: () => cubit.deleteItem(item.id),
                              backgroundColor: '#ffffff'.color,
                              child: CustomImage(
                                Assets.svg.deleteNotifications,
                                height: 16.sp,
                                width: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => SizedBox(height: 16.h),
                  );
                } else if (state.getNotifications.isDone) {
                  return CustomErrorWidget(
                    title: LocaleKeys.notifications.tr(),
                    subtitle: LocaleKeys.no_notifications.tr(),
                    errType: ErrorType.empty,
                  );
                } else if (state.getNotifications.isError) {
                  return CustomErrorWidget(
                    title: LocaleKeys.notifications.tr(),
                    subtitle: state.msg,
                    errType: state.errorType,
                  );
                } else {
                  return LoadingApp();
                }
              },
            ),
          ),
      bottomNavigationBar: UserModel.i.isAuth ? BlocBuilder<NotificationsCubit, NotificationsState>(
        bloc: cubit,
        buildWhen: (previous, current) => previous.getNotificationsPaging != current.getNotificationsPaging,
        builder: (context, state) => PaginationLoading(isLoading: state.getNotificationsPaging.isLoading),
      ) : null,
    );
  }
}
