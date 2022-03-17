import 'package:flutter/material.dart';

class ColorsX {
  static const brownTextColor = Color(0xff7B4425);
  static const primaryBlue = Color(0xFF5E2580);
  static const appRedColor = Color(0xFFD22630);

  static const lightBlue = Color(0xFF1CC7DB);
  static const lightDarkBlue = Color(0xFF3E72AC);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const red = Color(0xFFFF0000);

  static const lightGrey = Color(0xFFD4D4D4);

  static const grey = Color(0xFFF8F8F8);
  static const darkGrey = Color(0xFFDFDFDF);
  static const borderGrey = Color(0xFF707070);

  static const bgColor = Color(0xFFF2F2F2);
  static const greyField = Color(0xffC2C2C2);

  static const greyInputfield = Color(0xFFCFCFCF);
  static const greyText = Color(0xFFAAAAAA);
  static const lightGreyText = Color(0xFF757575);
  static const horizontalGradiant = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    //end: Alignment(0.8, 0.0), // 10% of the width, so there are ten blinds.
    colors: <Color>[
      Color(0xff5E2580),
      Color(0xff1CC7DB),
    ], // red to yellow
    //tileMode: TileMode.repeated,
  );
}
