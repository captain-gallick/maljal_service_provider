// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:maljal_service_provider/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String title;
  final GestureTapCallback onPressed;
  final double? width;

  const AppButton(
      {Key? key, required this.title, required this.onPressed, this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: onPressed,
                  child: Center(
                    child: Text(title,
                        style: const TextStyle(
                            color: AppColors.appLightBlue, fontSize: 16.0)),
                  )))),
      height: 40.0,
      width: width,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppColors.buttonGradientTop,
                AppColors.buttonGradientBottom
              ])),
    );
  }
}
