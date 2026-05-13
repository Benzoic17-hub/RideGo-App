import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final String serviceType;
  final String prefilledDestination;
  const BookingScreen(
      {super.key, required this.serviceType, this.prefilledDestination = ''});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _destCtrl = TextEditingController();
  final _pickupCtrl = TextEditingController();
  final _mapCtrl = MapController();

  LatLng? _pickupLatLng;
  LatLng? _destLatLng;
  List<LatLng> _routePoints = [];
  List<Map<String, dynamic>> _suggestions = [];
  bool _searchingDest = false;
  bool _calculating = false;
  bool _booking = false;
  double _distanceKm = 0;
  int _etaMinutes = 0;
  String _selectedVehicle = 'Economy';
  String _selectedPayment = 'MoMo';
  Timer? _debounce;
  String _serviceTab = 'Taxi';

  // Ghana pricing
  final Map<String, Map<String, double>> _pricing = {
    'Fastest': {'base': 5.0, 'perKm': 2.50},
    'Economy': {'base': 4.0, 'perKm': 2.00},
    'Comfort': {'base': 6.0, 'perKm': 3.00},
    'Okada': {'base': 3.0, 'perKm': 1.50},
    'Delivery': {'base': 4.0, 'perKm': 1.80},
    'Cargo': {'base': 8.0, 'perKm': 3.50},
  };

  @override
  void initState() {
    super.initState();
    _serviceTab = widget.serviceType == 'taxi'
        ? 'Taxi'
        : widget.serviceType == 'delivery'
            ? 'Delivery & Cargo'
            : widget.serviceType == 'cargo'
                ? 'Delivery & Cargo'
                : 'Other';
    if (widget.prefilledDestination.isNotEmpty) {
      _destCtrl.text = widget.prefilledDestination;
    }
    _initLocation();
  }

  @override
  void dispose() {
    _destCtrl.dispose();
    _pickupCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('current_lat');
    final lng = prefs.getDouble('current_lng');
    final addr = prefs.getString('current_address') ?? 'Your Location';
    if (lat != null && lng != null) {
      setState(() {
        _pickupLatLng = LatLng(lat, lng);
        _pickupCtrl.text = addr.split(',')[0];
      });
      if (widget.prefilledDestination.isNotEmpty) {
        await _geocodeDestination(widget.prefilledDestination);
      }
    } else {
      await _getLocation();
    }
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied)
        perm = await Geolocator.requestPermission();
      final pos = await Geolocator.getCurrentPosition();
      final res = await http.get(
          Uri.parse(
              'https://nominatim.openstreetmap.org/reverse?lat=${pos.latitude}&lon=${pos.longitude}&format=json'),
          headers: {'User-Agent': 'RideGoApp/1.0'});
      final data = jsonDecode(res.body);
      final addr = data['address'];
      final name =
          addr['road'] ?? addr['suburb'] ?? addr['city'] ?? 'Your Location';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('current_lat', pos.latitude);
      await prefs.setDouble('current_lng', pos.longitude);
      await prefs.setString('current_address', data['display_name'] ?? name);
      setState(() {
        _pickupLatLng = LatLng(pos.latitude, pos.longitude);
        _pickupCtrl.text = name;
      });
      if (widget.prefilledDestination.isNotEmpty) {
        await _geocodeDestination(widget.prefilledDestination);
      }
    } catch (e) {
      setState(() {
        _pickupLatLng = const LatLng(5.6037, -0.1870);
        _pickupCtrl.text = 'Accra, Ghana';
      });
    }
  }

  Future<void> _geocodeDestination(String query) async {
    try {
      final res = await http.get(
          Uri.parse(
              'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent("$query, Ghana")}&format=json&limit=1&countrycodes=gh'),
          headers: {'User-Agent': 'RideGoApp/1.0'});
      final data = jsonDecode(res.body) as List;
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lng = double.parse(data[0]['lon']);
        setState(() {
          _destLatLng = LatLng(lat, lng);
          _destCtrl.text = query;
        });
        await _calculateRoute();
      }
    } catch (_) {}
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    try {
      final res = await http.get(
          Uri.parse(
              'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent("$query, Ghana")}&format=json&limit=6&countrycodes=gh&addressdetails=1'),
          headers: {'User-Agent': 'RideGoApp/1.0'});
      final data = jsonDecode(res.body) as List;
      setState(() {
        _suggestions = data
            .map((e) => {
                  'name': e['display_name'].toString().split(',')[0],
                  'address': e['display_name'],
                  'lat': double.parse(e['lat']),
                  'lng': double.parse(e['lon']),
                  'type': e['type'] ?? 'place',
                })
            .toList();
      });
    } catch (_) {
      setState(() => _suggestions = []);
    }
  }

  Future<void> _calculateRoute() async {
    if (_pickupLatLng == null || _destLatLng == null) return;
    setState(() {
      _calculating = true;
      _routePoints = [];
    });
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${_pickupLatLng!.longitude},${_pickupLatLng!.latitude};'
          '${_destLatLng!.longitude},${_destLatLng!.latitude}'
          '?overview=full&geometries=geojson';
      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final distM = route['distance'] as num;
        final durS = route['duration'] as num;
        final coords = route['geometry']['coordinates'] as List;
        setState(() {
          _distanceKm = distM / 1000;
          _etaMinutes = (durS / 60).round();
          _routePoints = coords
              .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
              .toList();
          _calculating = false;
        });
        // Fit map to show full route
        if (_routePoints.isNotEmpty) {
          final bounds = LatLngBounds.fromPoints(_routePoints);
          _mapCtrl.fitCamera(CameraFit.bounds(
              bounds: bounds, padding: const EdgeInsets.all(60)));
        }
      }
    } catch (_) {
      if (_pickupLatLng != null && _destLatLng != null) {
        final dist = const Distance()
            .as(LengthUnit.Kilometer, _pickupLatLng!, _destLatLng!);
        setState(() {
          _distanceKm = dist;
          _etaMinutes = (dist * 3).round();
          _calculating = false;
        });
      }
    }
  }

  double _getFare(String vehicle) {
    final p = _pricing[vehicle] ?? {'base': 4.0, 'perKm': 2.0};
    return (p['base']! + (_distanceKm * p['perKm']!));
  }

  String _arriveTime() {
    final now = DateTime.now();
    final arrive = now.add(Duration(minutes: _etaMinutes));
    final h = arrive.hour > 12
        ? arrive.hour - 12
        : arrive.hour == 0
            ? 12
            : arrive.hour;
    final m = arrive.minute.toString().padLeft(2, '0');
    final ampm = arrive.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  Future<void> _bookRide() async {
    if (_pickupLatLng == null || _destLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your destination')));
      return;
    }
    setState(() => _booking = true);
    final fare = _getFare(_selectedVehicle);
    final data = await ApiService.bookRide(
      pickupAddress: _pickupCtrl.text,
      destinationAddress: _destCtrl.text,
      fare: fare,
      rideClass: _selectedVehicle,
      serviceType: widget.serviceType,
      pickupLat: _pickupLatLng!.latitude,
      pickupLng: _pickupLatLng!.longitude,
      destLat: _destLatLng!.latitude,
      destLng: _destLatLng!.longitude,
    );
    setState(() => _booking = false);
    if (data['success'] == true) {
      if (mounted) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text('🎉 Ride Requested!'),
                  content: Text(
                      'Looking for a driver near you...\n\nFare: GHC ${fare.toStringAsFixed(2)}\nDistance: ${_distanceKm.toStringAsFixed(1)} km'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('OK'))
                  ],
                ));
      }
    } else {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message'] ?? 'Booking failed'),
            backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRoute = _distanceKm > 0 && _routePoints.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // ── Full Screen Map ──
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _pickupLatLng ?? const LatLng(5.6037, -0.1870),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ridego.app',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(
                      points: _routePoints,
                      color: Colors.green,
                      strokeWidth: 5),
                ]),
              MarkerLayer(markers: [
                if (_pickupLatLng != null)
                  Marker(
                    point: _pickupLatLng!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location,
                        color: Colors.blue, size: 32),
                  ),
                if (_destLatLng != null)
                  Marker(
                    point: _destLatLng!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin,
                        color: Colors.red, size: 40),
                  ),
              ]),
            ],
          ),

          // ── ETA Bubble ──
          if (hasRoute)
            Positioned(
              top: 100,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  Text('$_etaMinutes',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18)),
                  const Text('min',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ]),
              ),
            ),

          // ── Arrive Time ──
          if (hasRoute)
            Positioned(
              bottom: 340,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1), blurRadius: 8)
                    ]),
                child: Text('arrive at ${_arriveTime()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),

          // ── Back Button ──
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1), blurRadius: 8)
                    ]),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),

          // ── Bottom Sheet ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2))),

                  // ── Pickup & Destination ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(children: [
                      // Pickup
                      Row(children: [
                        const Icon(Icons.person_pin_circle,
                            color: Colors.black87, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(
                                _pickupCtrl.text.isNotEmpty
                                    ? _pickupCtrl.text
                                    : 'Your Location',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15))),
                      ]),
                      const Divider(height: 16),
                      // Destination
                      Row(children: [
                        const CircleAvatar(
                            backgroundColor: Color(0xFFFFCC00),
                            radius: 11,
                            child: Icon(Icons.flag,
                                size: 14, color: Colors.black)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: TextField(
                          controller: _destCtrl,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Where to?',
                            hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.normal),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (v) {
                            _debounce?.cancel();
                            _debounce = Timer(const Duration(milliseconds: 500),
                                () => _searchPlaces(v));
                          },
                        )),
                        if (_destCtrl.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _destCtrl.clear();
                                _suggestions = [];
                                _destLatLng = null;
                                _routePoints = [];
                                _distanceKm = 0;
                              });
                            },
                            child: const Icon(Icons.close,
                                size: 18, color: Colors.grey),
                          ),
                      ]),
                    ]),
                  ),

                  // ── Search Suggestions ──
                  if (_suggestions.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final s = _suggestions[i];
                          final type = s['type'].toString();
                          final icon = type == 'bus_stop'
                              ? Icons.directions_bus
                              : type == 'aerodrome'
                                  ? Icons.flight
                                  : type == 'marketplace'
                                      ? Icons.store
                                      : Icons.location_on;
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[100],
                              radius: 18,
                              child:
                                  Icon(icon, size: 16, color: Colors.grey[700]),
                            ),
                            title: Text(s['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(
                                s['address']
                                    .toString()
                                    .split(',')
                                    .take(3)
                                    .join(','),
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            onTap: () async {
                              setState(() {
                                _destCtrl.text = s['name'];
                                _destLatLng = LatLng(s['lat'], s['lng']);
                                _suggestions = [];
                              });
                              await _calculateRoute();
                            },
                          );
                        },
                      ),
                    ),

                  if (_suggestions.isEmpty && _distanceKm > 0) ...[
                    // ── Service Tabs ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                          children:
                              ['Taxi', 'Delivery & Cargo', 'Other'].map((tab) {
                        final active = _serviceTab == tab;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _serviceTab = tab;
                            _selectedVehicle = tab == 'Taxi'
                                ? 'Economy'
                                : tab == 'Delivery & Cargo'
                                    ? 'Delivery'
                                    : 'Economy';
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: active ? Colors.black : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(tab,
                                style: TextStyle(
                                    color:
                                        active ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ),
                        );
                      }).toList()),
                    ),

                    // ── Vehicle Cards ──
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: _getVehicles().map((v) {
                          final name = v['name'] ?? '';
                          final emoji = v['emoji'] ?? '';
                          final selected = _selectedVehicle == name;
                          final fare = _getFare(name);
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedVehicle = name),
                            child: Container(
                              width: 110,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFFFFDF0)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: selected
                                        ? const Color(0xFFFFCC00)
                                        : Colors.grey[200]!,
                                    width: selected ? 2 : 1),
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(emoji,
                                        style: const TextStyle(fontSize: 22)),
                                    const SizedBox(height: 4),
                                    Text(name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12)),
                                    Text('$_etaMinutes min',
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 10)),
                                    Text('GHC ${fare.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                            color: Color(0xFF1a1a2e))),
                                  ]),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // ── Selected + Distance ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Row(children: [
                        const Icon(Icons.check_circle,
                            color: Color(0xFFFFCC00), size: 18),
                        const SizedBox(width: 8),
                        Text(
                            'You\'ve chosen $_selectedVehicle · GHC ${_getFare(_selectedVehicle).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const Spacer(),
                        Text('${_distanceKm.toStringAsFixed(1)} km',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                      ]),
                    ),

                    // ── Payment + Book ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: Row(children: [
                        // Payment selector
                        GestureDetector(
                          onTap: _showPaymentOptions,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFFFCC00), width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(children: [
                              Text(_getPaymentEmoji(),
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(_selectedPayment,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Request button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _booking ? null : _bookRide,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCC00),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _booking
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.black, strokeWidth: 2))
                                : const Text('REQUEST RIDE',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15)),
                          ),
                        ),
                      ]),
                    ),
                  ] else if (_calculating) ...[
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFFFFCC00))),
                            SizedBox(width: 12),
                            Text('Calculating route...',
                                style: TextStyle(color: Colors.grey)),
                          ]),
                    ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Type your destination above',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getVehicles() {
    if (_serviceTab == 'Delivery & Cargo') {
      return [
        {'name': 'Delivery', 'emoji': '🏍️'},
        {'name': 'Cargo', 'emoji': '🚛'},
      ];
    }
    if (_serviceTab == 'Other') {
      return [
        {'name': 'Okada', 'emoji': '🛵'},
      ];
    }
    return [
      {'name': 'Fastest', 'emoji': '🚗'},
      {'name': 'Economy', 'emoji': '🚙'},
      {'name': 'Comfort', 'emoji': '🚘'},
      {'name': 'Okada', 'emoji': '🛵'},
    ];
  }

  String _getPaymentEmoji() {
    switch (_selectedPayment) {
      case 'MTN MoMo':
        return '📱';
      case 'Telecel Cash':
        return '📱';
      case 'AirtelTigo':
        return '📱';
      case 'Ghana Pay':
        return '🏦';
      case 'Cash':
        return '💵';
      default:
        return '📱';
    }
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Method',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 16),
              ...[
                {
                  'name': 'MTN MoMo',
                  'emoji': '📱',
                  'color': Colors.yellow[700]!
                },
                {'name': 'Telecel Cash', 'emoji': '📱', 'color': Colors.red},
                {
                  'name': 'AirtelTigo',
                  'emoji': '📱',
                  'color': Colors.red[900]!
                },
                {'name': 'Ghana Pay', 'emoji': '🏦', 'color': Colors.blue},
                {'name': 'Cash', 'emoji': '💵', 'color': Colors.green},
              ].map((p) {
                final selected = _selectedPayment == p['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedPayment = p['name'] as String);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color:
                          selected ? const Color(0xFFFFFDF0) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected
                              ? const Color(0xFFFFCC00)
                              : Colors.transparent,
                          width: 2),
                    ),
                    child: Row(children: [
                      Text(p['emoji'] as String,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 16),
                      Text(p['name'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const Spacer(),
                      if (selected)
                        const Icon(Icons.check_circle,
                            color: Color(0xFFFFCC00)),
                    ]),
                  ),
                );
              }).toList(),
            ]),
      ),
    );
  }
}
