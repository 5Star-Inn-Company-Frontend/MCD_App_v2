import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/styles/app_colors.dart';

final lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.white,
    primaryColor: AppColors.white,
    applyElevationOverlayColor: false,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      // systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      // statusBarBrightness: Brightness.light,),

      // backgroundColor: AppColors.white,
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: AppColors.primaryGreen.withOpacity(0.3),
      cursorColor: AppColors.primaryColor,
      selectionHandleColor: AppColors.primaryGreen,
    ),
    textTheme: GoogleFonts.manropeTextTheme(),
    primaryTextTheme: GoogleFonts.manropeTextTheme(),
    dialogBackgroundColor: Colors.white,
    hoverColor: AppColors.primaryGreen.withOpacity(0.1),
    highlightColor: AppColors.primaryGreen.withOpacity(0.1),
    splashColor: AppColors.primaryGreen.withOpacity(0.1),
    focusColor: AppColors.primaryGreen.withOpacity(0.1),
    hintColor: AppColors.primaryGreen.withOpacity(0.5),
  );
