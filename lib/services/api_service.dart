import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.198:8000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ══════════════════════════════════════════════════════════
  // AUTH
  // ══════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> riderLogin(
      String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/rider/login'),
            headers: await _headers(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed. Check your network.'
      };
    }
  }

  static Future<Map<String, dynamic>> riderRegister(
      String name, String email, String phone, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/rider/register'),
            headers: await _headers(),
            body: jsonEncode({
              'name': name,
              'email': email,
              'phone': phone,
              'password': password
            }),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed. Check your network.'
      };
    }
  }

  static Future<Map<String, dynamic>> driverLogin(
      String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/driver/login'),
            headers: await _headers(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed. Check your network.'
      };
    }
  }

  static Future<Map<String, dynamic>> driverRegister(
    String name,
    String email,
    String phone,
    String password,
    String license,
    String carMake,
    String carModel,
    String carYear,
    String carPlate,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/driver/register'),
            headers: await _headers(),
            body: jsonEncode({
              'name': name,
              'email': email,
              'phone': phone,
              'password': password,
              'license_number': license,
              'car_make': carMake,
              'car_model': carModel,
              'car_year': carYear,
              'car_plate': carPlate,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed. Check your network.'
      };
    }
  }

  static Future<void> logout() async {
    try {
      await http.post(Uri.parse('$baseUrl/logout'), headers: await _headers());
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ══════════════════════════════════════════════════════════
  // RIDES — FIXED to match booking_screen.dart parameters
  // ══════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> bookRide({
    required String pickupAddress,
    required String destinationAddress,
    required double fare,
    required String rideClass,
    String serviceType = 'taxi',
    double? pickupLat,
    double? pickupLng,
    double? destLat,
    double? destLng,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/ride/book'),
            headers: await _headers(),
            body: jsonEncode({
              'pickup_address': pickupAddress,
              'destination_address': destinationAddress,
              'fare': fare,
              'ride_class': rideClass,
              'service_type': serviceType,
              if (pickupLat != null) 'pickup_lat': pickupLat,
              if (pickupLng != null) 'pickup_lng': pickupLng,
              if (destLat != null) 'destination_lat': destLat,
              if (destLng != null) 'destination_lng': destLng,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection failed.'};
    }
  }

  static Future<Map<String, dynamic>> getRideStatus(int rideId) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/ride/$rideId/status'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> cancelRide(int rideId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/ride/$rideId/cancel'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<List<dynamic>> getRideHistory() async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/rider/history'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      return data['rides'] ?? [];
    } catch (e) {
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════
  // DRIVER
  // ══════════════════════════════════════════════════════════

  static Future<List<dynamic>> getAvailableRides() async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/driver/rides'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      return data['rides'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> acceptRide(int rideId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/driver/ride/$rideId/accept'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> updateRideStatus(int rideId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/driver/ride/$rideId/status'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<void> updateLocation(double lat, double lng) async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl/driver/location'),
            headers: await _headers(),
            body: jsonEncode({'lat': lat, 'lng': lng}),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> getDriverEarnings() async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/driver/earnings'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {
        'success': false,
        'total_earnings': 0,
        'total_trips': 0,
        'rides': []
      };
    }
  }

  static Future<Map<String, dynamic>> getActiveRide() async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/driver/active-ride'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'ride': null};
    }
  }
}
