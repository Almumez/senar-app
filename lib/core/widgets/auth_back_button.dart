import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/extensions.dart';

class AuthBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const AuthBackButton({
    Key? key,
    this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50.h,
      right: 16.w,
      child: InkWell(
        onTap: onPressed ?? () => Navigator.of(context).pop(),
        child: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Icon(
              Icons.arrow_back,
              color: color ?? Colors.black,
              size: 18.w,
            ),
          ),
        ),
      ),
    );
  }
} 