import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

// ══════════════════════════════════════════════════════════════
// DRIVER LOGIN SCREEN
// ══════════════════════════════════════════════════════════════
class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});
  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }
    setState(() => _loading = true);
    final data =
        await ApiService.driverLogin(_email.text.trim(), _password.text);
    setState(() => _loading = false);

    if (data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user_type', 'driver');
      await prefs.setString('driver_name', data['driver']['name'] ?? '');
      await prefs.setString('driver_id', data['driver']['id'].toString());
      if (mounted)
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DriverHomeScreen()));
    } else {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message'] ?? 'Login failed'),
            backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          RichText(
              text: const TextSpan(children: [
            TextSpan(
                text: 'Driver Login\n',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
            TextSpan(
                text: 'Welcome back to ',
                style: TextStyle(fontSize: 16, color: Colors.white54)),
            TextSpan(
                text: 'RideGo',
                style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFFCC00),
                    fontWeight: FontWeight.bold)),
          ])),
          const SizedBox(height: 40),
          _field(_email, 'Email address', Icons.email_outlined,
              type: TextInputType.emailAddress),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: _obscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon:
                    const Icon(Icons.lock_outline, color: Color(0xFFFFCC00)),
                suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white38),
                    onPressed: () => setState(() => _obscure = !_obscure)),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2))
                  : const Text('Login',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
              child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Don't have an account? Register",
                style: TextStyle(color: Color(0xFFFFCC00))),
          )),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
      {TextInputType? type}) {
    return TextField(
      controller: c,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: const Color(0xFFFFCC00)),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none)),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DRIVER HOME SCREEN
