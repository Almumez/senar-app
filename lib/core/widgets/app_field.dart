import 'dart:convert';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/shared/controller/countries/cubit.dart';
import '../../features/shared/controller/countries/states.dart';
import '../../gen/assets.gen.dart';
import '../../gen/locale_keys.g.dart';
import '../../main.dart';
import '../../models/country.dart';
import '../services/service_locator.dart';
import '../utils/enums.dart';
import '../utils/extensions.dart';
import 'custom_image.dart';
import 'flash_helper.dart';
import 'loading.dart';
import 'select_item_sheet.dart';

class AppField extends StatefulWidget {
  final String? hintText, labelText, title;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry? margin;
  final String? Function(String? v)? validator;
  final bool isRequired, loading;
  final bool? enable, readOnly;
  final int maxLines;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final CountryModel? initCountry;
  final void Function(CountryModel country)? onChangeCountry;
  final void Function()? onTap;
  final Widget? suffixIcon, prefixIcon;
  final Color? fillColor;
  final String? direction;
  final bool showFlag;
  final String? phoneCode;

  const AppField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.keyboardType,
    this.margin,
    this.validator,
    this.isRequired = true,
    this.loading = false,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.suffixIcon,
    this.fillColor,
    this.prefixIcon,
    this.onChangeCountry,
    this.initCountry,
    this.title,
    this.enable,
    this.readOnly,
    this.direction,
    this.showFlag = true,
    this.phoneCode,
  });

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  late CountryModel country;
  late final CountriesCubit countryCubit;
  @override
  void initState() {
    if (widget.keyboardType == TextInputType.phone) {
      countryCubit = sl<CountriesCubit>()..getCountries();
      country = widget.initCountry ??
          CountryModel.fromJson(jsonDecode(Prefs.getString('country') ?? "{}"));
      if (country.hasData) widget.onChangeCountry?.call(country);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Text(
              widget.title!,
              style: context.mediumText
                  .copyWith(fontSize: 14, color: context.hintColor),
            ).withPadding(bottom: 8.h),
          Directionality(
            textDirection: widget.keyboardType == TextInputType.phone ||
                    context.locale.languageCode == 'en'
                ? TextDirection.rtl
                : TextDirection.rtl,
            child: TextFormField(
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onFieldSubmitted,
              maxLines: widget.maxLines,
              readOnly: widget.readOnly == true || widget.onTap != null,
              onTap: widget.onTap,
              enabled: widget.enable,
              obscureText:
                  widget.keyboardType == TextInputType.visiblePassword &&
                      showPass,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              validator: (v) {
                if (widget.isRequired && v?.isEmpty == true) {
                  return LocaleKeys.val_is_required.tr(args: [
                    widget.labelText?.replaceAll('*', '') ??
                        widget.title ??
                        LocaleKeys.this_field.tr()
                  ]);
                 }
                //else if (widget.keyboardType == TextInputType.phone &&
                //     v!.length != country.phoneNumberLimit) {
                //   return LocaleKeys.the_phone_number_must_consist_of_val_numbers
                //       .tr(args: [country.phoneNumberLimit.toString()]);
                // }
                // else if (!kDebugMode && widget.keyboardType == TextInputType.visiblePassword && v!.length < 8) {
                //   return LocaleKeys.the_password_must_not_be_less_than_8_numbers.tr();
                // }
                else if (widget.validator != null) {
                  return widget.validator?.call(v);
                }
                return null;
              },
              inputFormatters: [
                if (widget.keyboardType == TextInputType.phone &&
                    country.hasData &&
                    country.phoneNumberLimit > 0)
                  LengthLimitingTextInputFormatter(country.phoneNumberLimit),
              ],
              decoration: InputDecoration(
                hintText: widget.hintText ?? widget.labelText ?? widget.title,
                hintStyle: context.mediumText.copyWith(fontSize: 14.sp, color: Color(0xFF9E9E9E)),
                // labelText: widget.labelText,
                fillColor: widget.fillColor,
                prefixIcon: buildPrefixIcon(context),
                suffixIcon: buildSuffixIcon(context),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.errorColor),
                  borderRadius: BorderRadius.circular(15),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool showPass = true;

  buildSuffixIcon(BuildContext context) {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    } else if (widget.loading) {
      return SizedBox(
        height: 20.h,
        width: 20.h,
        child: CustomProgress(size: 15.h),
      );
    } else if (widget.onTap != null) {
      return CustomImage(
        Assets.svg.drop,
        height: 18.h,
        width: 18.h,
        color: context.primaryColor,
      );
    } else if (widget.keyboardType == TextInputType.visiblePassword) {
      return GestureDetector(
        onTap: () {
          setState(() {
            showPass = !showPass;
          });
        },
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: CustomImage(
            showPass ? Assets.svg.eye : Assets.svg.eyeSlash,
            width: 20.w,
            height: 20.w,
            color: Colors.black,
          ).center,
        ),
      );
    }
  }

  buildPrefixIcon(BuildContext context) {
    if (widget.prefixIcon != null) {
      return widget.prefixIcon;
    } else if (widget.keyboardType == TextInputType.phone) {
      final phoneCode = widget.phoneCode ?? "+${country.phoneCode.isNotEmpty ? country.phoneCode : 'XX'}";
      
      if (!widget.showFlag) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                phoneCode,
                style: context.regularText.copyWith(fontSize: 12),
                textDirection: TextDirection.ltr,
              ).withPadding(start: 10.w, end: 10.w),
              Container(
                margin: EdgeInsetsDirectional.only(end: 10.w),
                height: 15.h,
                width: 1,
                color: context.hintColor,
              )
            ],
          ),
        );
      }
      
      return BlocConsumer<CountriesCubit, CountriesState>(
        bloc: countryCubit,
        listener: (context, state) {
          if (state.countriesState.isError) {
            FlashHelper.showToast(state.msg);
          } else if (state.countriesState.isDone) {
            if (state.openSheet) {
              showModalBottomSheet<CountryModel?>(
                context: context,
                builder: (context) => SelectItemSheet(
                  title: LocaleKeys.select_val
                      .tr(args: [LocaleKeys.country_code.tr()]),
                  items: countryCubit.counties,
                  initItem: country,
                  withImage: true,
                ),
              ).then((value) {
                if (value != null) {
                  country = value;
                  Prefs.setString('country', jsonEncode(country.toJson()));
                  setState(() {});
                  widget.onChangeCountry?.call(country);
                }
              });
            } else if (!country.hasData && countryCubit.counties.isNotEmpty) {
              country = countryCubit.counties.first;
              setState(() {});
              widget.onChangeCountry?.call(country);
            }
          }
        },
        builder: (context, state) {
          return InkWell(
            onTap: () {
              if (state.countriesState != RequestState.loading) {
                countryCubit.getCountries(openSheet: true);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomImage(
                  country.image,
                  borderRadius: BorderRadius.circular(2.r),
                  height: 14.h,
                  width: 21.w,
                ).withPadding(start: 4.w, end: 4.w),
                Text(
                  phoneCode,
                  style: context.regularText.copyWith(fontSize: 12),
                  textDirection: TextDirection.ltr,
                ),
                CustomImage(
                  Assets.svg.drop,
                  height: 10.h,
                  width: 10.h,
                ).withPadding(start: 4.w, end: 8.w),
                Container(
                  margin: EdgeInsetsDirectional.only(end: 10.w),
                  height: 15.h,
                  width: 1,
                  color: context.hintColor,
                )
              ],
            ),
          );
        },
      );
    }

    return null;
  }
}
