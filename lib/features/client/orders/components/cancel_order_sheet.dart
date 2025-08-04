import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../gen/locale_keys.g.dart';

class CancelOrderSheet extends StatefulWidget {
  final TextEditingController reasonController;
  
  const CancelOrderSheet({
    super.key,
    required this.reasonController,
  });

  @override
  State<CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<CancelOrderSheet> {
  final formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return CustomAppSheet(
      title: "سبب الإلغاء",
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.h),
              AppField(
                controller: widget.reasonController,
                labelText: "سبب الإلغاء",

                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "الرجاء كتابة سبب الإلغاء";
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              AppBtn(
                title: LocaleKeys.confirm.tr(),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ],
    );
  }
} 