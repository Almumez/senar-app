import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/appbar.dart';

class RateAgentView extends StatefulWidget {
  final String orderId;
  final Function(RateData) callback;
  const RateAgentView({super.key, required this.orderId, required this.callback});

  @override
  State<RateAgentView> createState() => _RateAgentViewState();
}

class _RateAgentViewState extends State<RateAgentView> {
  final form = GlobalKey<FormState>();
  List<String> ratings = [LocaleKeys.quick_service, LocaleKeys.professional_work, LocaleKeys.dont_like_the_service, LocaleKeys.another_comment];

  final rateData = RateData(rateMsg: "", rating: 3, comment: TextEditingController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.rate_agent.tr()),
      bottomNavigationBar: SafeArea(
        child: AppBtn(
          title: LocaleKeys.send.tr(),
          enable: rateData.rateMsg != '',
          onPressed: () {
            if (form.currentState!.validate()) {
              widget.callback(rateData);
              Navigator.pop(context);
            }
          },
        ).withPadding(horizontal: 16.h, bottom: 16.h),
      ),
      body: Form(
        key: form,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(LocaleKeys.tell_us_your_opinion_about_the_agent.tr(), style: context.regularText).withPadding(top: 10.h),
              RatingBar(
                initialRating: rateData.rating,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                ratingWidget: RatingWidget(
                  full: CustomImage(Assets.svg.starIn, height: 30.h),
                  half: SizedBox.shrink(),
                  empty: CustomImage(Assets.svg.star, height: 30.h),
                ),
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                onRatingUpdate: (rating) {
                  setState(() {
                    rateData.rating = rating;
                  });
                },
              ).center.withPadding(vertical: 25.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ratings.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        rateData.rateMsg = ratings[index];
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
                      child: Row(
                        children: [
                          Expanded(child: Text(ratings[index].tr(), style: context.mediumText.copyWith(fontSize: 16)).withPadding(start: 8.w)),
                          Radio(
                            value: ratings[index],
                            groupValue: rateData.rateMsg,
                            onChanged: (value) {
                              setState(() {
                                rateData.rateMsg = ratings[index];
                              });
                            },
                          )
                        ],
                      ),
                    ).withPadding(bottom: 10.h),
                  );
                },
              ),
              if (rateData.rateMsg == LocaleKeys.another_comment)
                AppField(
                  maxLines: 4,
                  title: LocaleKeys.your_comment.tr(),
                  hintText: LocaleKeys.write_your_opinion.tr(),
                  controller: rateData.comment,
                )
            ],
          ).withPadding(horizontal: 16.w, vertical: 16.h),
        ),
      ),
    );
  }
}

class RateData {
  late String rateMsg;
  late double rating;
  late TextEditingController comment;
  RateData({required this.rateMsg, required this.rating, required this.comment});
}
