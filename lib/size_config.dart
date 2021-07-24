import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SizeConfig {
  static double screenWidth;
  static double w;
  static double wR;
  static double screenHeight;
  static double textFactor;
  static double h;
  static double hR;

  static double heightMultiplier;
  static double widthMultiplier;
  static bool isPortrait = true;

  void init(BoxConstraints constraints, Orientation orientation) {
    if (orientation == Orientation.portrait) {
      w = 411.4;
      h = 684.4;

      textFactor = Get.textScaleFactor;
      screenWidth = constraints.maxWidth > 411.4
          ? constraints.maxWidth / 411.4
          : textFactor;
      screenHeight = constraints.maxHeight > 684.4
          ? constraints.maxHeight / 684.4
          : textFactor;
      isPortrait = true;
    }
    // } else {
    //   w = 684.4/100;
    //   wR = 684.4/411.4;
    //   h = 411.4/100;
    //   hR = 411.4/684.4;
    //   // w = 411.4;
    //   // h = 684.4;
    //   screenWidth = constraints.maxWidth;
    //   screenHeight = constraints.maxHeight;
    //   isPortrait = false;
    // }

    // _blockSizeHorizontal = _screenWidth / 100;
    // _blockSizeVertical = _screenHeight / 100;

    // textMultiplier = _blockSizeVertical;
    // imageSizeMultiplier = _blockSizeHorizontal;
    // heightMultiplier = _blockSizeVertical;
    // widthMultiplier = _blockSizeHorizontal;
  }
}

// import 'package:flutter/material.dart';

// class SizeConfig {
//   static MediaQueryData _mediaQueryData;
//   static double screenWidth;
//   static double screenHeight;
//   static double defaultHeight;
//   static double defaultWidth;
//   static Orientation orientation;

//   void init(BuildContext context) {
//     _mediaQueryData = MediaQuery.of(context);

//     orientation = _mediaQueryData.orientation;

//     if (orientation == Orientation.portrait) {
//       screenWidth = _mediaQueryData.size.width;
//       screenHeight = _mediaQueryData.size.height;
//       defaultHeight = 684.4;
//       defaultWidth = 411.4;
//     } else {
//       screenHeight = _mediaQueryData.size.width;
//       screenWidth = _mediaQueryData.size.height;
//       defaultWidth = 684.4;
//       defaultHeight = 411.4;
//     }
//   }
// }

// Get the proportionate height as per screen size
double getHeight(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
  // 812 is the layout height that designer use
  return inputHeight * screenHeight;
}

// Get the proportionate height as per screen size
double getWidth(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designer use
  return inputWidth * screenWidth;
}

double getText(double inputWidth) {
  double textFactor = SizeConfig.textFactor;
  // 375 is the layout width that designer use
  return inputWidth * textFactor;
}
