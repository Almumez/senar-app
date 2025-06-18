// import '../utils/extensions.dart';
// import 'app_sheet.dart';
// import '../../gen/locale_keys.g.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../models/reasone.dart';
// import 'app_btn.dart';
// import 'app_field.dart';

// class SelectReasoneSheet extends StatefulWidget {
//   final String title;
//   final String? btnText;
//   final List<ReasonModel> items;

//   const SelectReasoneSheet({super.key, required this.title, required this.items, this.btnText});

//   @override
//   State<SelectReasoneSheet> createState() => _SelectReasoneSheetState();
// }

// class _SelectReasoneSheetState extends State<SelectReasoneSheet> {
//   ReasonModel? selecteIndex;
//   final text = TextEditingController();
//   bool showInput = false;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: AlignmentDirectional.bottomCenter,
//       children: [
//         CustomAppSheet(
//           title: widget.title,
//           children: [
//             Flexible(
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     ...List.generate(
//                       widget.items.length,
//                       (index) => GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             selecteIndex = widget.items[index];

//                             showInput = false;
//                           });
//                         },
//                         child: Container(
//                           margin: EdgeInsets.symmetric(vertical: 6.h),
//                           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(100.r),
//                             color: context.primaryColorLight,
//                             border: Border.all(color: context.hoverColor),
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   widget.items[index].name,
//                                   style: context.mediumText.copyWith(fontSize: 14),
//                                 ).withPadding(horizontal: 8.w),
//                               ),
//                               SizedBox(
//                                 height: 18.h,
//                                 width: 18.h,
//                                 child: Radio(
//                                   activeColor: context.primaryColor,
//                                   value: widget.items[index] == selecteIndex,
//                                   groupValue: true,
//                                   onChanged: (value) {
//                                     setState(() {
//                                       selecteIndex = widget.items[index];
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selecteIndex = null;
//                           showInput = true;
//                         });
//                       },
//                       child: Container(
//                         margin: EdgeInsets.symmetric(vertical: 6.h),
//                         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(100.r),
//                           color: context.primaryColorLight,
//                           border: Border.all(color: context.hoverColor),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 LocaleKeys.another_raeson.tr(),
//                                 style: context.mediumText.copyWith(fontSize: 14),
//                               ).withPadding(horizontal: 8.w),
//                             ),
//                             SizedBox(
//                               height: 18.h,
//                               width: 18.h,
//                               child: Radio(
//                                 activeColor: context.primaryColor,
//                                 value: showInput,
//                                 groupValue: true,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     selecteIndex = null;
//                                     showInput = true;
//                                   });
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     if (showInput) ...[
//                       Text(
//                         LocaleKeys.another_raeson.tr(),
//                         style: context.mediumText.copyWith(fontSize: 16),
//                       ).withPadding(vertical: 12.h),
//                       AppField(
//                         controller: text,
//                         hintText: LocaleKeys.write_the_reason_here.tr(),
//                         maxLines: 3,
//                       ),
//                     ],
//                     SizedBox(height: 20.h)
//                   ],
//                 ),
//               ),
//             ),
//            SizedBox(height: 50.h)
//           ],
//         ),
//         AppBtn(
//           onPressed: () => Navigator.pop(context, {
//             'id': selecteIndex?.id,
//             if (showInput) 'text': text.text,
//           }),
//           title: widget.btnText ?? LocaleKeys.confirm.tr(),
//         ).withPadding(vertical: 10.h,horizontal: 24.w)
//       ],
//     );
//   }
// }
