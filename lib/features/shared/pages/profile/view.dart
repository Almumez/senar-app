import 'package:easy_localization/easy_localization.dart' as lang;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/custom_radius_icon.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../models/profile_item.dart';
import '../../../../models/user_model.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/services/location_tracking_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../gen/locale_keys.g.dart';
import 'build_list.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLocationTracking = false;

  @override
  void initState() {
    super.initState();
    _checkLocationTrackingStatus();
  }

  void _checkLocationTrackingStatus() {
    if (UserModel.i.accountType == UserType.freeAgent) {
      _isLocationTracking = sl<LocationTrackingService>().isTracking;
      setState(() {});
    }
  }

  Future<void> _toggleLocationTracking() async {
    final service = sl<LocationTrackingService>();
    
    if (_isLocationTracking) {
      service.stopTracking();
    } else {
      await service.checkAndStart();
    }
    
    _isLocationTracking = service.isTracking;
    setState(() {});
    
    if (_isLocationTracking) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تشغيل خدمة تتبع الموقع'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إيقاف خدمة تتبع الموقع'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  List<ProfileItemModel> _buildItems() {
    final userType = UserModel.i.accountType;
    
    // لطباعة معلومات تصحيح الخطأ
    debugPrint('نوع المستخدم: ${UserModel.i.userType}, isAuth: ${UserModel.i.isAuth}');
    
    // للمستخدم العادي (client)
    if (userType == UserType.client) {
      debugPrint('استخدام قائمة المستخدم العادي');
      return BuildProfileList.clientItems;
    } else if (userType == UserType.agent) {
      return BuildProfileList.agentItems;
    } else if (userType == UserType.freeAgent) {
      return BuildProfileList.freeAgentItems;
    } else if (userType == UserType.productAgent) {
      return BuildProfileList.productAgentItems;
    } else if (userType == UserType.technician) {
      return BuildProfileList.technicianItems;
    } else {
      // في حالة عدم تعرف نوع المستخدم، نستخدم قائمة المستخدم العادي كاحتياط
      debugPrint('نوع المستخدم غير معروف، استخدام قائمة المستخدم العادي');
      return BuildProfileList.clientItems;
    }
  }

  Future<void> _refresh() async {
    // Actualizar los datos del usuario si es necesario
    _checkLocationTrackingStatus();
    setState(() {
      // Actualizar el estado si es necesario
    });
  }

  @override
  Widget build(BuildContext context) {
    // ضمان أن لدينا قائمة العناصر
    final profileItems = _buildItems();
    debugPrint('عدد العناصر في القائمة: ${profileItems.length}');
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(LocaleKeys.profile.tr(), style: context.mediumText.copyWith(fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: PullToRefresh(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // عرض معلومات المستخدم إذا كان مسجل الدخول
              if (UserModel.i.isAuth)
                InkWell(
                  onTap:() => push(NamedRoutes.editProfile),
                  child: Row(
                    children: [
                      CustomRadiusIcon(
                        onTap: () => push(NamedRoutes.editProfile),
                        size: 40.h,
                        child: CustomImage(
                          Assets.images.edit.path,
                          height: 20.h,
                          width: 20.h,
                          color: context.primaryColorDark,
                        ),
                      ).withPadding(end: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(UserModel.i.fullname, style: context.mediumText.copyWith(fontSize: 20)),
                            Text(
                              "+${UserModel.i.phoneCode}-${UserModel.i.phone}",
                              textDirection: TextDirection.ltr,
                              style: context.mediumText.copyWith(fontSize: 14),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ).withPadding(vertical: 15.h),
              
              // عرض عناصر القائمة
              ...List.generate(
                profileItems.length,
                (index) => InkWell(
                  onTap: profileItems[index].onTap,
                  child: Row(
                    children: [
                      CustomRadiusIcon(
                        size: 40.h,
                        backgroundColor: Colors.transparent,
                        child: CustomImage(
                          profileItems[index].image,
                          height: 20.h,
                          width: 20.h,
                          color: profileItems[index].isLogout ? context.errorColor : context.primaryColorDark,
                        ),
                      ).withPadding(end: 8.w),
                      Expanded(
                        child: Text(
                          profileItems[index].title.tr(),
                          style: context.mediumText.copyWith(fontSize: 14, color: profileItems[index].isLogout ? context.errorColor : null),
                        ),
                      ),
                    ],
                  ).withPadding(vertical: 8.h),
                ),
              )
            ],
          ).withPadding(horizontal: 16.w),
        ),
      ),
    );
  }
}
