import 'dart:async';
import 'dart:io';

// import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gasapp/core/widgets/base_shimmer.dart';
import 'package:lottie/lottie.dart';

import '../utils/extensions.dart';
class CustomImage extends StatefulWidget {
  final double? height, width;
  final String? url;
  final bool isFile;
  final BoxFit? fit;
  final BoxBorder? border;
  final Widget? child;
  final Function? onFinishLottie;
  final BoxConstraints? constraints;
  final Color? blurColor, color, backgroundColor;
  final BorderRadiusGeometry? borderRadius;

  const CustomImage(this.url,
      {super.key,
      this.height,
      this.width,
      this.isFile = false,
      this.borderRadius,
      this.fit,
      this.color,
      this.backgroundColor,
      this.border,
      this.child,
      this.blurColor,
      this.onFinishLottie,
      this.constraints});

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.url == null ? null : ValueKey(widget.url),
      height: widget.height,
      constraints: widget.constraints,
      width: widget.width,
      // alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: widget.borderRadius ?? BorderRadius.zero, color: widget.backgroundColor, border: widget.border),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Stack(
          children: [
            (() {
              if (widget.url?.isNotEmpty != true) {
                return _errorWidget(context);
              } else if (widget.url?.startsWith("http") == true) {
                return CashNetworkImage(
                  widget.url!,
                  height: widget.height,
                  width: widget.width,
                  fit: widget.fit ?? BoxFit.contain,
                  color: widget.color,
                  borderRadius: widget.borderRadius,
                );
              } else if (widget.url?.split(".").last.toLowerCase() == "svg") {
                return SvgPicture.asset(
                  widget.url!,
                  height: widget.height,
                  width: widget.width,
                  fit: widget.fit ?? BoxFit.contain,
                  colorFilter: widget.color != null ? ColorFilter.mode(widget.color!, BlendMode.srcIn) : null,
                );
              } else if (widget.url?.split(".").last.toLowerCase() == "json") {
                return CustomLottie(
                  widget.url!,
                  height: widget.height,
                  width: widget.width,
                  fit: widget.fit ?? BoxFit.contain,
                  onFinish: widget.onFinishLottie,
                );
              } else if (widget.isFile) {
                return Image.file(
                  File(widget.url!),
                  height: widget.height,
                  width: widget.width,
                  fit: widget.fit ?? BoxFit.contain,
                  color: widget.color,
                  errorBuilder: (context, error, stackTrace) => _errorWidget(context),
                );
              } else {
                return Image.asset(
                  widget.url!,
                  width: widget.width,
                  height: widget.height,
                  fit: widget.fit ?? BoxFit.contain,
                  color: widget.color,
                  errorBuilder: (context, error, stackTrace) => _errorWidget(context),
                );
              }
            })(),
            if (widget.blurColor != null)
              Container(
                height: widget.height,
                width: widget.width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ?? BorderRadius.zero,
                  color: widget.blurColor,
                ),
              ),
            if (widget.child != null) widget.child!.center,
          ],
        ),
      ),
    );
  }

  Widget _errorWidget(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          border: widget.border ?? Border.all(color: context.hoverColor),
        ),
        height: widget.height,
        width: widget.width,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 30,
            maxHeight: 30,
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Icon(Icons.broken_image, color: context.hoverColor),
          ),
        ),
      );
}

class CustomLottie extends StatefulWidget {
  final double? height, width;
  final String? url;
  final BoxFit? fit;
  final Function? onFinish;
  const CustomLottie(this.url, {super.key, this.height, this.width, this.fit, this.onFinish});

  @override
  State<CustomLottie> createState() => _CustomLottieState();
}

class _CustomLottieState extends State<CustomLottie> with TickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.url!,
      height: widget.height,
      width: widget.width,
      fit: widget.fit ?? BoxFit.contain,
      repeat: false,
      onLoaded: (composition) {
        _controller
          ..duration = composition.duration
          ..forward().whenComplete(
            () => Timer(1.seconds, () {
              if (widget.onFinish != null) widget.onFinish!();
            }),
          );
      },
    );
  }
}

class CashNetworkImage extends StatefulWidget {
  final String? url;
  final double? height, width;
  final BoxBorder? border;
  final BoxFit? fit;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;

  const CashNetworkImage(
    this.url, {
    super.key,
    this.height,
    this.width,
    this.fit,
    this.color,
    this.borderRadius,
    this.border,
  });

  @override
  State<CashNetworkImage> createState() => _CashNetworkImageState();
}

class _CashNetworkImageState extends State<CashNetworkImage> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.url!,
      height: widget.height,
      width: widget.width,

      fit: widget.fit ?? BoxFit.contain,
      color: widget.color,
      cacheKey: widget.url,
      maxWidthDiskCache: (widget.width ?? double.infinity) == double.infinity ? context.w.toInt() : (widget.width! * 2).toInt(),
      // maxHeightDiskCache: widget.width?.toInt(),
      errorWidget: (context, url, error) => _errorWidget(),
      placeholder: (context, url) => loading(),
    );
  }

  Widget loading() => Container(
        width: widget.width,
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: widget.borderRadius ?? BorderRadius.zero),
        child: BaseShimmer(
          child: Center(
            child: CustomImage(
              'assets/images/logo.png',
              height: widget.height == null || widget.height! / 7 < 20 ? 20 : widget.height! / 7,
            ).withPadding(horizontal: 10),
          ),
        ),
      );

  Widget _errorWidget() {
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
        border: widget.border ?? Border.all(color: Colors.grey.shade200),
      ),
      height: widget.height,
      width: widget.width,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          constraints: const BoxConstraints(maxWidth: 30, maxHeight: 30),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Icon(Icons.broken_image, color: Colors.grey.shade200),
          ),
        ),
      ),
    );
  }
}
