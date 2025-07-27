import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/extensions.dart';

class ServiceClosedDialog extends StatelessWidget {
  final String openingTime;
  
  const ServiceClosedDialog({
    Key? key,
    required this.openingTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة الإغلاق
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time,
                color: context.primaryColor,
                size: 40.r,
              ),
            ),
            SizedBox(height: 24.h),
            
            // عنوان الإغلاق
            Text(
              "الخدمة مغلقة حالياً",
              style: context.boldText.copyWith(
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            
            // وصف الإغلاق
            Text(
              "عذراً، الخدمة غير متاحة في الوقت الحالي. سيتم إعادة فتح الخدمة في الساعة $openingTime.",
              style: context.regularText.copyWith(
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            
            // زر الموافقة
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "حسناً",
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
    );
  }

  // Método estático para mostrar el diálogo
  static Future<void> show(BuildContext context, String openingTime) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ServiceClosedDialog(openingTime: openingTime),
    );
  }
} 