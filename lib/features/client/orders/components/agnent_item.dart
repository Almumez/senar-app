import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../core/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';
import '../../../shared/components/status_container.dart';

class ClientOrderAgentItem extends StatelessWidget {
  const ClientOrderAgentItem({
    super.key,
    required this.data,
  });

  final ClientOrderModel data;

  // Extract first name from full name
  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return "";
    return fullName.split(' ').first;
  }

  // Open WhatsApp chat with the agent
  void _openWhatsApp(String phoneNumber, BuildContext context) async {
    if(phoneNumber.isEmpty) return;
    
    // Format the phone number by removing any spaces or special characters
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check if the number starts with '+' or add the '+' if needed
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = '+$formattedNumber';
    }
    
    // Create the WhatsApp URL
    final Uri whatsappUrl = Uri.parse('https://wa.me/$formattedNumber');
    
    // Launch WhatsApp
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        // Handle case where WhatsApp is not installed
        debugPrint('WhatsApp is not installed');
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  // Make a phone call to the agent
  void _callAgent(String phoneNumber) async {
    if(phoneNumber.isEmpty) {
      debugPrint('Phone number is empty');
      return;
    }
    
    // Direct approach to making a phone call
    final phoneUrl = 'tel:${phoneNumber.trim()}';
    debugPrint('Opening phone URL: $phoneUrl');
    
    try {
      // Skip canLaunchUrl check and launch directly
      await launchUrl(Uri.parse(phoneUrl), mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Error launching phone call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug print the agent phone number
    debugPrint('Agent phone number: ${data.agent.phoneNumber}');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   "• ${data.type != 'maintenance' || data.type != 'supply' ? LocaleKeys.technician.tr() : LocaleKeys.agent.tr()}",
        //   style: context.semiboldText.copyWith(fontSize: 16),
        // ).withPadding(bottom: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.white,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/svg/delivry.svg',
                height: 20.h,
                width: 20.h,
                colorFilter: ColorFilter.mode(
                  context.primaryColor,
                  BlendMode.srcIn,
                ),
              ).withPadding(end: 10.w),
              Expanded(
                child: Text(
                  data.agent.id == '' ? "انتظار" : _getFirstName(data.agent.fullname),
                  style: context.mediumText
                ),
              ),
              // Add chat and call icons when order is accepted and agent is assigned
              if (data.status == 'accepted' && data.agent.id != '')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chat icon
                    InkWell(
                      onTap: () => _openWhatsApp(data.agent.phoneNumber, context),
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
                    ).withPadding(end: 8.w),
                    
                    // Call icon
                    InkWell(
                      onTap: () {
                        final phoneNumber = data.agent.phoneNumber;
                        debugPrint('Tapped call button. Phone: $phoneNumber');
                        
                        if(phoneNumber.isNotEmpty) {
                          final url = 'tel:$phoneNumber';
                          launchUrl(Uri.parse(url));
                        }
                      },
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
                  ],
                ).withPadding(end: 12.w),
              
              if (data.type != 'maintenance' && data.type != 'supply')
                StatusContainer(
                  title: data.statusTrans,
                  color: data.color,
                ).toEnd
            ],
          ),
        ).withPadding(bottom: 16.h),
      ],
    );
  }
}
