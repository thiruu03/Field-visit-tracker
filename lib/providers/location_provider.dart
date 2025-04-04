import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class LocationProvider extends ChangeNotifier {
  InternetConnectionChecker internetConnectionChecker =
      InternetConnectionChecker.instance;

  Future<bool> isInternetAvailable() async {
    return await internetConnectionChecker.hasConnection;
  }

  //get location name
  Future<String> getLocationName(double lat, double long) async {
    if (!await isInternetAvailable()) {
      print("No Internet Connection");
      return 'No internet connection';
    }
    try {
      if (lat == 0.0 && long == 0.0) {
        print("Invalid coordinates format.");
        return 'Invalid coordinates';
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        print("Location Found: ${place.street}, ${place.locality}");
        return "${place.locality}.";
      } else {
        return 'Location not detected';
      }
    } catch (e) {
      print("Error fetching location: $e");
      return 'Unknown location';
    }
  }
}
