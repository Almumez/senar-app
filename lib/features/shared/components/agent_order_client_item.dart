import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../gen/assets.gen.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/widgets/custom_image.dart';
import '../../../gen/locale_keys.g.dart';
import '../../../models/client.dart';
import 'package:url_launcher/url_launcher.dart';

void _callClient(String phoneCode, String phone) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: '$phoneCode$phone');
  print(phoneUri);
  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    throw 'Could not launch $phoneUri';
  }
}

class AgentOrderClientItem extends StatelessWidget {
  const AgentOrderClientItem({
    super.key,
    required this.data,
    this.orderStatus,
  });

  final ClientModel data;
  final String? orderStatus;

  @override
  Widget build(BuildContext context) {
    if (data.id == '') {
      return const SizedBox.shrink();
    }
    
    // Verificar si el estado del pedido es "pending"
    final bool isPending = orderStatus == 'pending';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.white,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/svg/profile_out.svg',
                height: 20.h,
                width: 20.h,
                colorFilter: ColorFilter.mode(
                  context.primaryColor,
                  BlendMode.srcIn,
                ),
              ).withPadding(end: 10.w),
              Expanded(
                child: Text(
                  data.fullname.split(' ')[0],
                  style: context.mediumText.copyWith(fontSize: 14.sp),
                ),
              ),
              // Solo mostrar los botones de llamada y chat si el estado NO es "pending"
              if (!isPending) ...[
                // Call icon
                InkWell(
                  onTap: () => _callClient(data.phoneCode, data.phone),
                  child: Container(
                    padding: EdgeInsets.all(8.h),
                    decoration: BoxDecoration(
                      color: Color(0xfff5f5f5),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      'assets/svg/call.svg',
                      height: 20.h,
                      width: 20.w,
                      colorFilter: ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Chat icon
                InkWell(
                  onTap: () {
                    // Add chat functionality here
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.h),
                    decoration: BoxDecoration(
                      color: Color(0xfff5f5f5),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      'assets/svg/chatbox.svg',
                      height: 20.h,
                      width: 20.w,
                      colorFilter: ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ).withPadding(bottom: 16.h),
      ],
    );
  }
}
