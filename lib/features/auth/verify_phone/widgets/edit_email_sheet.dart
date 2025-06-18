import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/country.dart';
import '../controller/verify_phone_bloc.dart';
import '../controller/verify_phone_states.dart';

class EditPhoneSheet extends StatefulWidget {
  final String phone;
  const EditPhoneSheet({super.key, required this.phone});

  @override
  State<EditPhoneSheet> createState() => _EditPhoneSheetState();
}

class _EditPhoneSheetState extends State<EditPhoneSheet> {
  late final newPhone = TextEditingController(text: widget.phone);
  CountryModel? country;
  final form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Set default country code for Saudi Arabia
    country = CountryModel.fromJson({
      'name': 'Saudi Arabia',
      'phone_code': '966',
      'flag': '',
      'short_name': 'SA',
      'phone_limit': 9
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppSheet(
      title: LocaleKeys.edit_phone.tr(),
      children: [
        Form(
          key: form,
          child: AppField(
            controller: newPhone,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            keyboardType: TextInputType.text,
            labelText: "هاتف",
            direction: "right",
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 25.h,
                  width: 1,
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
                  child: Text(
                    textAlign: TextAlign.left,
                    "+966",
                    style: context.regularText.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
        BlocConsumer<VerifyPhoneCubit, VerifyPhoneState>(
          listenWhen: (previous, current) => previous.editEmailState != current.editEmailState,
          buildWhen: (previous, current) => previous.editEmailState != current.editEmailState,
          listener: (context, state) {
            if (state.editEmailState.isDone) {
              Navigator.pop(context, {'phone': newPhone.text});
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: AppBtn(
                loading: state.editEmailState.isLoading,
                title: "تغيير",
                onPressed: () => form.isValid ? context.read<VerifyPhoneCubit>().editEmail('966', newPhone.text) : null,
                backgroundColor: Colors.black,
                textColor: Colors.white,
              ),
            );
          },
        ),
        SizedBox(height: 10.h)
      ],
    );
  }
}
