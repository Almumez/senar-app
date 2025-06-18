import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/assets.gen.dart';
import '../utils/extensions.dart';
import 'custom_image.dart';

class SuccessfullySheet extends StatelessWidget {
  final String title;
  final String? subTitle;
  final Function? onLottieFinish;

  const SuccessfullySheet({
    super.key,
    required this.title,
    this.onLottieFinish,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        width: context.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          color: context.primaryColorLight,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5.h,
                width: 134.w,
                margin: EdgeInsets.only(top: 21.h, bottom: 8.h),
                decoration: BoxDecoration(color: context.hintColor, borderRadius: BorderRadius.circular(20.r)),
              ),
              CustomImage(
                Assets.lottie.successfully,
                onFinishLottie: () {
                  Navigator.pop(context);
                  onLottieFinish?.call();
                },
                height: 160.h,
              ).withPadding(top: 40.h, bottom: 16.h),
              Text(
                title,
                style: context.mediumText.copyWith(fontSize: 20.sp, color: Colors.black),
                textAlign: TextAlign.center,
              ).withPadding(top: 10.h, bottom: 10.h),
              if (subTitle != null)
                Text(
                  subTitle!,
                  style: context.mediumText.copyWith(fontSize: 14.sp, color: Colors.black),
                  textAlign: TextAlign.center,
                ).withPadding(top: 10.h, bottom: 10.h),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
