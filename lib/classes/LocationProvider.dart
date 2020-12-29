import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider {

  static void getLocation({Function toUse}) async {
    await Location().requestPermission();
    Location().onLocationChanged().listen((location) {
      toUse(location);
    });
  }

  static Future<LatLng> getCurrentLocation() async {
    LocationData l = await Location().getLocation();
    return LatLng(l.latitude, l.longitude);
  }
}
