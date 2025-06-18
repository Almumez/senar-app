import 'package:easy_localization/easy_localization.dart';

import '../../gen/locale_keys.g.dart';
import '../utils/enums.dart';
import '../utils/extensions.dart';
import 'app_btn.dart';
import 'custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomErrorWidget extends StatelessWidget {
  final String title;
  final String? subtitle, image;
  final ErrorType? errType;
  final void Function()? onTap;
  final String? btnTitle;
  final double? height;
  final EdgeInsetsGeometry? padding;
  const CustomErrorWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.image,
    this.errType,
    this.height,
    this.padding,
    this.onTap,
    this.btnTitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding ?? EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (img != null) ...[
              CustomImage(
                img,
                height: 180.h,
              ).center,
              SizedBox(height: 24.h),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.mediumText.copyWith(fontSize: 20.sp),
            ),
            SizedBox(height: 8.h),
            if (subtitle?.isNotEmpty == true)
              Text(
                subtitle ?? '',
                textAlign: TextAlign.center,
                style: context.mediumText.copyWith(fontSize: 14.sp, color: Colors.black),
              ),
            if (onTap != null) ...[
              SizedBox(height: 12.h),
              AppBtn(
                title: btnTitle ?? LocaleKeys.try_again.tr(),
                onPressed: onTap,
              ),
            ]
          ],
        ).withPadding(horizontal: 24.w),
      ),
    );
  }

  String? get img {
    if (image?.isNotEmpty == true) {
      return image;
    }
    // else if (errorStatus == 0) {
    //   return Assets.svg.noInternet;
    // } else if (errorStatus == 1) {
    //   return Assets.svg.emptyFavorite;
    // } else if (errorStatus == 2) {
    //   return Assets.svg.serverError;
    // }
    return null;
  }
}
