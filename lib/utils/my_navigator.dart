import 'package:flutter/material.dart';

class NavigationHelper {
  navigateTo(context, screen) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => screen));
  }

  closeTempScreen(context) {
    Navigator.pop(context);
  }

  openTempScreen(context, screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
