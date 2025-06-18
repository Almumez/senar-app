// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../utils/extensions.dart';

// class CustomSheet extends StatelessWidget {
//   final List<Widget> children;
//   final String title;
//   const CustomSheet({super.key, required this.children, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: context.w,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
//         color: context.primaryColorLight,
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//           child: Column(
//             spacing: 16.h,
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [Text(title, style: context.mediumText.copyWith(fontSize: 20)).withPadding(vertical: 15.h), ...children],
//           ),
//         ),
//       ),
//     );
//   }
// }
