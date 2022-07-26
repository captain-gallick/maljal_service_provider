import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:maljal_service_provider/constants/app_urls.dart';
import 'package:maljal_service_provider/screens/service_feeds.dart';
import 'package:maljal_service_provider/utils/map_utils.dart';
import 'package:maljal_service_provider/utils/my_navigator.dart';
import 'package:maljal_service_provider/utils/shared_preferences.dart';

class TrackerScreen extends StatefulWidget {
  final String userLat, userLng, id, rt;
  const TrackerScreen(
      {Key? key,
      required this.userLat,
      required this.userLng,
      required this.id,
      required this.rt})
      : super(key: key);

  @override
  _TrackerScreenState createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen>
    with WidgetsBindingObserver {
  late CameraPosition initialLoaction =
      const CameraPosition(target: LatLng(27, 78), zoom: 14.47);
  late Marker userLocationMarker = const Marker(markerId: MarkerId('user'));
  late Marker vendorLocationMarker = const Marker(markerId: MarkerId('vendor'));
  late GoogleMapController _mapController;
  late BuildContext waitDialogContext, buildContext;

  @override
  void dispose() {
    _mapController.dispose();
    locationTimer.cancel();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    //WidgetsBinding.instance?.addPostFrameCallback((_) => markUserLocation());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      super.didChangeAppLifecycleState(state);

      // These are the callbacks
      switch (state) {
        case AppLifecycleState.resumed:
          setState(() {});
          // widget is resumed
          break;
        case AppLifecycleState.inactive:
          // widget is inactive
          break;
        case AppLifecycleState.paused:
          locationTimer = Timer.periodic(
              const Duration(seconds: 10), (Timer t) => _updateLocation());
          // widget is paused
          break;
        case AppLifecycleState.detached:
          // widget is detached
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          locationTimer.cancel();
          if (widget.rt == 'new') {
            NavigationHelper().navigateTo(context, const ServiceFeedsScreen());
          } else {
            NavigationHelper().closeTempScreen(context);
          }
          return false;
        },
        child: Scaffold(
          body: GoogleMap(
            initialCameraPosition: initialLoaction,
            mapType: MapType.normal,
            markers: {vendorLocationMarker, userLocationMarker},
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              markUserLocation();
              //getVendorLocation();
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            tooltip: 'OPEN MAPS',
            label: const Text('OPEN MAPS'),
            icon: const Icon(Icons.map),
            onPressed: () {
              try {
                MapUtils.openMap(
                    double.parse(widget.userLat), double.parse(widget.userLng));
                //    double.parse(widget.userLat), double.parse(widget.userLng));
                //Navigator.pop(context);
              } catch (e) {
                log(e.toString());
              }
            },
          ),
        ),
      ),
    );
  }

  markUserLocation() async {
    LatLng latLng =
        LatLng(double.parse(widget.userLat), double.parse(widget.userLng));
    await _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 14.0)));
    _addMarker(latLng);
  }

  _addMarker(LatLng pos) async {
    log(pos.longitude.toString() + '---' + pos.latitude.toString());
    try {
      setState(() {
        userLocationMarker = Marker(
          markerId: const MarkerId('user'),
          infoWindow: const InfoWindow(title: 'User location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: pos,
        );
      });
    } catch (e) {
      log(e.toString());
    }

    locationTimer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => _updateLocation());
    //Navigator.pop(waitDialogContext);
  }

  late Timer locationTimer;

  _addVendorMarker(LatLng pos) async {
    try {
      setState(() {
        vendorLocationMarker = Marker(
          markerId: const MarkerId('vendor'),
          infoWindow: const InfoWindow(title: 'Your location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
      });
    } catch (e) {
      log(e.toString());
    }

    //Navigator.pop(waitDialogContext);
  }

  getVendorLocation() async {
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
    LatLng latLng =
        LatLng(_locationData.longitude ?? 0, _locationData.longitude ?? 0);
    //_addVendorMarker(latLng);
  }

  late LocationData _locationData;

  _updateLocation() async {
    await getVendorLocation();
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
      } else {
        log(response.body);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An Error Occured."),
      ));
    }
  }
}
