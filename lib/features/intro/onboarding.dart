import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/routes/app_routes_fun.dart';
import '../../core/routes/routes.dart';
import '../../core/widgets/app_btn.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/custom_image.dart';
import '../../gen/assets.gen.dart';
import '../../gen/locale_keys.g.dart';

import '../../components/appbar.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // شعار كبير في الوسط
                  Image.asset(
                    'assets/images/splash.png',
                    height: 150.h,
                  ),
                  SizedBox(height: 80.h),
                  // مرحباً بك بخط كبير
                  Text(
                    LocaleKeys.welcome_you.tr(),
                    style: context.mediumText.copyWith(
                      fontSize: 20.sp,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // الأزرار في الأسفل
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // زر ابدأ الآن بدون ظل
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: AppBtn(
                      title: LocaleKeys.star_now.tr(),
                      backgroundColor: Colors.transparent,
                      textColor: Colors.white,
                      onPressed: () => replacement(NamedRoutes.login),
                      radius: 30.r,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // زر الدخول كضيف بحدود بدون ظل
                  AppBtn(
                    title: LocaleKeys.login_as_guest.tr(),
                    backgroundColor: Colors.transparent,
                    textColor: Colors.black,
                    onPressed: () => pushAndRemoveUntil(NamedRoutes.navbar),
                    radius: 30.r,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
