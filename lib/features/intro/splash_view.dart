import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';

import '../../core/routes/app_routes_fun.dart';
import '../../core/routes/routes.dart';
import '../../core/services/service_locator.dart';
import '../../core/utils/enums.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/custom_image.dart';
import '../../core/widgets/loading.dart';
import '../../gen/assets.gen.dart';
import '../../gen/locale_keys.g.dart';
import 'controller/version_cubit.dart';
import 'controller/version_state.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final versionCubit = sl<VersionCubit>();
  bool _showUpdateDialog = false;

  void navigateUser() {
    if (_showUpdateDialog) return; // لا تنتقل إذا كان هناك تحديث مطلوب

    if (!UserModel.i.isAuth) {
      replacement(NamedRoutes.onboarding);
      return;
    }
    if (!UserModel.i.isActive) {
      replacement(NamedRoutes.login);
      return;
    }

    if (UserModel.i.accountType != UserType.freeAgent) {
      replacement(NamedRoutes.navbar);
      return;
    }

    if (!UserModel.i.completeRegistration) {
      replacement(NamedRoutes.login);
      return;
    }

    if (!UserModel.i.adminApproved) {
      replacement(NamedRoutes.successCompleteData);
      return;
    }

    replacement(NamedRoutes.navbar);
  }

  @override
  void initState() {
    log(UserModel.i.token);
    
    // التحقق من الإصدار
    versionCubit.checkVersion().then((_) {
      if (versionCubit.state.updateAvailable) {
        setState(() {
          _showUpdateDialog = true;
        });
      } else {
        // الانتقال بعد 3 ثواني إذا لم يكن هناك تحديث مطلوب
        Timer(3.seconds, () => navigateUser());
      }
    }).catchError((error) {
      // في حالة حدوث خطأ، انتقل بعد 3 ثواني
      Timer(3.seconds, () => navigateUser());
    });
    
    super.initState();
  }

  // فتح متجر التطبيقات
  void _launchAppStore() async {
    // رابط متجر جوجل بلاي
    final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.senar.gasapp');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<VersionCubit, VersionState>(
        bloc: versionCubit,
        listener: (context, state) {
          if (state.requestState.isDone && state.updateAvailable) {
            // عرض النافذة المنبثقة للتحديث
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showUpdatePopup();
            });
          }
        },
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: CustomImage(
              'assets/images/splash.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
  
  // عرض النافذة المنبثقة للتحديث
  void _showUpdatePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // منع الإغلاق بزر الرجوع
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // أيقونة التحديث
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update,
                    color: context.primaryColor,
                    size: 40.r,
                  ),
                ),
                SizedBox(height: 24.h),
                
                // عنوان التحديث
                Text(
                  "تحديث جديد متاح",
                  style: context.boldText.copyWith(
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                
                // وصف التحديث
                Text(
                  "هناك إصدار جديد من التطبيق متاح الآن. يرجى تحديث التطبيق للاستمتاع بأحدث الميزات والتحسينات.",
                  style: context.regularText.copyWith(
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                
                // زر التحديث
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _launchAppStore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "تحديث الآن",
                      style: context.boldText.copyWith(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
