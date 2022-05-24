import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maljal_service_provider/screens/login_screen.dart';
import 'package:maljal_service_provider/screens/service_feeds.dart';
import 'package:maljal_service_provider/screens/welcome_screen.dart';
import 'package:maljal_service_provider/utils/my_navigator.dart';
import 'package:maljal_service_provider/utils/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      checkPath();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(80.0),
              child: Image.asset('assets/images/logo.png'),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Image.asset('assets/images/vendor_text_icon.png'),
            ),

            /* const Text(
              'Service Provider',
              style: TextStyle(color: Colors.white),
            ), */
            const SizedBox(
              height: 10.0,
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Image.asset('assets/images/splash_image.png'),
        )
      ],
    )));
  }

  checkPath() async {
    SharedPreferencesHelper preferencesHelper = SharedPreferencesHelper();

    if (await preferencesHelper.isWelcomeShown()) {
      if (await preferencesHelper.isLoggedIn()) {
        NavigationHelper().navigateTo(context, const ServiceFeedsScreen());
      } else {
        NavigationHelper().navigateTo(context, const LoginScreen());
      }
    } else {
      NavigationHelper().navigateTo(context, const WelcomeScreen());
    }
  }
}
