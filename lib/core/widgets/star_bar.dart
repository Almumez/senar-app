// import '../utils/extensions.dart';
// import 'custom_image.dart';
// import '../../gen/assets.gen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class CustomStarBar extends StatelessWidget {
//   final double initialRating;
//   final double? size;
//   final EdgeInsetsGeometry? itemPadding;
//   final void Function(double)? onRatingUpdate;
//   const CustomStarBar({super.key, required this.initialRating, this.itemPadding, this.onRatingUpdate, this.size});

//   @override
//   Widget build(BuildContext context) {
//     return RatingBar(
//       initialRating: initialRating,
//       direction: Axis.horizontal,
//       allowHalfRating: false,
//       itemCount: 5,
//       itemSize: size ?? 40.h,
//       ignoreGestures: onRatingUpdate == null,
//       glowColor: Colors.white,
//       ratingWidget: RatingWidget(
//         empty: CustomImage(
//           Assets.svg.starOutline,
//           height: size,
//           width: size,
//           color: context.indicatorColor,
//         ),
//         half: CustomImage(
//           Assets.svg.starOutline,
//           height: size,
//           width: size,
//           color: context.indicatorColor,
//         ),
//         full: CustomImage(
//           Assets.svg.star,
//           height: size,
//           width: size,
//           color: context.indicatorColor,
//         ),
//       ),
//       itemPadding: itemPadding ?? EdgeInsets.zero,
//       onRatingUpdate: (rating) {
//         onRatingUpdate?.call(rating);
//       },
//     );
//   }
// }
