import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../services/location_service.dart';

class MapScreen extends StatefulWidget {
  final String serviceType;
  final String? initialDestination;

  const MapScreen({
    super.key,
    required this.serviceType,
    this.initialDestination,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;

  LatLng? _userLocation;
  LatLng? _destination;

  List<LatLng> _routePoints = [];
  double _distance = 0;
  String _duration = "";

  final TextEditingController _searchController = TextEditingController();

  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ FIXED: SAFE LOCATION LOAD
  Future<void> _loadLocation() async {
    final loc = await LocationService.getCurrentLocation();

    if (!mounted) return;

    if (loc['success'] == true) {
      final latLng = LatLng(loc['lat'], loc['lng']);

      setState(() {
        _userLocation = latLng;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _mapController.move(latLng, 15);
        }
      });
    }
  }

  // 🔍 SEARCH PLACE
  Future<void> _searchPlace(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}, Ghana&format=json&limit=1";

    final res = await http
        .get(Uri.parse(url), headers: {'User-Agent': 'RideGoApp/1.0'});

    final data = json.decode(res.body);

    if (data.isNotEmpty) {
      final place = data[0];
      final lat = double.parse(place['lat']);
      final lon = double.parse(place['lon']);

      final dest = LatLng(lat, lon);

      setState(() {
        _destination = dest;
      });

      _mapController.move(dest, 14);

      await _getRoute();
    }
  }

  // 🛣️ FIXED ROUTE SYSTEM (OSRM HTTPS)
  Future<void> _getRoute() async {
    if (_userLocation == null || _destination == null) return;

    setState(() => _isLoadingRoute = true);

    try {
      final url =
          "https://router.project-osrm.org/route/v1/driving/${_userLocation!.longitude},${_userLocation!.latitude};${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=geojson";

      final res = await http.get(Uri.parse(url));

      final data = json.decode(res.body);

      final route = data['routes'][0];

      final coords = route['geometry']['coordinates'] as List;

      List<LatLng> points = coords.map((e) => LatLng(e[1], e[0])).toList();

      setState(() {
        _routePoints = points;
        _distance = route['distance'] / 1000;
        _duration = (route['duration'] / 60).toStringAsFixed(0) + " min";
      });

      // ✅ CENTER MAP TO ROUTE
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(50),
        ),
      );
    } catch (e) {
      debugPrint("Route error: $e");
    }

    setState(() => _isLoadingRoute = false);
  }

  // ✅ CONFIRM
  void _confirmLocation() {
    Navigator.pop(context, {
      'pickup': _userLocation,
      'destination': _destination,
      'distance': _distance,
      'duration': _duration,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 🗺️ MAP (FIXED TILE LOADING)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation!,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName:
                    "com.example.ridego_app", // 🔥 FIX 403 ERROR
              ),

              // ROUTE LINE
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5,
                      color: Colors.black,
                    )
                  ],
                ),

              // USER MARKER
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location,
                        color: Colors.blue, size: 30),
                  ),
                  if (_destination != null)
                    Marker(
                      point: _destination!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on,
                          color: Colors.red, size: 35),
                    ),
                ],
              ),
            ],
          ),

          // 🔍 SEARCH BAR
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: TextField(
              controller: _searchController,
              onSubmitted: _searchPlace,
              decoration: InputDecoration(
                hintText: "Where to?",
                filled: true,
                fillColor: Colors.white,
                suffixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // 📊 ROUTE INFO
          if (_distance > 0)
            Positioned(
              bottom: 120,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  "${_distance.toStringAsFixed(1)} km • $_duration",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

          // ⏳ LOADING
          if (_isLoadingRoute) const Center(child: CircularProgressIndicator()),

          // ✅ CONFIRM BUTTON
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _confirmLocation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFFFFCC00),
              ),
              child: const Text(
                "Confirm Location",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
