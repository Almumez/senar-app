import 'dart:async' as timer;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/slider.dart';
import '../../../shared/components/appbar.dart';

class StoryView extends StatefulWidget {
  final List<SliderModel> galleryItems;
  final int initPage;
  const StoryView({
    super.key,
    required this.galleryItems,
    required this.initPage,
  });

  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> with SingleTickerProviderStateMixin {
  late final pageController = PageController(initialPage: widget.initPage);
  late int page = widget.initPage;
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    _controller = AnimationController(
      vsync: this,
      duration: 5.seconds,
    )..forward();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.addListener(() {
      if (_controller.isCompleted) {
        page += 1;
        if (page == widget.galleryItems.length) {
          Navigator.pop(context);
        } else {
          pageController.nextPage(duration: 100.milliseconds, curve: Curves.linear);
          timer.Timer(
            100.milliseconds,
            () => _controller
              ..reset()
              ..animateTo(1),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: LocaleKeys.offers_from_management.tr(),
      ),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _animation.value,
                backgroundColor: '#E9E9E9'.color,
                valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
                minHeight: 2.h,
              ).withPadding(vertical: 12.h);
            },
          ),
          Expanded(
            child: PhotoViewGallery.builder(
              scrollPhysics: const NeverScrollableScrollPhysics(),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.galleryItems[index].image),
                  initialScale: PhotoViewComputedScale.contained * 0.8,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.galleryItems[index].id),
                );
              },
              itemCount: widget.galleryItems.length,
              pageController: pageController,
              backgroundDecoration: BoxDecoration(color: context.scaffoldBackgroundColor),
              onPageChanged: (v) {},
            ),
          ),
        ],
      ),
    );
  }
}