// ══════════════════════════════════════════════════════════════
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});
  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: const [
        DriverDashboard(),
        DriverEarningsScreen(),
        DriverProfileScreen(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        selectedItemColor: const Color(0xFFFFCC00),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DRIVER DASHBOARD
// ══════════════════════════════════════════════════════════════
class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});
  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  String _driverName = '';
  bool _isOnline = false;
  List<dynamic> _rides = [];
  bool _loading = true;
  Timer? _timer;
  double _todayEarnings = 0;
  int _todayTrips = 0;

  @override
  void initState() {
    super.initState();
    _loadDriver();
    _loadRides();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _loadRides());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDriver() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _driverName = prefs.getString('driver_name') ?? 'Driver';
      _isOnline = prefs.getBool('driver_online') ?? false;
    });
  }

  Future<void> _loadRides() async {
    final rides = await ApiService.getAvailableRides();
    final earnings = await ApiService.getDriverEarnings();
    setState(() {
      _rides = rides;
      _loading = false;
      _todayEarnings = (earnings['today_earnings'] ?? 0).toDouble();
      _todayTrips = earnings['today_trips'] ?? 0;
    });
  }

  Future<void> _toggleOnline() async {
    final prefs = await SharedPreferences.getInstance();
    final newStatus = !_isOnline;
    await prefs.setBool('driver_online', newStatus);
    setState(() => _isOnline = newStatus);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            newStatus ? '🟢 You are now Online' : '🔴 You are now Offline'),
        backgroundColor: newStatus ? Colors.green : Colors.red));
  }

  Future<void> _acceptRide(int rideId) async {
    final data = await ApiService.acceptRide(rideId);
    if (data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Ride accepted!'), backgroundColor: Colors.green));
      _loadRides();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Failed'),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(children: [
          // ── Top Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF1a1a2e), Color(0xFF16213e)]),
            ),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(
                    text: const TextSpan(children: [
                  TextSpan(
                      text: 'Ride',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  TextSpan(
                      text: 'Go ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFCC00))),
                  TextSpan(
                      text: 'Driver',
                      style: TextStyle(fontSize: 16, color: Colors.white70)),
                ])),
                Text('Welcome, $_driverName',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 13)),
              ]),
              const Spacer(),
              // Online Toggle
              Row(children: [
                Text(_isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                        color: _isOnline ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _toggleOnline,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 52,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _isOnline
                          ? const Color(0xFFFFCC00)
                          : Colors.grey[600],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      alignment: _isOnline
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ),
              ]),
            ]),
          ),

          // ── Today Stats ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(children: [
              Expanded(
                  child: _StatCard(
                      label: "Today's Earnings",
                      value: 'GHC ${_todayEarnings.toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: Colors.green)),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                      label: "Today's Trips",
                      value: '$_todayTrips trips',
                      icon: Icons.directions_car,
                      color: const Color(0xFFFFCC00))),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatCard(
                      label: 'Rating',
                      value: '5.0 ⭐',
                      icon: Icons.star,
                      color: Colors.orange)),
            ]),
          ),
          const SizedBox(height: 8),

          // ── Ride Requests ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(children: [
              const Text('📋 Ride Requests',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: _rides.isNotEmpty
                        ? const Color(0xFFFFCC00)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${_rides.length} requests',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _rides.isNotEmpty
                            ? Colors.black
                            : Colors.grey[600])),
              ),
            ]),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRides,
              color: const Color(0xFFFFCC00),
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFFCC00)))
                  : _rides.isEmpty
                      ? Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              const Text('⏳', style: TextStyle(fontSize: 60)),
                              const SizedBox(height: 12),
                              Text(
                                  _isOnline
                                      ? 'No ride requests yet...'
                                      : 'Go online to receive requests',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              const SizedBox(height: 6),
                              Text(
                                  _isOnline
                                      ? 'Pull down to refresh'
                                      : 'Toggle the switch above',
                                  style: TextStyle(color: Colors.grey[500])),
                              if (!_isOnline) ...[
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _toggleOnline,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFCC00),
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12))),
                                  child: const Text('Go Online',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                              ],
                            ]))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _rides.length,
                          itemBuilder: (_, i) {
                            final ride = _rides[i];
                            final fare = ride['fare'] ?? 0;
                            final distance = ride['distance_km'] ?? 0;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10)
                                ],
                              ),
                              child: Column(children: [
                                // Header
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFCC00)
                                        .withOpacity(0.1),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.person_pin,
                                        color: Color(0xFF1a1a2e)),
                                    const SizedBox(width: 8),
                                    Text('Rider #${ride['user_id'] ?? ''}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text(
                                          'GHC ${fare.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                    ),
                                  ]),
                                ),

                                // Route
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(children: [
                                    Row(children: [
                                      const Icon(Icons.my_location,
                                          color: Colors.blue, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                          child: Text(
                                              ride['pickup_address'] ??
                                                  'Pickup',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis)),
                                    ]),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                          children: List.generate(
                                              3,
                                              (_) => Container(
                                                  width: 2,
                                                  height: 5,
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 1),
                                                  color: Colors.grey[300]))),
                                    ),
                                    Row(children: [
                                      const Icon(Icons.location_pin,
                                          color: Colors.red, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                          child: Text(
                                              ride['destination_address'] ??
                                                  'Destination',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis)),
                                    ]),
                                    const SizedBox(height: 8),
                                    Row(children: [
                                      Icon(Icons.straighten,
                                          size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text('${distance.toStringAsFixed(1)} km',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13)),
                                      const SizedBox(width: 16),
                                      Icon(Icons.category,
                                          size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text(ride['ride_class'] ?? 'Economy',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13)),
                                    ]),
                                  ]),
                                ),

                                // Accept Button
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => _acceptRide(ride['id']),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFFFCC00),
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12))),
                                      child: const Text('Accept Ride',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15)),
                                    ),
                                  ),
                                ),
                              ]),
                            );
                          },
                        ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Stat Card ──────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 14, color: color)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DRIVER EARNINGS SCREEN
