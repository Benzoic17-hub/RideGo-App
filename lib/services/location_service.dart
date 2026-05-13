import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {'error': 'Please enable location services'};
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {'error': 'Location permission denied'};
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {'error': 'Location permissions are permanently denied'};
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      return {
        'success': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': '${place.street ?? ''}, ${place.locality}, ${place.country}',
      };
    } catch (e) {
      return {'success': false, 'error': 'Please enable location services'};
    }
  }
}
