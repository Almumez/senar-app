// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../features/client/edit_profile/controller/edit_profile_cubit.dart';
// import '../../features/client/edit_profile/controller/edit_profile_state.dart';
// import '../../gen/locale_keys.g.dart';
// import '../../models/country.dart';
// import '../services/service_locator.dart';
// import '../utils/extensions.dart';
// import 'app_btn.dart';
// import 'app_field.dart';
// import 'app_sheet.dart';
// import 'flash_helper.dart';

// class UpdatePhoneSheet extends StatefulWidget {
//   const UpdatePhoneSheet({super.key});

//   @override
//   State<UpdatePhoneSheet> createState() => _UpdatePhoneSheetState();
// }

// class _UpdatePhoneSheetState extends State<UpdatePhoneSheet> {
//   final cubit = sl<EditProfileCubit>();
//   final formKey = GlobalKey<FormState>();
//   @override
//   Widget build(BuildContext context) {
//     return CustomAppSheet(
//       title: LocaleKeys.update_phone.tr(),
//       children: [
//         SizedBox(height: 12.h),
//         Form(
//           key: formKey,
//           child: AppField(
//             controller: cubit.newPhone,
//             labelText: LocaleKeys.phone.tr(),
//             keyboardType: TextInputType.phone,
//             initCountry: CountryModel.fromJson(),
//             onChangeCountry: (country) => cubit.country = country,
//           ),
//         ),
//         SizedBox(height: 12.h),
//         BlocConsumer<EditProfileCubit, EditProfileState>(
//           bloc: cubit,
//           listener: (context, state) {
//             if (state.phoneState.isDone) {
//               Navigator.pop(context);
//             } else if (state.phoneState.isError) {
//               FlashHelper.showToast(state.msg);
//             }
//           },
//           builder: (context, state) {
//             return SafeArea(
//               child: AppBtn(
//                 loading: state.phoneState.isLoading,
//                 title: LocaleKeys.confirm.tr(),
//                 onPressed: () {
//                   if (formKey.currentState?.validate() == true) {
//                     cubit.updatePhone();
//                   }
//                 },
//               ).withPadding(bottom: 12.h),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
