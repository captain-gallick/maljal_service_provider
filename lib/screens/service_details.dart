import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:maljal_service_provider/constants/app_colors.dart';
import 'package:maljal_service_provider/constants/app_urls.dart';
import 'package:maljal_service_provider/data_models/my_services.dart';
import 'package:maljal_service_provider/my_widgets/app_button.dart';
import 'package:maljal_service_provider/my_widgets/text_field.dart';
import 'package:maljal_service_provider/screens/service_feeds.dart';
import 'package:maljal_service_provider/utils/map_utils.dart';
import 'package:maljal_service_provider/utils/my_navigator.dart';
import 'package:maljal_service_provider/utils/network_checkup.dart';
import 'package:maljal_service_provider/utils/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:background_location/background_location.dart' as bl;

class ServiceDetailsScrceen extends StatefulWidget {
  final MyServices myServices;
  const ServiceDetailsScrceen({Key? key, required this.myServices})
      : super(key: key);

  @override
  _ServiceDetailsScrceenState createState() => _ServiceDetailsScrceenState();
}

class _ServiceDetailsScrceenState extends State<ServiceDetailsScrceen>
    with WidgetsBindingObserver {
  late BuildContext buildContext;
  bool showButtons = true;
  bool showAccept = true;
  bool showDecline = false;
  bool showFinish = false;
  late TextEditingController happyCodeController = TextEditingController();
  late BuildContext dialogContext;
  late LocationData _locationData;
  Timer? locationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => getLocation());
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    happyCodeController.dispose();
    locationTimer?.cancel();
    bl.BackgroundLocation.stopLocationService();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        bl.BackgroundLocation.stopLocationService();
        break;
      case AppLifecycleState.inactive:
        // widget is inactive
        break;
      case AppLifecycleState.paused:
        // widget is paused
        break;
      case AppLifecycleState.detached:
        // widget is detached
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return SafeArea(
        child: WillPopScope(
            onWillPop: () async {
              //NavigationHelper().closeTempScreen(context);
              NavigationHelper()
                  .navigateTo(context, const ServiceFeedsScreen());
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Align(
                    alignment: const Alignment(-0.25, 0.0),
                    child: Text(
                      widget.myServices.servicename,
                      softWrap: true,
                      style: const TextStyle(color: AppColors.appTextDarkBlue),
                    )),
                backgroundColor: AppColors.backgroundcolor,
                elevation: 0.0,
                leading: IconButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.appTextDarkBlue,
                    ),
                    onPressed: () {
                      //NavigationHelper().closeTempScreen(context);
                      NavigationHelper()
                          .navigateTo(context, const ServiceFeedsScreen());
                    }),
              ),
              body: SizedBox(
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Card(
                            color: Colors.blue.shade50,
                            margin: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 5.0),
                            elevation: 10.0,
                            shadowColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            child: SizedBox(
                              height: 450,
                              width: 400,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        //put image here
                                        child: getImage(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Service Name: ' +
                                          widget.myServices.servicename,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: AppColors.appTextDarkBlue,
                                      ),
                                    ),
                                    Text(
                                      'Service No: ' + widget.myServices.id,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: AppColors.appTextDarkBlue,
                                      ),
                                    ),
                                    Text(
                                      'Description: ' + widget.myServices.descr,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: AppColors.appTextDarkBlue,
                                      ),
                                    ),
                                    (!widget.myServices.video.endsWith('org/')
                                        ? getVideo(1)
                                        : getVideo(2)),
                                    const Text(
                                      'Person Details',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: AppColors.appTextDarkBlue,
                                      ),
                                    ),
                                    Text(
                                      'Name: ' + widget.myServices.username,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: AppColors.appTextDarkBlue,
                                      ),
                                    ),
                                    Text(
                                      'Phone: ' + widget.myServices.uphone,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: AppColors.appTextDarkBlue,
                                      ),
                                    ),
                                    Text(
                                      'Email: ' + widget.myServices.uemail,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: AppColors.appTextDarkBlue,
                                      ),
                                    ),
                                    Text(
                                      'Address: ' +
                                          widget.myServices.building +
                                          ', ' +
                                          widget.myServices.areaname +
                                          ', ' +
                                          widget.myServices.city +
                                          ', ' +
                                          widget.myServices.pincode,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: AppColors.appTextDarkBlue,
                                      ),
                                    ),
                                    Text(
                                      'Landmark: ' + widget.myServices.landmark,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: AppColors.appTextDarkBlue,
                                      ),
                                    ),
                                    Text(
                                      widget.myServices.addedOn
                                              .replaceAll(' ', ' | ') +
                                          " | " +
                                          'STATUS:' +
                                          getStatus(widget.myServices.status),
                                      style: const TextStyle(
                                        color: AppColors.appTextDarkBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: showButtons,
                            child: Center(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor:
                                                AppColors.lightTextColor),
                                        onPressed: () async {
                                          await bl.BackgroundLocation
                                              .setAndroidNotification(
                                            title:
                                                'Your location is being shared',
                                            message:
                                                'Your location is being shared',
                                            icon: 'assets/icon/icon.png',
                                          );
                                          await bl.BackgroundLocation
                                              .setAndroidConfiguration(1000);
                                          await bl.BackgroundLocation
                                              .startLocationService(
                                                  distanceFilter: 1);
                                          bl.BackgroundLocation
                                              .getLocationUpdates((loc) {
                                            log(loc.latitude.toString());
                                            _updateLocation(
                                                loc.latitude, loc.longitude);
                                          });
                                          MapUtils.openMap(
                                              double.parse(
                                                  widget.myServices.lat),
                                              double.parse(
                                                  widget.myServices.lng));
                                          //_shareLocationDialog();
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Text(
                                            'ENROUTE',
                                            style: TextStyle(
                                                color: AppColors.appAlmostWhite,
                                                fontSize: 16.0),
                                          ),
                                        )),
                                    TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              AppColors.lightTextColor,
                                        ),
                                        onPressed: () {
                                          url_launcher.launch("tel://" +
                                              widget.myServices.uphone);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Text(
                                            'CALL USER',
                                            style: TextStyle(
                                                color: AppColors.appAlmostWhite,
                                                fontSize: 16.0),
                                          ),
                                        )),
                                  ]),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Visibility(
                            visible: showAccept,
                            child: Center(
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: AppColors.appGreen,
                                    ),
                                    onPressed: () {
                                      NetworkCheckUp()
                                          .checkConnection()
                                          .then((value) {
                                        if (value) {
                                          _acceptService();
                                          /* setState(() {
                                          widget.myServices.status = '2';
                                        }); */
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                                "Please connect to internet."),
                                          ));
                                        }
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      child: Text(
                                        'ACCEPT SERVICE',
                                        style: TextStyle(
                                            color: AppColors.appAlmostWhite),
                                      ),
                                    ))
                                /* child: AppButton(
                                  title: 'ACCEPT SERVICE',
                                  width: 200.0,
                                  onPressed: () {
                                    NetworkCheckUp()
                                        .checkConnection()
                                        .then((value) {
                                      if (value) {
                                        _acceptService();
                                        /* setState(() {
                                          widget.myServices.status = '2';
                                        }); */
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Please connect to internet."),
                                        ));
                                      }
                                    });
                                  }), */
                                ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Visibility(
                            visible: showFinish,
                            child: Center(
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: AppColors.appGreen,
                                    ),
                                    onPressed: () {
                                      getHappyCode();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      child: Text(
                                        'FINISH SERVICE',
                                        style: TextStyle(
                                            color: AppColors.appAlmostWhite),
                                      ),
                                    ))
                                /* child: AppButton(
                                  title: 'FINISH SERVICE',
                                  width: 200.0,
                                  onPressed: () {
                                    getHappyCode();
                                  }), */
                                ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          /* Visibility(
                              visible: showDecline,
                              child: Center(
                                  child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        NavigationHelper().openTempScreen(
                                            context,
                                            DeclineServiceScreen(
                                              id: widget.myServices.id,
                                            ));
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text(
                                          'DECLINE SERVICE',
                                          style: TextStyle(
                                              color: AppColors.appAlmostWhite),
                                        ),
                                      )))
                              /* child: AppButton(
                                  title: 'DECLINE SERVICE',
                                  width: 200.0,
                                  onPressed: () {
                                    NavigationHelper().openTempScreen(
                                        context,
                                        DeclineServiceScreen(
                                          id: widget.myServices.id,
                                        ));
                                  }), */
                              ), */
                        ]),
                  ),
                ),
              ),
            )));
  }

  getVideo(int i) {
    if (i == 1) {
      return GestureDetector(
        onTap: () {
          NetworkCheckUp().checkConnection().then((value) {
            if (value) {
              url_launcher.launch(widget.myServices.video);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Please connect to internet."),
              ));
            }
          });
        },
        child: Text(
          'open video',
          style: TextStyle(
              color: Colors.blue.shade800,
              decoration: TextDecoration.underline),
        ),
      );
    } else {
      return const Text('');
    }
  }

  String getStatus(String s) {
    String status = '';
    switch (s) {
      case '1':
        status = 'NEW';
        showButtons = false;
        showDecline = false;
        showAccept = true;
        break;
      case '2':
        status = 'ON GOING';
        showAccept = false;
        showButtons = true;
        showFinish = true;
        if (widget.myServices.vendormsg == '') {
          showDecline = true;
        } else {
          showDecline = false;
        }
        break;
      case '3':
        status = 'COMPLETE';
        showButtons = false;
        showAccept = false;
        break;
      default:
    }
    return status;
  }

  getImage() {
    if (!widget.myServices.image.endsWith('maljal.org/')) {
      return GestureDetector(
          onTap: () {
            showImage(widget.myServices.image);
          },
          child: Align(
              alignment: Alignment.topCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: _getImage(widget.myServices.image),
              )));
    } else {
      return const Center(child: Text('No Image Available'));
    }
  }

  _getImage(String image) {
    try {
      return Image.network(image, fit: BoxFit.cover);
    } catch (e) {
      return const Text('x');
    }
  }

  void showImage(image) {
    showDialog(
        barrierDismissible: true,
        context: buildContext,
        builder: (BuildContext context) {
          dialogContext = context;
          return WillPopScope(
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _getImage(image),
                ),
              ),
              onWillPop: () async => true);
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
        //showPermissionDialog(2);
        return;
      }
    }

    _locationData = await location.getLocation();
  }

  _acceptService() async {
    try {
      showLoader();
      await getLocation();
      String token = await SharedPreferencesHelper().getToken();
      if (token != '') {
        //LocationData data = await getLocation();
        final Response response = await post(Uri.parse(AppUrl.accept),
            headers: <String, String>{'token': token},
            body: jsonEncode(<String, String>{
              "booking_id": widget.myServices.id,
              "lat": _locationData.latitude.toString(),
              "lng": _locationData.longitude.toString(),
            }));
        log('accept___' + response.body);
        if ((jsonDecode(response.body)['data'] == null)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('AN ERROR OCCURED'),
          ));
          Navigator.pop(dialogContext);
        } else {
          //showLoader();
          Timer(const Duration(seconds: 2), () {
            Navigator.pop(dialogContext);
            setState(() {
              widget.myServices.status = '2';
            });
          });
        }
      } else {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error!"),
        ));
      }
    } catch (e) {
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error!"),
      ));
      log(e.toString());
    }
  }

  void showLoader() {
    showDialog(
        barrierDismissible: false,
        context: buildContext,
        builder: (BuildContext context) {
          dialogContext = context;
          return WillPopScope(
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    'assets/images/loader.png',
                    width: 100.0,
                  ),
                ),
              ),
              onWillPop: () async => false);
        });
  }

  /* void showPermissionDialog(int val) async {
    String myText = '';
    if (val != 2) {
      myText =
          'Maljal Service Provider collects location data to enable live tracking of the service provider even when the app is closed or not in use.';
    } else {
      myText =
          'Please allow background location access from settings to use all features of the app.';
    }
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
                    Visibility(
                      visible: (val != 2 ? true : false),
                      child: Row(
                        children: [
                          TextButton(
                              onPressed: () async {
                                //await SharedPreferencesHelper().setLocationDialog(2);
                                Navigator.pop(context);
                                //getLocation();
                              },
                              child: const Text('Deny')),
                          TextButton(
                              onPressed: () async {
                                await SharedPreferencesHelper()
                                    .setLocationDialog(1);
                                Navigator.pop(context);
                                getLocation();
                              },
                              child: const Text('Allow'))
                        ],
                      ),
                    ),
                    Visibility(
                        visible: (val == 2),
                        child: TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              //getLocation();
                            },
                            child: const Text('Okay')))
                  ],
                ),
              ),
            ),
          );
        });
  } */

  void getHappyCode() async {
    await _requestHappyCode();
    showDialog(
        barrierDismissible: true,
        context: buildContext,
        builder: (BuildContext context) {
          dialogContext = context;
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    height: 300.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        const Text(
                          'Enter Happy code:',
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                        MyTextField(
                          type: TextInputType.number,
                          myController: happyCodeController,
                        ),
                        Row(
                          children: [
                            Text(fileName),
                            const Text('Pick'),
                            TextButton(
                                onPressed: () {
                                  imageVideo = 1;
                                  pickFile(setState);
                                },
                                child: const Text('Image')),
                            const Text('or'),
                            TextButton(
                                onPressed: () {
                                  imageVideo = 2;
                                  pickFile(setState);
                                },
                                child: const Text('Video')),
                          ],
                        ),
                        AppButton(
                            title: 'SUBMIT',
                            width: 150.0,
                            onPressed: () {
                              NetworkCheckUp().checkConnection().then((value) {
                                if (value) {
                                  _finishService();
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content:
                                        Text("Please connect to internet."),
                                  ));
                                }
                              });
                            })
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  _requestHappyCode() async {
    String token = await SharedPreferencesHelper().getToken();
    if (token != '') {
      showLoader();
      final Response response = await post(
        Uri.parse(AppUrl.requestCode),
        headers: <String, String>{'token': token},
        body: jsonEncode(<String, String>{'booking_id': widget.myServices.id}),
      );

      log('happy code: ' + jsonDecode(response.body).toString());
      if ((jsonDecode(response.body)['data'] == null)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Wrong Code'),
        ));
        Navigator.pop(dialogContext);
      } else {
        Navigator.pop(dialogContext);
        //showLoader(2);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An Error Occured."),
      ));
    }
  }

  String fileName = '';
  File? pickedFile;
  int imageVideo = -1;

  _finishService() async {
    String _code = happyCodeController.text;
    if (_code.isNotEmpty) {
      String token = await SharedPreferencesHelper().getToken();
      if (token != '') {
        showLoader();
        var mRequest = MultipartRequest("POST", Uri.parse(AppUrl.finish));
        mRequest.headers.addAll(<String, String>{"token": token});

        mRequest.fields['happy_code'] = _code;
        mRequest.fields['id'] = widget.myServices.id;
        if (fileName != '') {
          mRequest.files.add(MultipartFile(
              'media',
              File(pickedFile!.path.toString()).readAsBytes().asStream(),
              File(pickedFile!.path.toString()).lengthSync(),
              filename: pickedFile!.path.toString().split("/").last));
        }

        var response = await mRequest.send();

        if (response.statusCode == 200) {
          Timer(const Duration(seconds: 2), () {
            NavigationHelper().navigateTo(context, const ServiceFeedsScreen());
          });
        } else {
          //showLoader(2);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error'),
          ));
          Navigator.pop(dialogContext);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("An Error Occured."),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter a valid code."),
      ));
    }
  }

  pickFile(v) async {
    final ImagePicker _picker = ImagePicker();
    XFile? file;

    if (imageVideo == 1) {
      file = await _picker.pickImage(source: ImageSource.gallery);
    } else if (imageVideo == 2) {
      file = await _picker.pickVideo(source: ImageSource.gallery);
    }

    if (file != null) {
      v(() {
        pickedFile = File(file!.path);
        log(file.name);
        if (file.name.length > 10) {
          fileName = file.name.substring(0, 10);
        } else {
          fileName = file.name;
        }
      });
    } else {
      // User canceled the picker
    }
  }

  late BuildContext locationDailog;

  /* void _shareLocationDialog() {
    
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
                          if (widget.myServices.status == "2") {
                            Navigator.pop(locationDailog);
                          } else {
                            Navigator.pushReplacement(
                                buildContext,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ServiceFeedsScreen()));
                          }
                        })
                  ],
                ),
              ),
            ),
          );
        });
  } */

  _updateLocation(lattitude, longitude) async {
    NetworkCheckUp().checkConnection().then((value) async {
      if (value) {
        await getLocation();
        String token = await SharedPreferencesHelper().getToken();
        if (token != '') {
          final Response response = await post(
            Uri.parse(AppUrl.updateLocation),
            headers: <String, String>{'token': token},
            body: jsonEncode(<String, String>{
              "booking_id": widget.myServices.id,
              "lat": lattitude.toString(),
              "lng": longitude.toString(),
            }),
          );

          log(response.body);
          if ((jsonDecode(response.body)['data'] == null)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('AN ERROR OCCURED'),
            ));
            Navigator.pop(dialogContext);
          } else {
            log(response.body);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("An Error Occured."),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please connect to internet."),
        ));
      }
    });
  }
}
