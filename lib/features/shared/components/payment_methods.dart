import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/custom_image.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/locale_keys.g.dart';

class PaymentMethodsView extends StatefulWidget {
  final Function(String) callback;

  const PaymentMethodsView({super.key, required this.callback});

  @override
  State<PaymentMethodsView> createState() => _PaymentMethodsViewState();
}

class _PaymentMethodsViewState extends State<PaymentMethodsView> {
  String paymentMethod = '';

  List<PaymentMethods> methods = [
    // PaymentMethods(image: "assets/svg/card.svg", title: "الكتروني", key: "visa"),
    PaymentMethods(image: "assets/svg/cash.svg", title: LocaleKeys.cash.tr(), key: "cash"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/svg/pay.svg',
              height: 20.h,
              width: 20.w,
            ),
            SizedBox(width: 8.w),
            Text("دفع", 
              style: context.mediumText.copyWith(fontSize: 14.sp)
            ),
          ],
        ).withPadding(bottom: 10.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: methods.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                setState(() {
                  paymentMethod = methods[index].key;
                  widget.callback(paymentMethod);
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      methods[index].image,
                      height: 20.h,
                      width: 20.h,
                    ),
                    Expanded(child: Text(methods[index].title, 
                      style: context.mediumText.copyWith(
                        fontSize: 14,
                        color: paymentMethod == methods[index].key 
                          ? context.primaryColor 
                          : Colors.black,
                      )
                    ).withPadding(start: 8.w)),
                    // Custom radio button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          paymentMethod = methods[index].key;
                          widget.callback(paymentMethod);
                        });
                      },
                      child: Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: paymentMethod == methods[index].key
                              ? context.primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: paymentMethod == methods[index].key
                                ? context.primaryColor
                                : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        margin: EdgeInsets.only(right: 8.w),
                      ),
                    ),
                  ],
                ),
              ).withPadding(bottom: 8.h),
            );
          },
        )
      ],
    );
  }
}

class PaymentMethods {
  final String title, image, key;

  PaymentMethods({required this.title, required this.image, required this.key});
}
