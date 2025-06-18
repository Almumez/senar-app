import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../shared/components/appbar.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';

class ClientChooseDistributingService extends StatefulWidget {
  const ClientChooseDistributingService({super.key});

  @override
  State<ClientChooseDistributingService> createState() => _ClientChooseDistributingServiceState();
}

class _ClientChooseDistributingServiceState extends State<ClientChooseDistributingService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.gas_distribution.tr()),
      body: Column(
        spacing: 24.h,
        children: [
          SizedBox(height: 24.h),
          BannerImage(
            image: context.locale.languageCode == 'en' ? Assets.images.buyCylinderEn.path : Assets.images.buyCylinder.path,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 170.w, child: Text(LocaleKeys.gas_exchange.tr(), style: context.mediumText.copyWith(fontSize: 16), textAlign: TextAlign.center))
                    .withPadding(bottom: 10.h),
                AppBtn(
                  title: LocaleKeys.buy_or_refill_gas.tr(),
                  width: 150.h,
                  height: 40.h,
                  onPressed: () => push(NamedRoutes.buyCylinder),
                )
              ],
            ).withPadding(end: 20.w).toEnd,
          ),
          BannerImage(
            image: context.locale.languageCode == 'en' ? Assets.images.sellCylinderEn.path : Assets.images.sellCylinder.path,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                        width: 147.w,
                        child: Text(LocaleKeys.sell_gas_to_companies.tr(), style: context.mediumText.copyWith(fontSize: 16), textAlign: TextAlign.center))
                    .withPadding(bottom: 10.h),
                AppBtn(
                  title: LocaleKeys.sell_gas.tr(),
                  width: 150.h,
                  height: 40.h,
                )
              ],
            ).withPadding(end: 20.w).toEnd,
          ),
        ],
      ).withPadding(horizontal: 16.w),
    );
  }
}

class BannerImage extends StatelessWidget {
  final String image;

  final Widget child;
  const BannerImage({
    super.key,
    required this.image,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomImage(image,
        height: 156.h,
        width: 361.w,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: context.primaryColorDark.withValues(alpha: .2)),
        child: child);
  }
}
