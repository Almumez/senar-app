import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/enums.dart';

import '../../controller/upload_attachment/attachment_cubit.dart';
import '../../controller/upload_attachment/attachment_state.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/phoneix.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../core/widgets/pin_code_sheet.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/user_model.dart';
import '../../components/appbar.dart';
import 'controller/edit_profile_cubit.dart';
import 'controller/edit_profile_state.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final cubit = sl<EditProfileCubit>();
  final _buttonStream = StreamController<bool>();

  @override
  void initState() {
    super.initState();
    cubit.name.addListener(() => _buttonStream.add(cubit.canUpdate));
  }

  @override
  void dispose() {
    _buttonStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "تعديل الحساب"),
      body: BlocBuilder<EditProfileCubit, EditProfileState>(
        bloc: cubit,
        builder: (context, state) {
          if (state.profileDataState.isLoading) {
            return const Center(child: LoadingApp());
          }
          
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                
                // الاسم - قابل للتعديل
                AppField(
                  labelText: "اسم",
                  controller: cubit.name
                ).withPadding(bottom: 16.h),
                
                // رقم الهاتف - كنص فقط
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "هاتف",
                      style: context.mediumText.copyWith(fontSize: 14, color: Colors.black.withOpacity(0.7)),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${cubit.phone.text} ${cubit.country?.phoneCode ?? '966'}+",
                            style: context.regularText.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                // الجنس - خيارات
                Text(
                  "جنس",
                  style: context.mediumText.copyWith(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 8.h),
                BlocBuilder<EditProfileCubit, EditProfileState>(
                  bloc: cubit,
                  builder: (context, state) {
                    return Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text("ذكر", style: context.mediumText.copyWith(fontSize: 14)),
                            value: 'male',
                            groupValue: cubit.gender,
                            onChanged: (value) {
                              if (value != null) cubit.setGender(value);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text("أنثى", style: context.mediumText.copyWith(fontSize: 14)),
                            value: 'female',
                            groupValue: cubit.gender,
                            onChanged: (value) {
                              if (value != null) cubit.setGender(value);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                SizedBox(height: 30.h),
                
                // زر التعديل
                StreamBuilder<bool>(
                  stream: _buttonStream.stream,
                  initialData: cubit.canUpdate,
                  builder: (context, snapshot) {
                    return BlocConsumer<EditProfileCubit, EditProfileState>(
                      bloc: cubit,
                      listener: (context, state) {
                        if (state.requestState.isDone) {
                          FlashHelper.showToast(state.msg, type: MessageType.success);
                          _buttonStream.add(cubit.canUpdate);
                        } else if (state.requestState.isError) {
                          FlashHelper.showToast(state.msg);
                        }
                      },
                      builder: (context, state) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: AppBtn(
                            enable: snapshot.data ?? false,
                            title: "تعديل",
                            loading: state.requestState.isLoading,
                            backgroundColor: Colors.transparent,
                            textColor: Colors.white,
                            radius: 30.r,
                            onPressed: () {
                              cubit.updateProfile();
                            },
                          ),
                        );
                      }
                    );
                  }
                ),
                
                SizedBox(height: 30.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
