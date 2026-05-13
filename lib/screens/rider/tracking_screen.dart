import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/api_service.dart';

class TrackingScreen extends StatefulWidget {
  final String rideId;
  const TrackingScreen({super.key, required this.rideId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Timer? _timer;
  Map<String, dynamic>? _rideData;
  LatLng _driverPos = LatLng(5.6037, -0.1870); // Default Accra
  final MapController _mapController = MapController();
  bool _driverAccepted = false;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    // Poll every 4 seconds to check if a driver accepted or moved
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _refreshRideStatus();
    });
  }

  Future<void> _refreshRideStatus() async {
    try {
      final data = await ApiService.getRideDetails(widget.rideId);

      if (data['success'] == true) {
        setState(() {
          _rideData = data['ride'];

          // 1. Update Driver Position
          if (_rideData!['driver_lat'] != null &&
              _rideData!['driver_lng'] != null) {
            _driverPos = LatLng(
                double.parse(_rideData!['driver_lat'].toString()),
                double.parse(_rideData!['driver_lng'].toString()));

            // Move map to follow the driver
            _mapController.move(_driverPos, 15.0);
          }

          // 2. Update Acceptance Status
          String status = _rideData!['status'] ?? 'pending';
          if (status == 'accepted' ||
              status == 'on_the_way' ||
              status == 'arrived') {
            _driverAccepted = true;
          }
        });
      }
    } catch (e) {
      debugPrint("Tracking Error: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. LIVE MAP (V6.1.0 Syntax)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _driverPos,
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ridego',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _driverPos,
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.directions_car,
                      color: _driverAccepted ? Colors.blue : Colors.grey,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. TOP BAR (BACK BUTTON) - FIXED HERE
          Positioned(
            top: 50,
            left: 20,
            child: Material(
              // Wrap with Material to provide elevation
              elevation: 4,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // 3. BOTTOM INFO PANEL
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_driverAccepted) ...[
                    const LinearProgressIndicator(color: Colors.orange),
                    const SizedBox(height: 15),
                    const Text(
                      "Searching for nearby drivers...",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Text("Usually takes less than a minute",
                        style: TextStyle(color: Colors.grey)),
                  ] else ...[
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.orange,
                          child:
                              Icon(Icons.person, color: Colors.white, size: 35),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _rideData?['driver_name'] ?? "Driver Found",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                _rideData?['car_model'] ??
                                    "Toyota Vitz (White)",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(0.1),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.call, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Driver is arriving in 4 mins",
                          style: TextStyle(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
