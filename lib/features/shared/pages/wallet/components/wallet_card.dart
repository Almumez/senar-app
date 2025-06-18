import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/extensions.dart';

import '../../../../../core/widgets/custom_image.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../../../models/user_model.dart';

class WalletCard extends StatelessWidget {
  final String amount;
  const WalletCard({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return CustomImage(
      Assets.images.walletCard.path,
      height: 200.h,
      width: context.w,
      fit: BoxFit.fitWidth,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              text: LocaleKeys.welcome.tr(),
              style: context.mediumText.copyWith(color: context.primaryColorLight, fontSize: 14),
              children: [
                TextSpan(text: ' ', style: context.mediumText.copyWith(fontSize: 20)),
                TextSpan(text: UserModel.i.fullname.split(' ')[0], style: context.mediumText.copyWith(color: context.primaryColorLight, fontSize: 20)),
              ],
            ),
          ),
          SizedBox(height: 55.h),
          Text(LocaleKeys.current_balance.tr(), style: context.mediumText.copyWith(color: context.primaryColorLight, fontSize: 14)),
          SizedBox(height: 10.h),
          Text.rich(
            TextSpan(
              text: amount,
              style: context.mediumText.copyWith(color: context.primaryColorLight, fontSize: 20),
              children: [
                TextSpan(text: ' ', style: context.mediumText.copyWith(fontSize: 20)),
                TextSpan(text: LocaleKeys.currency.tr(), style: context.mediumText.copyWith(color: context.primaryColorLight, fontSize: 20)),
              ],
            ),
          ),
        ],
      ).toEnd.withPadding(horizontal: 20.w, vertical: 16.h),
    );
  }
}
