import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/fonts.gen.dart';
import 'extensions.dart';

class AppThemes {
  static const mainColor = '#090909';
  static const lightText = '#f5f5f5';
  static const scaffoldBackgroundColor = '#FFFFFF';
  static const lightColor = '#f5f5f5';
  static const mainBorder = '#f5f5f5';
  static const blackColor = '#040404';
  static const rateColor = '#F4BD5B';
  static const secondaryColor = '#A07855';
  static const whiteColor = '#FFFFFF';
  static const errorColor = '#F43F3F';
  static const secondaryHeaderColor = '#f5f5f5';
  static const canvasColor = '#f5f5f5';
  static const shadowColor = '#f5f5f5';
  static const cardColor = '#f5f5f5';

  static ThemeData get lightTheme => ThemeData(
        indicatorColor: rateColor.color,
        primaryColor: mainColor.color,
        scaffoldBackgroundColor: scaffoldBackgroundColor.color,
        textTheme: arabicTextTheme,
        hoverColor: lightColor.color,
        fontFamily: FontFamily.ibm,
        hintColor: lightText.color,
        primaryColorLight: Colors.white,
        primaryColorDark: blackColor.color,
        disabledColor: lightText.color,
        secondaryHeaderColor: secondaryHeaderColor.color,
        canvasColor: canvasColor.color,
        cardColor: cardColor.color,
        shadowColor: shadowColor.color,
        splashColor: Colors.transparent, // Removes splash effect
        highlightColor: Colors.transparent, // Removes highlight when holding
        dividerColor: mainBorder.color,
        appBarTheme: AppBarTheme(
          backgroundColor: scaffoldBackgroundColor.color,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: whiteColor.color,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            fontFamily: FontFamily.ibm,
            color: blackColor.color,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: scaffoldBackgroundColor.color,
          selectedItemColor: mainColor.color,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          // selectedLabelStyle: const TextStyle(color: Colors.white),
          // unselectedLabelStyle: TextStyle(color: "#AED489".color),
          type: BottomNavigationBarType.fixed,
          selectedIconTheme: const IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: "#f5f5f5".color),
          unselectedItemColor: "#f5f5f5".color,
          enableFeedback: true,
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return mainColor.color;
              } else {
                return mainBorder.color;
              }
            },
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(1000),
            borderSide: BorderSide.none,
          ),
          iconSize: 24.h,
          backgroundColor: mainColor.color,
          elevation: 1,
        ),
        colorScheme: ColorScheme.light(
          primaryContainer: lightColor.color,
          secondary: secondaryColor.color,
          primary: mainColor.color,
          error: errorColor.color,
        ),
        timePickerTheme: TimePickerThemeData(
          elevation: 0,
          dialHandColor: mainColor.color,
          dialTextColor: Colors.black,
          backgroundColor: Colors.white,
          hourMinuteColor: scaffoldBackgroundColor.color,
          dayPeriodTextColor: Colors.black,
          entryModeIconColor: Colors.transparent,
          dialBackgroundColor: scaffoldBackgroundColor.color,
          hourMinuteTextColor: Colors.black,
          dayPeriodBorderSide: BorderSide(color: mainColor.color),
        ),
        dividerTheme: DividerThemeData(color: mainBorder.color),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: const TextStyle(
            fontFamily: FontFamily.ibm,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          inputDecorationTheme: InputDecorationTheme(
            suffixIconColor: mainColor.color,
            fillColor: scaffoldBackgroundColor.color,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 18.w),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: lightText.color),
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: TextStyle(fontSize: 14.sp, fontFamily: FontFamily.ibm, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w500),
          hintStyle: TextStyle(fontSize: 14.sp, fontFamily: FontFamily.ibm, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w500),
          fillColor: scaffoldBackgroundColor.color,
          filled: true,
          errorBorder: OutlineInputBorder(borderSide: BorderSide(color: errorColor.color), borderRadius: BorderRadius.circular(14.r)),
          disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: mainBorder.color), borderRadius: BorderRadius.circular(14.r)),
          border: OutlineInputBorder(borderSide: BorderSide(color: mainBorder.color), borderRadius: BorderRadius.circular(14.r)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: mainColor.color), borderRadius: BorderRadius.circular(14.r)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: mainBorder.color), borderRadius: BorderRadius.circular(14.r)),
          contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 18.w),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.transparent,
          modalBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            borderSide: BorderSide.none,
          ),
        ),
      );

  static TextTheme get arabicTextTheme => const TextTheme(
        labelLarge: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),  // bold
        headlineMedium: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),  // semibold
        labelMedium: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),  // medium
        headlineSmall: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),  // regular
        labelSmall: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),  // light
        titleLarge: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),  // titulo importante
      );
}
