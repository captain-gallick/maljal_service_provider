import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:maljal_service_provider/constants/app_urls.dart';
import 'package:maljal_service_provider/my_widgets/app_button.dart';
import 'package:maljal_service_provider/screens/service_feeds.dart';
import 'package:maljal_service_provider/utils/my_navigator.dart';
import 'package:maljal_service_provider/utils/shared_preferences.dart';

class LocationSharingScreen extends StatefulWidget {
  final String id;
  const LocationSharingScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _LocationSharingScreenState createState() => _LocationSharingScreenState();
}

class _LocationSharingScreenState extends State<LocationSharingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => _shareLocationDialog());
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Container(),
      ),
    ));
  }

  late BuildContext locationDailog;
  late BuildContext buildContext;

  void _shareLocationDialog() {
    Timer locationTimer = Timer.periodic(
        const Duration(seconds: 15), (Timer t) => _updateLocation());
    showDialog(
        barrierDismissible: false,
        context: buildContext,
        builder: (BuildContext context) {
          locationDailog = context;
          return Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: 300.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    const Center(
                      child: Text(
                        'Close the box to stop sharing your location.',
                        style: TextStyle(color: Colors.black, fontSize: 20.0),
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    AppButton(
                        title: 'Close',
                        width: 150.0,
                        onPressed: () {
                          locationTimer.cancel();
                          Navigator.pushReplacement(
                              buildContext,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ServiceFeedsScreen()));
                        })
                  ],
                ),
              ),
            ),
          );
        });
  }

  late LocationData _locationData;

  _updateLocation() async {
    await getLocation();
    String token = await SharedPreferencesHelper().getToken();
    if (token != '') {
      final Response response = await post(
        Uri.parse(AppUrl.updateLocation),
        headers: <String, String>{'token': token},
        body: jsonEncode(<String, String>{
          "booking_id": widget.id,
          "lat": _locationData.latitude.toString(),
          "lng": _locationData.longitude.toString(),
        }),
      );

      if ((jsonDecode(response.body)['data'] == null)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('AN ERROR OCCURED'),
        ));
        NavigationHelper().navigateTo(context, const ServiceFeedsScreen());
      } else {
        log(response.body);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An Error Occured."),
      ));
    }
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
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
  }
}
