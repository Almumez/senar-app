import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/extensions.dart';

class ClosingTimeWarningDialog extends StatelessWidget {
  final int cancellationTime;
  
  const ClosingTimeWarningDialog({
    Key? key,
    required this.cancellationTime,
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
            // أيقونة التحذير
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber.shade700,
                size: 40.r,
              ),
            ),
            SizedBox(height: 24.h),
            
            // عنوان التحذير
            Text(
              "تنبيه: وقت الخدمة قارب على الانتهاء",
              style: context.boldText.copyWith(
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            
            // وصف التحذير
            Text(
              "نود إعلامك أن وقت الخدمة قارب على الانتهاء. سنحاول العثور على موصل لطلبك خلال $cancellationTime دقيقة، وإلا سيتم إلغاء الطلب تلقائيًا. هل ترغب في المتابعة؟",
              style: context.regularText.copyWith(
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            
            // أزرار الإجراءات
            Row(
              children: [
                // زر الإلغاء
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: context.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: context.primaryColor),
                      ),
                    ),
                    child: Text(
                      "إلغاء",
                      style: context.boldText.copyWith(
                        fontSize: 16.sp,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                
                // زر المتابعة
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
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
          ],
        ),
      ),
    );
  }

  // طريقة ثابتة لعرض الحوار والحصول على استجابة المستخدم
  static Future<bool?> show(BuildContext context, int cancellationTime) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ClosingTimeWarningDialog(cancellationTime: cancellationTime),
    );
  }
} 