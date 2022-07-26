import 'dart:developer';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher/src/models.dart' as mt;

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    /* String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude%2C$longitude';
    log(googleUrl);
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
      log('launched');
    } else {
      log('error');
      throw 'Could not open the map.';
    } */

    if (await MapLauncher.isMapAvailable(mt.MapType.google) == true) {
      await MapLauncher.showMarker(
          mapType: mt.MapType.google,
          coords: Coords(latitude, longitude),
          title: 'User Location');
    } else {
      log('error');
      throw 'Could not open the map.';
    }
  }
}
