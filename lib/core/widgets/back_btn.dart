import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/extensions.dart';
import 'custom_radius_icon.dart';

class BackWidget extends StatelessWidget {
  final dynamic data;

  final Color? color;
  const BackWidget({
    super.key,
    this.color,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: CustomRadiusIcon(
        onTap: () => Navigator.pop(context, data),
        size: 56.h,
        backgroundColor: color ?? '#f5f5f5'.color,
        // borderColor: context.hoverColor,
        // child: Transform.rotate(
        //   angle: context.locale.languageCode == "en" ? pi : 0,
        //   child: CustomImage(
        //     Assets.svg.backIcon,
        //     height: 24.h,
        //     width: 24.h,
        //   ),
        // ),
      ).toEnd,
    );
  }
}
