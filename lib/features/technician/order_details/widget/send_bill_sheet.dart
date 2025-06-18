import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../gen/locale_keys.g.dart';

class SendBillSheet extends StatefulWidget {
  final String? amount;
  const SendBillSheet({super.key, this.amount});

  @override
  State<SendBillSheet> createState() => _SendBillSheetState();
}

class _SendBillSheetState extends State<SendBillSheet> {
  late final textCtr = TextEditingController(text: widget.amount ?? '');
  final form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: CustomAppSheet(
        title: LocaleKeys.attach_invoice.tr(),
        children: [
          AppField(
            controller: textCtr,
            keyboardType: TextInputType.number,
            labelText: LocaleKeys.amount.tr(),
            validator: (v) {
              final amount = double.tryParse('$v');
              if (amount == null) {
                return LocaleKeys.invalid_value.tr();
              } else if (amount == 0) {
                return LocaleKeys.insufficient_balance.tr();
              }
              return null;
            },
            suffixIcon: SizedBox(
              width: 100.w,
              child: Container(
                decoration: BoxDecoration(color: '#F4F7FC'.color, borderRadius: BorderRadius.circular(4.r)),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Text(
                  LocaleKeys.sar.tr(),
                  style: context.regularText.copyWith(fontSize: 14),
                ),
              ).center,
            ),
          ),
          AppBtn(
            onPressed: () {
              if (form.isValid) {
                Navigator.pop(context, textCtr.text);
              }
            },
            title: LocaleKeys.confirm.tr(),
          )
        ],
      ),
    );
  }
}
