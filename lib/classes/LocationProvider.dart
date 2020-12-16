import 'package:location/location.dart';

class LocationProvider {
  static void getLocation({Function toUse}) async {
    await Location().requestPermission();
    Location().onLocationChanged().listen((location) {
      toUse(location);
    });
  }
}
