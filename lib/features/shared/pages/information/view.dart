import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/profile_item.dart';
import '../../components/appbar.dart';

class InformationView extends StatefulWidget {
  const InformationView({super.key});

  @override
  State<InformationView> createState() => _InformationViewState();
}

class _InformationViewState extends State<InformationView> {
  // Elements moved from settings page
  List<ProfileItemModel> items = [
    ProfileItemModel(image: Assets.svg.aboutUs, title: LocaleKeys.about_us, onTap: () => push(NamedRoutes.static, arg: {'type': StaticType.about})),
    ProfileItemModel(image: Assets.svg.terms, title: LocaleKeys.terms_and_conditions, onTap: () => push(NamedRoutes.static, arg: {'type': StaticType.terms})),
    ProfileItemModel(image: Assets.svg.policy, title: LocaleKeys.privacy_policy, onTap: () => push(NamedRoutes.static, arg: {'type': StaticType.privacy})),
    ProfileItemModel(image: Assets.svg.faq, title: LocaleKeys.faq, onTap: () => push(NamedRoutes.faq)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppbar(title: LocaleKeys.information.tr()),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 50.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 32.h,
          children: [
            ...List.generate(
              items.length,
              (index) => InkWell(
                onTap: items[index].onTap,
                child: Row(
                  children: [
                    CustomImage(
                      items[index].image,
                      height: 24.h,
                      width: 24.h,
                      color: items[index].isLogout ? context.errorColor : context.primaryColorDark,
                    ).withPadding(end: 16.w),
                    Expanded(
                      child: Text(
                        items[index].title.tr(),
                        style: context.mediumText.copyWith(fontSize: 16, color: items[index].isLogout ? context.errorColor : null),
                      ),
                    ),
                  ],
                ),
              ).withPadding(bottom: 4.h),
            ),
          ],
        ),
      ),
    );
  }
} 