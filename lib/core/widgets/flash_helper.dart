import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/assets.gen.dart';

import '../../../core/routes/app_routes_fun.dart';
import '../utils/extensions.dart';
import 'custom_image.dart';

enum MessageType { success, fail, warning }

class FlashHelper {
  static Future<void> showToast(String msg, {int duration = 2, MessageType type = MessageType.fail}) async {
    if (msg.isEmpty) return;
    return showFlash(
      context: navigator.currentContext!,
      builder: (context, controller) {
        return FlashBar(
          controller: controller,
          position: FlashPosition.top,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top + 10.h),
          content: Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9.r),
              color: _getBgColor(type),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 11.h),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Center(
                    child: CustomImage(
                      "assets/images/splash.png",
                      fit: BoxFit.scaleDown,
                      height: 25.h,
                      width: 25.h,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    msg,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    softWrap: true,
                    style: context.regularText.copyWith(fontSize: 16, color: context.primaryColorLight),
                  ),
                ),
              ],
            ),
          ),

        );
      },
      duration: Duration(milliseconds: duration * 1000),
    );
  }

  static Color _getBgColor(MessageType msgType) {
    switch (msgType) {
      case MessageType.success:
        return "#53A653".color;
      case MessageType.warning:
        return "#FFCC00".color;
      default:
        return "#EF233C".color;
    }
  }

  // static String _getToastIcon(MessageType msgType) {
  //   return 'Assets.svg.logo';
  //   // switch (msgType) {
  //   //   case MessageType.success:
  //   //     return Assets.svg.success;

  //   //   case MessageType.warning:
  //   //     return Assets.svg.warning;

  //   //   default:
  //   //     return Assets.svg.error;
  //   // }
  // }
}
