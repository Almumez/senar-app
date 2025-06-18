import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/extensions.dart';
import 'custom_radius_icon.dart';

class CustomAppSheet extends StatelessWidget {
  final String? title, subtitle;
  final List<Widget>? children;
  final EdgeInsetsGeometry? padding;

  const CustomAppSheet({super.key, this.title, this.children, this.padding, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(32.r))),
        constraints: BoxConstraints(maxHeight: context.h / 1.2),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 15.h, horizontal: 24.w),
                height: 5.h,
                width: 134.w,
                decoration: BoxDecoration(
                  color: '#f5f5f5'.color,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ).center,
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: 24.w,
                    child: CustomRadiusIcon(
                      size: 40.h,
                      borderRadius: BorderRadius.circular(6.r),
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 20.h,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      title ?? "",
                      style: context.mediumText.copyWith(fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ).withPadding(bottom: 0.h),
              Text(
                subtitle ?? "",
                style: context.mediumText.copyWith(fontSize: 14, color: '#f5f5f5'.color),
              ).withPadding(horizontal: 24.w, bottom: 16.h),
              Flexible(
                child: Padding(
                  padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16.h,
                    children: children ?? [],
                  ),
                ),
              ),
              SizedBox(height: 10.h)
            ],
          ),
        ),
      ),
    );
  }
}
