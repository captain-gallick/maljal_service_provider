import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maljal_service_provider/my_widgets/app_button.dart';
import 'package:maljal_service_provider/my_widgets/text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        body: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage('assets/images/login_bg.png'),
                fit: BoxFit.cover,
              )),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 5,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 210.0,
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 9,
                    child: Text(
                        'Type your registered email, We will send you Password reset link on that id',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.grey,
                        )),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 9.25,
                    child: MyTextField(
                      hint: 'Enter Email',
                      type: TextInputType.emailAddress,
                    ),
                  ),
                  Align(
                    heightFactor: 18,
                    alignment: Alignment.bottomCenter,
                    child: AppButton(
                      title: 'SUBMIT',
                      onPressed: () {},
                      width: 150.0,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
