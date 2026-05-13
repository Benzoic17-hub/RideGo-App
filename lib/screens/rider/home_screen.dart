import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'booking_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart' as profile;

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});
  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  int _currentIndex = 0;
  String _userName = '';
  String _currentLocation = 'Your location';
  List<Map<String, dynamic>> _savedLocations = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadLocation();
    _loadSavedLocations();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userName = prefs.getString('user_name') ?? 'Rider');
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('current_address') ?? '';
    if (saved.isNotEmpty) {
      setState(() => _currentLocation = saved.split(',')[0]);
    }
  }

  Future<void> _loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_locations');
    if (raw != null) {
      setState(() =>
          _savedLocations = List<Map<String, dynamic>>.from(jsonDecode(raw)));
    }
  }

  void _showLocationOptions() {
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
              const Text('YOUR LOCATION',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text(_currentLocation,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 20)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: const Text('Save location for future use',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  _savedLocations
                      .removeWhere((l) => l['name'] == _currentLocation);
                  _savedLocations.insert(0,
                      {'name': _currentLocation, 'address': _currentLocation});
                  if (_savedLocations.length > 5)
                    _savedLocations = _savedLocations.take(5).toList();
                  await prefs.setString(
                      'saved_locations', jsonEncode(_savedLocations));
                  setState(() {});
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Location saved!')));
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Change location',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _loadLocation();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share location',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('📍 $_currentLocation')));
                },
              ),
              const SizedBox(height: 16),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            userName: _userName,
            currentLocation: _currentLocation,
            savedLocations: _savedLocations,
            onLocationTap: _showLocationOptions,
          ),
          const RiderHistoryScreen(),
          const profile.RiderProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFFFFCC00),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'My Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String userName, currentLocation;
  final List<Map<String, dynamic>> savedLocations;
  final VoidCallback onLocationTap;

  const _HomeTab({
    required this.userName,
    required this.currentLocation,
    required this.savedLocations,
    required this.onLocationTap,
  });

  void _goToBooking(BuildContext context, String type, {String dest = ''}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BookingScreen(serviceType: type, prefilledDestination: dest),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'R';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          // ── Top Bar (Yango style) ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: const TextSpan(children: [
                        TextSpan(
                            text: 'Ride',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1a1a2e))),
                        TextSpan(
                            text: 'Go',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFCC00))),
                      ])),
                      GestureDetector(
                        onTap: onLocationTap,
                        child: Row(children: [
                          Flexible(
                              child: Text(currentLocation,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis)),
                          Icon(Icons.chevron_right,
                              size: 16, color: Colors.grey[600]),
                        ]),
                      ),
                    ]),
              ),
              CircleAvatar(
                backgroundColor: const Color(0xFFFFCC00),
                child: Text(initial,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              const SizedBox(width: 12),
              Icon(Icons.menu, color: Colors.grey[800]),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                // ── Service Cards (Yango style) ──
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _ServiceCard(
                        emoji: '🏍️',
                        label: 'Delivery',
                        sub: 'Fast & affordable',
                        onTap: () => _goToBooking(context, 'delivery'),
                      ),
                      _ServiceCard(
                        emoji: '🚗',
                        label: 'Rides',
                        sub: 'from 4 min',
                        active: true,
                        onTap: () => _goToBooking(context, 'taxi'),
                      ),
                      _ServiceCard(
                        emoji: '🚛',
                        label: 'Cargo',
                        sub: 'Heavy loads',
                        onTap: () => _goToBooking(context, 'cargo'),
                      ),
                      _ServiceCard(
                        emoji: '🛵',
                        label: 'Okada',
                        sub: 'Beat traffic',
                        onTap: () => _goToBooking(context, 'okada'),
                      ),
                    ],
                  ),
                ),

                // ── Where To Bar (Yango style) ──
                GestureDetector(
                  onTap: () => _goToBooking(context, 'taxi'),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 12),
                      const Expanded(
                          child: Text('Where to?',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF333333)))),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Saved Locations ──
                if (savedLocations.isNotEmpty) ...[
                  ...savedLocations.take(2).map((loc) => _RecentLocation(
                        icon: Icons.bookmark,
                        name: loc['name'] ?? '',
                        sub: loc['address'] ?? '',
                        onTap: () => _goToBooking(context, 'taxi',
                            dest: loc['address'] ?? ''),
                      )),
                ],

                // ── Recent/Quick Locations (Yango style) ──
                _RecentLocation(
                  icon: Icons.history,
                  name: 'Accra Mall',
                  sub: 'Spintex Road, Accra',
                  eta: '7 min',
                  onTap: () => _goToBooking(context, 'taxi',
                      dest: 'Accra Mall, Spintex Road, Accra'),
                ),
                _RecentLocation(
                  icon: Icons.history,
                  name: 'Kotoka Airport',
                  sub: 'Airport City, Accra',
                  eta: '13 min',
                  onTap: () => _goToBooking(context, 'taxi',
                      dest: 'Kotoka International Airport, Accra'),
                ),
                _RecentLocation(
                  icon: Icons.history,
                  name: 'University of Ghana',
                  sub: 'Legon, Accra',
                  eta: '20 min',
                  onTap: () => _goToBooking(context, 'taxi',
                      dest: 'University of Ghana, Legon'),
                ),
                const SizedBox(height: 12),

                // ── Promo Banners (Yango style) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Expanded(
                        child: _PromoBanner(
                      title: 'BECOME\nA DRIVER',
                      sub: 'and earn up to\n7 000 GHC\nper week',
                      color1: const Color(0xFF1a1a2e),
                      color2: const Color(0xFF16213e),
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _PromoBanner(
                      title: 'BEAT\nTHE TRAFFIC',
                      sub: 'Request Okada. With\n20% OFF\nfirst 3 rides',
                      color1: const Color(0xFF2d2d2d),
                      color2: const Color(0xFF1a1a1a),
                    )),
                  ]),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Expanded(
                        child: _PromoBanner(
                      title: 'DISCOVER\nDELIVERY\nIN KUMASI',
                      sub: '',
                      color1: Colors.white,
                      color2: Colors.white,
                      textColor: Colors.black,
                      hasBorder: true,
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _PromoBanner(
                      title: 'LARGE\nLOADS?',
                      sub: 'Order Cargo Delivery',
                      color1: const Color(0xFFe63946),
                      color2: const Color(0xFFc1121f),
                    )),
                  ]),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String emoji, label, sub;
  final bool active;
  final VoidCallback onTap;
  const _ServiceCard(
      {required this.emoji,
      required this.label,
      required this.sub,
      required this.onTap,
      this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(height: 6),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          if (active)
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11))
          else
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ]),
      ),
    );
  }
}

class _RecentLocation extends StatelessWidget {
  final IconData icon;
  final String name, sub;
  final String? eta;
  final VoidCallback onTap;
  const _RecentLocation(
      {required this.icon,
      required this.name,
      required this.sub,
      required this.onTap,
      this.eta});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: Colors.grey[100],
            radius: 20,
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(sub,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ])),
          if (eta != null)
            Text(eta!,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87)),
        ]),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  final String title, sub;
  final Color color1, color2;
  final Color textColor;
  final bool hasBorder;
  const _PromoBanner(
      {required this.title,
      required this.sub,
      required this.color1,
      required this.color2,
      this.textColor = Colors.white,
      this.hasBorder = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: hasBorder ? Border.all(color: Colors.grey[200]!) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                height: 1.2)),
        if (sub.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(sub,
              style: TextStyle(
                  color: textColor == Colors.white
                      ? Colors.white70
                      : Colors.grey[600],
                  fontSize: 11,
                  height: 1.4)),
        ],
      ]),
    );
  }
}
