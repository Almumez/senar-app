import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';

class RequestGasWidget extends StatelessWidget {
  const RequestGasWidget({
    super.key,
  });

  void _showDistributionOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            top: 20.h,
            right: 16.w,
            left: 16.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // شريط سحب في أعلى البوتوم شيت
                Container(
                  width: 50.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ).center.withPadding(bottom: 25.h),
                
                // عنوان البوتوم شيت
                Text(
                  LocaleKeys.distribution.tr(),
                  style: context.mediumText.copyWith(
                    fontSize: 14.sp,
                    color: Colors.black,
                  ),
                ).withPadding(bottom: 24.h),
                
                // خيار شراء/إعادة تعبئة أسطوانة
                _buildBannerImage(
                  context: context,
                  image: context.locale.languageCode == 'en' 
                    ? Assets.images.buyCylinderEn.path 
                    : Assets.images.buyCylinder.path,
                  title: LocaleKeys.gas_exchange.tr(),
                  buttonText: LocaleKeys.buy_or_refill_gas.tr(),
                  onPressed: () {
                    Navigator.pop(context);
                    push(NamedRoutes.buyCylinder);
                  },
                ).withPadding(bottom: 20.h),
                
                // Two square boxes side by side
                Row(
                  children: [
                    // First box - Sell Gas Cylinders
                    Expanded(
                      child: _buildSquareOption(
                        context: context,
                        title: "بيع",
                        onPressed: () {
                          Navigator.pop(context);
                          // Add a small delay to ensure the bottom sheet is closed before showing popup
                          Future.delayed(Duration(milliseconds: 300), () {
                            _showComingSoonPopup(context, "بيع");
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // Second box - Wholesale
                    Expanded(
                      child: _buildSquareOption(
                        context: context,
                        title: "جملة",
                        onPressed: () {
                          Navigator.pop(context);
                          // Add a small delay to ensure the bottom sheet is closed before showing popup
                          Future.delayed(Duration(milliseconds: 300), () {
                            _showComingSoonPopup(context, "جملة");
                          });
                        },
                      ),
                    ),
                  ],
                ).withPadding(bottom: 20.h),

              ],
            ),
          ),
        );
      },
    );
  }

  // عرض نافذة "قريباً"
  void _showComingSoonPopup(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          backgroundColor: Colors.white,
          content: Container(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: "#d68243".color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: "#d68243".color,
                    size: 35.r,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  LocaleKeys.coming_soon.tr(),
                  style: context.mediumText.copyWith(
                    fontSize: 14.sp,
                    color: "#090909".color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.h),
                Text(
                  LocaleKeys.service_not_available.tr(),
                  style: context.mediumText.copyWith(
                    fontSize: 14.sp,
                    color: "#9E968F".color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: "#090909".color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      minimumSize: Size(double.infinity, 50.h),
                    ),
                    child: Text(
                      LocaleKeys.ok.tr(),
                      style: context.mediumText.copyWith(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // بناء صورة البانر مع النص والزر
  Widget _buildBannerImage({
    required BuildContext context,
    required String image,
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        color: Color(0xfff5f5f5),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(25.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.mediumText.copyWith(
                        fontSize: 14.sp,
                        color: Colors.black,
                      ),
                    ).withPadding(start: 25.h) ,
                    SizedBox(height: 15.h),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
                      child: Center(
                        child: Text(
                          buttonText,
                          style: context.mediumText.copyWith(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.white,
              child: Image.asset(
                "assets/images/tree_gas.png",
                height: 75.h,
                width: 75.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 15.w),
          ],
        ),
      ),
    );
  }

  // New method to build square option boxes
  Widget _buildSquareOption({
    required BuildContext context,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        color: Color(0xfff5f5f5),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25.r),
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: context.mediumText.copyWith(
                    fontSize: 14.sp,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 15.h),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                  child: Center(
                    child: Text(
                      LocaleKeys.coming_soon.tr(),
                      style: context.mediumText.copyWith(
                        fontSize: 14.sp,
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

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.locale.languageCode == 'en';
    
    return InkWell(
      onTap: () => _showDistributionOptionsBottomSheet(context),
      child: Container(
        height: 140.h,
        width: 353.w,
        decoration: BoxDecoration(
          color: Color(0xfff5f5f5),
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.distribution.tr(),
              style: context.mediumText.copyWith(
                fontSize: 20.sp,
                color: Colors.black,
              ),
            ).withPadding(start: 10.w),
            CircleAvatar(
              radius: 60.r,
              backgroundColor: Colors.white,
              child: Image.asset(
                height: 200.h,
                width: 200.w,
                isEnglish
                    ? Assets.images.homeDistributionEn.path
                    : Assets.images.homeDistribution.path,
              ),
            )
          ],
        ),
      ),
    );
  }
}


// {"address_id":"56","payment_method":"cash","fiber_cylinder_buying":1}
// {"address_id":"56","payment_method":"cash","gas_connection ":1}
// {"address_id":"56","payment_method":"visa","gas_regulator":1}