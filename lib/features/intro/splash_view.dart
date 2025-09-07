import 'dart:async';
import 'dart:developer';
import 'dart:io'; // Añadir importación para detectar la plataforma

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';

import '../../core/routes/app_routes_fun.dart';
import '../../core/routes/routes.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/settings_service.dart';
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
  final settingsService = sl<SettingsService>();
  bool _showUpdateDialog = false;
  bool _showServiceClosedDialog = false;

  void navigateUser() {
    if (_showUpdateDialog || _showServiceClosedDialog) return; // لا تنتقل إذا كان هناك تحديث مطلوب أو الخدمة مغلقة

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
    
    // جلب إعدادات النظام والتحقق من الإصدار
    _loadSettingsAndCheckVersion();
    
    super.initState();
  }

  // دالة لجلب الإعدادات والتحقق من الإصدار
  Future<void> _loadSettingsAndCheckVersion() async {
    try {
      // جلب إعدادات النظام
      debugPrint('Loading settings...');
      await settingsService.getSettings();
      debugPrint('Settings loaded successfully');
      
      // التحقق من حالة الخدمة بناءً على متغير is_opened من API
      if (!settingsService.isServiceOpenedFromAPI()) {
        debugPrint('Service is closed, showing service closed dialog');
        setState(() {
          _showServiceClosedDialog = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showServiceClosedPopup();
        });
        return; // لا تتابع إذا كانت الخدمة مغلقة
      }
      
      // التحقق من الإصدار لجميع الأنظمة
      debugPrint('Checking app version...');
      await versionCubit.checkVersion();
      
      // التحقق من وجود تحديث متاح لجميع الأنظمة
      if (versionCubit.state.updateAvailable) {
        debugPrint('Update available, showing update dialog');
        setState(() {
          _showUpdateDialog = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showUpdatePopup();
        });
      } else {
        debugPrint('No update available, proceeding to navigation');
        // الانتقال بعد 3 ثواني إذا لم يكن هناك تحديث مطلوب
        Timer(3.seconds, () => navigateUser());
      }
    } catch (error) {
      debugPrint('Error during initialization: $error');
      // في حالة حدوث خطأ، انتقل بعد 3 ثواني
      Timer(3.seconds, () => navigateUser());
    }
  }

  // فتح متجر التطبيقات
  void _launchAppStore() async {
    // تحديد الرابط حسب نظام التشغيل
    final Uri url;
    
    if (Platform.isIOS) {
      // رابط متجر آبل
      url = Uri.parse('https://apps.apple.com/sa/app/senar-%D8%B3%D9%8A%D9%86%D8%A7%D8%B1/id6741438069');
    } else {
      // رابط متجر جوجل بلاي
      url = Uri.parse('https://play.google.com/store/apps/details?id=com.vcorp.senar');
    }
    
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
          // التحقق من وجود تحديث متاح لجميع الأنظمة
          if (state.requestState.isDone && state.updateAvailable) {
            debugPrint('Update available in BlocListener, showing update dialog');
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
  
  // عرض النافذة المنبثقة لإغلاق الخدمة
  void _showServiceClosedPopup() {
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
                // أيقونة إغلاق الخدمة
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.red,
                    size: 40.r,
                  ),
                ),
                SizedBox(height: 24.h),
                
                // عنوان إغلاق الخدمة
                Text(
                  "الخدمة مغلقة حالياً",
                  style: context.boldText.copyWith(
                    fontSize: 18.sp,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                
                // وصف إغلاق الخدمة مع وقت الفتح
                Text(
                  "نعتذر، الخدمة مغلقة حالياً. ستفتح في الساعة ${settingsService.settings?.closingService.openingTime ?? '08:00'} صباحاً.",
                  style: context.regularText.copyWith(
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                
                // زر المتابعة
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showServiceClosedDialog = false;
                      });
                      Navigator.of(context).pop();
                      // المتابعة إلى التطبيق رغم إغلاق الخدمة
                      navigateUser();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "متابعة",
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
  
  // عرض النافذة المنبثقة للتحديث
  void _showUpdatePopup() {
    final bool isIOS = Platform.isIOS;
    final String title = isIOS ? "تطبيق سنار متاح الآن" : "تحديث جديد متاح";
    final String message = isIOS 
        ? "تطبيق سنار متاح الآن على متجر آبل. انتقل إلى App Store لتحميل التطبيق والاستمتاع بتجربة أفضل."
        : "هناك إصدار جديد من التطبيق متاح الآن. يرجى تحديث التطبيق للاستمتاع بأحدث الميزات والتحسينات.";
    final String buttonText = isIOS ? "الانتقال إلى App Store" : "تحديث الآن";
    
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
                    isIOS ? Icons.apple : Icons.system_update,
                    color: context.primaryColor,
                    size: 40.r,
                  ),
                ),
                SizedBox(height: 24.h),
                
                // عنوان التحديث
                Text(
                  title,
                  style: context.boldText.copyWith(
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                
                // وصف التحديث
                Text(
                  message,
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
                      buttonText,
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
