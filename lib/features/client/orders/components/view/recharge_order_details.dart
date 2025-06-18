import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/utils/extensions.dart';
import '../../../../../core/widgets/custom_image.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../../../models/client_order.dart';
import '../../../../shared/components/status_container.dart';
import '../../../../shared/components/address_item.dart';
import '../bill_widget.dart';
import '../payment_item.dart';

class ClientRechargeOrderDetails extends StatelessWidget {
  const ClientRechargeOrderDetails({
    super.key,
    required this.data,
  });

  final ClientOrderModel data;

  Color get color {
    switch (data.status) {
      case 'pending':
        return "#CE6518".color;
      case 'accepted':
        return "#168836".color;
      default:
        return "#CE6518".color;
    }
  }

  String get title {
    switch (data.status) {
      case 'pending':
        return LocaleKeys.wait_for_agent_to_take_cylinder_and_refill.tr();
      case 'accepted':
        return LocaleKeys.refilling_a_small_cylinder_now_see_cost.tr();
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != '')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 15.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r), 
                border: Border.all(color: context.borderColor.withOpacity(0.3)),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20.h, color: color).withPadding(end: 10.w),
                  Expanded(child: Text(title, style: context.mediumText.copyWith(fontSize: 14.sp, color: color))),
                ],
              ),
            ).withPadding(horizontal: 16.w, bottom: 16.h),
          if (title != '')
            Container(
              height: 10.h,
              color: context.canvasColor,
            ).withPadding(bottom: 16.h),
          
          // إضافة قسم التعليمات في البداية
          _buildInstructionsSection(context).withPadding(horizontal: 16.w, bottom: 25.h),
            
          // Mostrar la sección del agente siempre, solo cambiamos el título
          _buildSectionHeader(context, LocaleKeys.delivery_person.tr(), 'assets/svg/delivery.svg'),
          Container(
            width: context.w,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.white,
            ),
            child: Row(
              children: [
                if (data.agent.id != '')
                  CustomImage(data.agent.image, height: 40.h, width: 40.h, borderRadius: BorderRadius.circular(20.h)).withPadding(end: 10.w),
                Expanded(
                  child: Text(
                    data.agent.id == '' ? LocaleKeys.waiting_for_the_request_to_be_accepted_by_the_nearest_representative.tr() : data.agent.fullname,
                    style: context.mediumText.copyWith(fontSize: 14.sp),
                  ),
                ),
                StatusContainer(
                  title: data.statusTrans,
                  color: data.color,
                ).toEnd
              ],
            ),
          ).withPadding(horizontal: 16.w, bottom: 16.h),
          
          _buildSectionHeader(context, LocaleKeys.service_type.tr(), 'assets/svg/clean.svg'),
          Container(
            width: context.w,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.white,
            ),
            child: Row(
              children: [
                // Mostrar la imagen directamente sin fondo
                CustomImage(
                  Assets.svg.clientRefill, 
                  height: 50.h,
                  width: 50.h,
                  borderRadius: BorderRadius.circular(8.r),
                ).withPadding(end: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.refilling_a_small_cylinder.tr(), 
                        style: context.semiboldText.copyWith(fontSize: 16.sp)
                      ).withPadding(bottom: 8.h),
                      // Eliminar el contenedor de fondo y mostrar solo el texto
                      Text(
                        "${LocaleKeys.quantity.tr()} : ${data.daforaCount}",
                        style: context.mediumText.copyWith(
                          fontSize: 14.sp,
                          color: context.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).withPadding(horizontal: 16.w, bottom: 16.h),
          
          _buildSectionHeader(context, LocaleKeys.site_address.tr(), 'assets/svg/door.svg'),
          _buildComponentCard(
            context, 
            child: OrderDetailsAddressItem(
              title: data.address.placeTitle,
              description: data.address.placeDescription,
            )
          ),
          
          _buildSectionHeader(context, LocaleKeys.payment_method.tr(), 'assets/svg/payment.svg'),
          _buildComponentCard(
            context, 
            child: OrderPaymentItem(data: data)
          ),
          
          _buildSectionHeader(context, LocaleKeys.service_price.tr(), 'assets/svg/price.svg'),
          _buildComponentCard(
            context, 
            child: ClientBillWidget(data: data)
          ),
        ],
      ),
    );
  }
  
  // دالة لإنشاء قسم التعليمات
  Widget _buildInstructionsSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildVerticalInstructionItem(
          context: context,
          svgAsset: 'assets/svg/clean.svg',
          text: "اسطوانة نظيفة",
        ),
        _buildVerticalInstructionItem(
          context: context,
          svgAsset: 'assets/svg/door.svg',
          text: "توصل للباب",
        ),
        _buildVerticalInstructionItem(
          context: context,
          svgAsset: 'assets/svg/warning.svg',
          text: "استلامك مسوؤليتك",
        ),
      ],
    );
  }
  
  // دالة لإنشاء عنصر تعليمة واحدة بشكل عمودي (أيقونة فوق النص)
  Widget _buildVerticalInstructionItem({
    required BuildContext context, 
    required String svgAsset, 
    required String text
  }) {
    // تقسيم النص إلى كلمات
    List<String> words = text.split(' ');
    
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgAsset,
            height: 24.h,
            width: 24.h,
            colorFilter: ColorFilter.mode(
              context.primaryColor,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 8.h),
          Column(
            children: words.map((word) => 
              Text(
                word,
                textAlign: TextAlign.center,
                style: context.mediumText.copyWith(
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              )
            ).toList(),
          ),
        ],
      ),
    );
  }
  
  // Widget para crear encabezados de sección
  Widget _buildSectionHeader(BuildContext context, String title, String svgAsset) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
      child: Row(
        children: [
          SvgPicture.asset(
            svgAsset,
            height: 20.h,
            width: 20.w,
            colorFilter: ColorFilter.mode(
              context.primaryColor,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: context.semiboldText.copyWith(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
  
  // Widget para crear tarjetas de componentes con estilo unificado
  Widget _buildComponentCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h, left: 16.w, right: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: child,
    );
  }
}
