import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../gen/locale_keys.g.dart';
import '../routes/app_routes_fun.dart';
import '../utils/extensions.dart';
import 'app_sheet.dart';

class PickImage extends StatefulWidget {
  final String title;
  const PickImage({super.key, required this.title});

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  @override
  Widget build(BuildContext context) {
    return CustomAppSheet(
      title: widget.title,
      children: [
        Row(
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    pick(ImageSource.camera).then((value) {
                      if (value != null) {
                        Navigator.pop(navigator.currentContext!, value);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.h),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.hoverColor),
                    ),
                    child: Icon(
                      CupertinoIcons.camera,
                      color: context.hintColor,
                      size: 32.h,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  LocaleKeys.camera.tr(),
                  style: context.regularText.copyWith(fontSize: 14, color: context.hintColor),
                  textAlign: TextAlign.center,
                )
              ],
            ).withPadding(end: 30.w),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    pick(ImageSource.gallery).then((value) {
                      if (value != null) {
                        Navigator.pop(navigator.currentContext!, value);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.h),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.hoverColor),
                    ),
                    child: Icon(
                      CupertinoIcons.photo,
                      color: context.hintColor,
                      size: 32.h,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  LocaleKeys.gallery.tr(),
                  style: context.regularText.copyWith(fontSize: 14, color: context.hintColor),
                  textAlign: TextAlign.center,
                )
              ],
            ).withPadding(end: 30.w),
          ],
        ),
        SafeArea(child: SizedBox(height: 20.w)),
      ],
    );
  }

  Future<XFile?> pick(ImageSource type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: type);
    return file;
  }
}
