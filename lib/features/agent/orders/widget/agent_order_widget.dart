import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/agent_order.dart';
import '../../../shared/components/status_container.dart';

class AgentOrderWidget extends StatelessWidget {
  final AgentOrderModel item;
  final Function() onBack;
  const AgentOrderWidget({super.key, required this.item, required this.onBack});

  onTap() {
    push(NamedRoutes.agentShowOrder, arg: {"id": item.id, "type": item.type}).then((_) => onBack());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          color: Color(0xfff5f5f5),
        ),
        child: Column(
          spacing: 5.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        (item.status == 'pending' || item.status == 'completed' || item.status == 'canceled') ? "********" : item.clientName,
                        style: context.mediumText.copyWith(fontSize: 14, color: Colors.black),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          CustomImage(
                            Assets.svg.location,
                            height: 16.sp,
                            width: 16.sp,
                            color: Colors.black,
                          ).withPadding(end: 4.w),
                          Expanded(
                            child: Text(
                              item.address.placeDescription,
                              style: context.mediumText.copyWith(fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(" ${item.id} #", style: context.mediumText.copyWith(fontSize: 14, color: Colors.black)),
                    SizedBox(height: 4.h),
                    if (item.price != 0)
                      Text.rich(
                        TextSpan(children: [
                            TextSpan(
                            text: "${item.price} ",
                            style: context.mediumText.copyWith(fontSize: 14, color: Colors.black),
                          ),
                           TextSpan(
                            text: LocaleKeys.sar.tr(),
                            style: context.mediumText.copyWith(fontSize: 14, color: Colors.black),
                          ),
                        ]),
                      ),
                  ],
                ),
              ],
            ),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: LocaleKeys.the_service.tr(),
                          style: context.mediumText.copyWith(color: Colors.black),
                          children: [
                            TextSpan(
                              text: item.typeTrans,
                              style: context.mediumText.copyWith(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          CustomImage(
                            Assets.svg.calender,
                            height: 16.sp,
                            width: 16.sp,
                            color: Colors.black,
                          ).withPadding(end: 5.w),
                          Text(
                            _formatDate(item.createdAt),
                            style: context.mediumText.copyWith(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          CustomImage(
                            Assets.svg.clock,
                            height: 16.sp,
                            width: 16.sp,
                            color: Colors.black,
                          ).withPadding(start: 12.w, end: 5.w),
                          Text(
                            _formatTime(item.createdAt),
                            style: context.mediumText.copyWith(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 105.w,
                      height: 30.h,
                      child: StatusContainer(
                        title: item.statusTrans,
                        color: item.color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (item.status == 'pending')
                      Container(
                        width: 105.w,
                        height: 30.h,
                        child: AppBtn(
                          onPressed: onTap,
                          height: 30.h,
                          saveArea: false,
                          title: LocaleKeys.accept.tr(),
                          radius: 4.r,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      // If date is in format "2025 Jan 30 - 16:04" or similar
      if (dateStr.contains('-')) {
        String datePart = dateStr.split('-')[0].trim();
        List<String> parts = datePart.split(' ');
        if (parts.length >= 3) {
          int? day = int.tryParse(parts[2]);
          String month = parts[1];
          int? year = int.tryParse(parts[0]);
          
          if (day != null && year != null) {
            int monthNum = _getMonthNumber(month);
            return "${day.toString().padLeft(2, '0')}/${monthNum.toString().padLeft(2, '0')}/$year";
          }
        }
      }
      
      // Try standard parsing
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy', 'en').format(date);
    } catch (e) {
      // Return original format if parsing fails
      return dateStr.contains('-') ? dateStr.split('-')[0].trim() : dateStr;
    }
  }

  String _formatTime(String dateStr) {
    try {
      // If time is in format "2025 Jan 30 - 16:04" or similar
      if (dateStr.contains('-')) {
        String timePart = dateStr.split('-')[1].trim();
        // Check if it's already in hh:mm format
        if (timePart.contains(':')) {
          List<String> timeParts = timePart.split(':');
          int? hour = int.tryParse(timeParts[0]);
          int? minute = int.tryParse(timeParts[1]);
          
          if (hour != null && minute != null) {
            bool isPm = hour >= 12;
            int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
            return "${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}";
          }
        }
        return timePart;
      }
      
      // Try standard parsing
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('hh:mm a', 'en').format(date);
    } catch (e) {
      // Return original format or empty if parsing fails
      return dateStr.contains('-') ? dateStr.split('-')[1].trim() : '';
    }
  }
  
  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthName] ?? 1;
  }
}