// ══════════════════════════════════════════════════════════════
class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});
  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  Map<String, dynamic> _earnings = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getDriverEarnings();
    setState(() {
      _earnings = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = (_earnings['total_earnings'] ?? 0).toDouble();
    final trips = _earnings['total_trips'] ?? 0;
    final rides = _earnings['rides'] as List? ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF1a1a2e), Color(0xFF16213e)])),
            child: Column(children: [
              const Text('My Earnings',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 8),
              Text('GHC ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 36)),
              const SizedBox(height: 4),
              Text('$trips total trips',
                  style:
                      const TextStyle(color: Color(0xFFFFCC00), fontSize: 14)),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _EarnStat(
                    label: 'This Week',
                    value: 'GHC ${(total * 0.3).toStringAsFixed(2)}'),
                Container(width: 1, height: 40, color: Colors.white24),
                _EarnStat(
                    label: 'This Month',
                    value: 'GHC ${(total * 0.7).toStringAsFixed(2)}'),
                Container(width: 1, height: 40, color: Colors.white24),
                _EarnStat(
                    label: 'All Time',
                    value: 'GHC ${total.toStringAsFixed(2)}'),
              ]),
            ]),
          ),

          // Rides List
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFCC00)))
                : rides.isEmpty
                    ? const Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Text('💰', style: TextStyle(fontSize: 60)),
                            SizedBox(height: 12),
                            Text('No earnings yet',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            Text('Complete rides to see earnings here',
                                style: TextStyle(color: Colors.grey)),
                          ]))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: rides.length,
                        itemBuilder: (_, i) {
                          final r = rides[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14)),
                            child: Row(children: [
                              Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFFFCC00)
                                          .withOpacity(0.1),
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.directions_car,
                                      color: Color(0xFFFFCC00))),
                              const SizedBox(width: 14),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(r['pickup_address'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    Text('→ ${r['destination_address'] ?? ''}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12)),
                                  ])),
                              Text('GHC ${(r['fare'] ?? 0).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.green,
                                      fontSize: 15)),
                            ]),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }
}

class _EarnStat extends StatelessWidget {
  final String label, value;
  const _EarnStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ]);
}

// ══════════════════════════════════════════════════════════════
// DRIVER PROFILE SCREEN
// ══════════════════════════════════════════════════════════════
class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});
  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  String _name = '';
  String _avatar = '🧔';
  final List<String> _avatars = [
    '🧔',
    '👨',
    '👱',
    '😎',
    '🕵️',
    '👮',
    '🦸',
    '🧙',
    '🚀',
    '🦁'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('driver_name') ?? 'Driver';
      _avatar = prefs.getString('driver_avatar') ?? '🧔';
    });
  }

  void _pickAvatar() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Choose Avatar',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: _avatars
                .map((a) => GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('driver_avatar', a);
                        setState(() => _avatar = a);
                        if (mounted) Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: _avatar == a
                                ? const Color(0xFFFFCC00).withOpacity(0.2)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _avatar == a
                                    ? const Color(0xFFFFCC00)
                                    : Colors.transparent,
                                width: 2)),
                        child: Center(
                            child:
                                Text(a, style: const TextStyle(fontSize: 30))),
                      ),
                    ))
                .toList(),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: RichText(
            text: const TextSpan(children: [
          TextSpan(
              text: 'Ride',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          TextSpan(
              text: 'Go ',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFCC00))),
          TextSpan(
              text: 'Driver',
              style: TextStyle(fontSize: 14, color: Colors.white54)),
        ])),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Profile Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1a1a2e), Color(0xFF16213e)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              Stack(children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                      radius: 44,
                      backgroundColor: const Color(0xFFFFCC00).withOpacity(0.2),
                      child:
                          Text(_avatar, style: const TextStyle(fontSize: 44))),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: const CircleAvatar(
                          backgroundColor: Color(0xFFFFCC00),
                          radius: 14,
                          child: Icon(Icons.camera_alt,
                              size: 14, color: Colors.black)),
                    )),
              ]),
              const SizedBox(height: 12),
              Text(_name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('Active Driver',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _DriverStat(label: 'Trips', value: '0'),
                Container(width: 1, height: 40, color: Colors.white24),
                _DriverStat(label: 'Rating', value: '5.0 ⭐'),
                Container(width: 1, height: 40, color: Colors.white24),
                _DriverStat(label: 'Earnings', value: 'GHC 0'),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // Options
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              ListTile(
                  leading: const Icon(Icons.directions_car_outlined),
                  title: const Text('My Vehicle',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {}),
              const Divider(height: 1),
              ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Earnings',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {}),
              const Divider(height: 1),
              ListTile(
                  leading: const Icon(Icons.star_outline),
                  title: const Text('My Ratings',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {}),
              const Divider(height: 1),
              ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Support',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {}),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log out',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600)),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (context.mounted)
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _WelcomeRedirect()),
                        (r) => false);
                },
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _DriverStat extends StatelessWidget {
  final String label, value;
  const _DriverStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ]);
}

// Redirect helper
class _WelcomeRedirect extends StatelessWidget {
  const _WelcomeRedirect();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/');
    });
    return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFFFFCC00))));
  }
}
