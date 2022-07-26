import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:maljal_service_provider/constants/app_colors.dart';
import 'package:maljal_service_provider/constants/app_urls.dart';
import 'package:maljal_service_provider/data_models/vendors.dart';
import 'package:maljal_service_provider/my_widgets/app_button.dart';
import 'package:maljal_service_provider/my_widgets/text_field.dart';
import 'package:maljal_service_provider/screens/service_feeds.dart';
import 'package:maljal_service_provider/utils/my_navigator.dart';
import 'package:maljal_service_provider/utils/network_checkup.dart';
import 'package:maljal_service_provider/utils/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showOTP = false;
  String _otp = '', _phone = '';
  var phoneController = TextEditingController();
  var otpController = TextEditingController();
  late BuildContext dialogContext, alertDialogContext;
  String appSignature = 'qsyJENrq9bU';
  late Timer timer;
  late BuildContext buildContext;

  @override
  void initState() {
    super.initState();
    SmsAutoFill().getAppSignature.then((value) {
      appSignature = value;
    });
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => _checkPermissionDialog());
  }

  _checkPermissionDialog() async {
    showPermissionDialog();
  }

  void showPermissionDialog() async {
    String myText =
        'Upaay Service Provider collects location data to enable live tracking of the service provider even when the app is closed or not in use.';

    showDialog(
        barrierDismissible: false,
        context: buildContext,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Dialog(
              backgroundColor: Colors.white,
              child: SizedBox(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          myText,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20.0),
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          getLocation();
                        },
                        child: const Text('Okay'))
                  ],
                ),
              ),
            ),
          );
        });
  }

  getLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      //showPermissionDialog(2);
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        showPermissionDialog();
        return;
      }
    }
  }

  @override
  void dispose() {
    timer.cancel();
    SmsAutoFill().unregisterListener();
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return SafeArea(
      child: WillPopScope(
          onWillPop: () async {
            if (showOTP) {
              showAlertDialog();
            } else {
              SystemNavigator.pop();
            }
            return false;
          },
          child: Scaffold(
              body: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/user_icon.png',
                      width: 150.0,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      'LOGIN',
                      style: TextStyle(
                          color: AppColors.appTextLightBlue, fontSize: 35.0),
                    ),
                    const SizedBox(
                      height: 70.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Visibility(
                            visible: !showOTP,
                            child: const Text(
                              'Enter Your Phone Number',
                              style: TextStyle(
                                  color: AppColors.lightTextColor,
                                  fontSize: 18),
                            )),
                      ),
                    ),
                    Visibility(
                      visible: !showOTP,
                      child: MyTextField(
                        prefix: '   +91   ',
                        hint: 'Enter Phone',
                        length: 10,
                        type: TextInputType.number,
                        myController: phoneController,
                      ),
                    ),
                    Visibility(
                      visible: showOTP,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              'sent to ${phoneController.text}',
                              style: const TextStyle(
                                  color: AppColors.lightTextColor),
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                showAlertDialog();
                              },
                              child: const Text(
                                'change?',
                                style: TextStyle(
                                    decoration: TextDecoration.underline),
                              ))
                        ],
                      ),
                    ),
                    Visibility(
                        visible: showOTP,
                        child: Column(children: [
                          PinFieldAutoFill(
                            decoration: const UnderlineDecoration(
                                textStyle:
                                    TextStyle(color: AppColors.lightTextColor),
                                colorBuilder:
                                    FixedColorBuilder(AppColors.appGreen)),
                            controller: otpController,
                            codeLength: 6,
                            onCodeSubmitted: (code) {
                              doLogin();
                            },
                            onCodeChanged: (code) {
                              if (code!.length == 6) {
                                _otp = code;
                                doLogin();
                              }
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          StatefulBuilder(builder:
                              (BuildContext context, StateSetter setter) {
                            timer = Timer(const Duration(seconds: 1), () {
                              getTimeText(setter);
                            });
                            return Text(
                              timeText,
                              style: const TextStyle(
                                  color: AppColors.lightTextColor),
                            );
                          }),
                        ])),
                    const SizedBox(
                      height: 80.0,
                    ),
                    AppButton(
                      title: (!showOTP ? 'CONTINUE' : 'LOG IN'),
                      onPressed: () {
                        NetworkCheckUp().checkConnection().then((value) {
                          if (value) {
                            (!showOTP ? sendOTP() : doLogin());
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Please connect to internet."),
                            ));
                          }
                        });
                      },
                      width: 150.0,
                    )
                  ],
                ),
              ),
            ),
          ))),
    );
  }

  int startTime = 120;
  String timeText = 'Resend OTP in 2 : 00';

  getTimeText(setter) {
    if (startTime != 0) {
      setter(() {
        startTime = (startTime - 1).round();
        if (startTime >= 60) {
          timeText = 'Resend OTP in 1 : ' + (startTime - 60).toString();
        } else {
          timeText = 'Resend OTP in 0 : ' + startTime.toString();
        }
      });
    } else {
      sendOTP();
    }
  }

  Future<void> sendOTP() async {
    _phone = phoneController.text;

    if (_phone.length == 10) {
      showLoader();
      final Response response = await post(
        Uri.parse(AppUrl.sendOtp),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{'phone': _phone, 'signature': appSignature}),
      );

      log(response.body);
      if (!(jsonDecode(response.body).toString().toLowerCase())
          .contains('success')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(jsonDecode(response.body)['message']),
        ));
        Navigator.pop(dialogContext);
      } else {
        setState(() {
          SmsAutoFill().listenForCode;
          showOTP = true;
          Navigator.pop(dialogContext);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter a valid Phone Number."),
      ));
    }
  }

  Future<void> doLogin() async {
    _otp = otpController.text;
    log('_otp: ' + _otp);

    if (_otp.length == 6) {
      showLoader();
      final Response response = await post(
        Uri.parse(AppUrl.verifyOtp),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'phone': _phone, 'otp': _otp}),
      );

      log(response.body);
      if (!(jsonDecode(response.body).toString().toLowerCase())
          .contains('success')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              jsonDecode(response.body)['message'].toString().toUpperCase()),
        ));
        Navigator.pop(dialogContext);
      } else {
        timer.cancel();
        Vendor user = Vendor.fromJson(jsonDecode(response.body)['data']);

        SharedPreferencesHelper sharedPreferences = SharedPreferencesHelper();

        await sharedPreferences.setToken(user.token);
        String address = user.building +
            ", " +
            user.area +
            ", " +
            user.ward +
            ", " +
            user.city +
            ", " +
            user.pincode +
            ", ";
        await sharedPreferences.setVendor(user, address);
        NavigationHelper().navigateTo(context, const ServiceFeedsScreen());
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter a valid Phone Number."),
      ));
    }
  }

  void showLoader() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return WillPopScope(
              child: Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const CircularProgressIndicator(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: (showOTP
                            ? const Text('Please wait while we login...')
                            : const Text('Please wait...')),
                      ),
                    ],
                  ),
                ),
              ),
              onWillPop: () async => false);
        });
  }

  showAlertDialog() {
    // set up the buttons
    Widget yesButton = TextButton(
      child: const Text("YES"),
      onPressed: () {
        setState(() {
          timer.cancel();
          showOTP = !showOTP;
          Navigator.pop(alertDialogContext);
        });
      },
    );
    Widget noButton = TextButton(
      child: const Text("NO"),
      onPressed: () {
        Navigator.pop(alertDialogContext);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("AlertDialog"),
      content: const Text("Are you sure?"),
      actions: [
        yesButton,
        noButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        alertDialogContext = context;
        return WillPopScope(
            child: alert,
            onWillPop: () async {
              return false;
            });
      },
    );
  }
}
