import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:maljal_service_provider/constants/app_colors.dart';
import 'package:maljal_service_provider/constants/app_urls.dart';
import 'package:maljal_service_provider/screens/service_feeds.dart';
import 'package:maljal_service_provider/utils/my_navigator.dart';
import 'package:maljal_service_provider/utils/network_checkup.dart';
import 'package:maljal_service_provider/utils/shared_preferences.dart';

class DeclineServiceScreen extends StatefulWidget {
  final String id;
  const DeclineServiceScreen({Key? key, required this.id}) : super(key: key);

  @override
  _DeclineServiceScreenState createState() => _DeclineServiceScreenState();
}

class _DeclineServiceScreenState extends State<DeclineServiceScreen> {
  TextEditingController reasonController = TextEditingController();
  late BuildContext dialogContext;
  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
            onWillPop: () async {
              NavigationHelper().closeTempScreen(context);
              return false;
            },
            child: Scaffold(
                backgroundColor: AppColors.appLightBlue,
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: AppColors.appLightBlue,
                  title: const Text('SEND REMARK',
                      style: TextStyle(color: AppColors.appTextDarkBlue)),
                  centerTitle: true,
                  leading: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.appTextDarkBlue,
                      )),
                ),
                body: Stack(
                  children: [
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Image.asset('assets/images/login_bg_inv.png')),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          children: [
                            const Center(
                              child: Text(
                                'Please add you remark here.',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: AppColors.appTextDarkBlue),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 10,
                              child: TextFormField(
                                controller: reasonController,
                                minLines: 7,
                                maxLines: 7,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                    fillColor: AppColors.backgroundcolor,
                                    filled: true,
                                    hintText: 'Type here...',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                    )),
                              ),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  NetworkCheckUp()
                                      .checkConnection()
                                      .then((value) {
                                    if (value) {
                                      declineService();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content:
                                            Text("Please connect to internet."),
                                      ));
                                    }
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Text(
                                    'SEND',
                                    style: TextStyle(
                                        color: AppColors.appAlmostWhite),
                                  ),
                                )),
                            /* AppButton(
                              title: 'SUBMIT TO DECLINE',
                              onPressed: () {
                                NetworkCheckUp()
                                    .checkConnection()
                                    .then((value) {
                                  if (value) {
                                    declineService();
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content:
                                          Text("Please connect to internet."),
                                    ));
                                  }
                                });
                              },
                              width: 200,
                            ), */
                            const SizedBox(
                              height: 50,
                            ),
                            GestureDetector(
                                onTap: () {
                                  NavigationHelper().closeTempScreen(context);
                                },
                                child: const Text('GO BACK',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )))
                          ],
                        ),
                      ),
                    )
                  ],
                ))));
  }

  Future<void> declineService() async {
    try {
      String reason = reasonController.text;
      String token = await SharedPreferencesHelper().getToken();

      if (reason.isNotEmpty) {
        showLoader();
        final Response response = await post(
          Uri.parse(AppUrl.decline),
          headers: <String, String>{
            'token': token,
          },
          body: jsonEncode(
              <String, String>{'vendor_msg': reason, 'id': widget.id}),
        );

        if ((jsonDecode(response.body)['status'] == true)) {
          NavigationHelper().navigateTo(context, const ServiceFeedsScreen());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                jsonDecode(response.body)['message'].toString().toUpperCase()),
          ));
          Navigator.pop(dialogContext);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter a message."),
        ));
      }
    } catch (e) {
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An Error occured."),
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
                    children: const <Widget>[
                      CircularProgressIndicator(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text('Please wait...'),
                      ),
                    ],
                  ),
                ),
              ),
              onWillPop: () async => false);
        });
  }
}
