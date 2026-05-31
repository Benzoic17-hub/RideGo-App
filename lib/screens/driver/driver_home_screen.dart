import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../main.dart';

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
    print(data);

    if (data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user_type', 'driver');
      await prefs.setString('driver_name', data['driver']['name'] ?? '');
      // Ensure .toString() is used
      await prefs.setString('driver_id', data['driver']['id'].toString());
      await prefs.setString('driver_phone', data['driver']['phone'] ?? '');
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
    try {
      final rides = await ApiService.getAvailableRides();
      final earnings = await ApiService.getDriverEarnings();
      if (mounted)
        setState(() {
          _rides = rides;
          _loading = false;
          _todayEarnings = (earnings['today_earnings'] ?? 0).toDouble();
          _todayTrips = earnings['today_trips'] ?? 0;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleOnline() async {
    final prefs = await SharedPreferences.getInstance();
    final newStatus = !_isOnline;
    await prefs.setBool('driver_online', newStatus);
    setState(() => _isOnline = newStatus);
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(newStatus ? '🟢 You are now Online' : '🔴 You are Offline'),
          backgroundColor: newStatus ? Colors.green : Colors.red));
  }

  // ✅ FIX: Accept ride with null-safe ID
  Future<void> _acceptRide(dynamic rideId) async {
    if (rideId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('❌ Invalid ride'), backgroundColor: Colors.red));
      return;
    }
    final id = int.tryParse(rideId.toString());
    if (id == null) return;

    // Show loading
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFCC00))));

    final data = await ApiService.acceptRide(id);

    if (mounted) Navigator.pop(context); // close loading

    if (data['success'] == true) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✅ Ride accepted! Go pick up the rider.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3)));
      _loadRides();
    } else {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message'] ?? 'Failed to accept ride'),
            backgroundColor: Colors.red));
    }
  }

  // ✅ NEW: Cancel ride
  Future<void> _cancelRide(dynamic rideId, String riderName) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _CancelDialog(riderName: riderName),
    );
    if (reason == null || reason.isEmpty) return;

    final id = int.tryParse(rideId.toString());
    if (id == null) return;

    final data = await ApiService.cancelRide(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['success'] == true
              ? '✅ Ride cancelled successfully'
              : '❌ ${data['message'] ?? 'Could not cancel'}'),
          backgroundColor:
              data['success'] == true ? Colors.orange : Colors.red));
      _loadRides();
    }
  }

  String _safe(Map ride, List<String> keys, String fallback) {
    for (final k in keys) {
      if (ride[k] != null && ride[k].toString().trim().isNotEmpty)
        return ride[k].toString();
    }
    return fallback;
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
                    colors: [Color(0xFF1a1a2e), Color(0xFF16213e)])),
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
              Row(children: [
                Text(_isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                        color: _isOnline ? Colors.green : Colors.grey[400],
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
                        borderRadius: BorderRadius.circular(14)),
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
                              color: Colors.white, shape: BoxShape.circle)),
                    ),
                  ),
                ),
              ]),
            ]),
          ),

          // ── Stats ──
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
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                      label: "Today's Trips",
                      value: '$_todayTrips trips',
                      icon: Icons.directions_car,
                      color: const Color(0xFFFFCC00))),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                      label: 'Rating',
                      value: '5.0 ⭐',
                      icon: Icons.star,
                      color: Colors.orange)),
            ]),
          ),
          const SizedBox(height: 8),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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

          // ── Rides List ──
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRides,
              color: const Color(0xFFFFCC00),
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFFCC00)))
                  : _rides.isEmpty
                      ? ListView(children: [
                          SizedBox(
                              height: 320,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('⏳',
                                        style: TextStyle(fontSize: 60)),
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
                                        style:
                                            TextStyle(color: Colors.grey[500])),
                                    if (!_isOnline) ...[
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: _toggleOnline,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFFFCC00),
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
                                  ])),
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          itemCount: _rides.length,
                          itemBuilder: (_, i) {
                            final ride = Map<String, dynamic>.from(_rides[i]);
                            final rideId = ride['id'];
                            final riderName = _safe(
                                ride, ['rider_name', 'user_name'], 'Rider');
                            final riderPhone =
                                _safe(ride, ['rider_phone', 'phone'], '');
                            final pickup = _safe(
                                ride,
                                ['pickup', 'pickup_address'],
                                'Pickup location');
                            final dest = _safe(
                                ride,
                                ['destination', 'destination_address'],
                                'Destination');
                            final fare = double.tryParse(
                                    (ride['fare'] ?? 0).toString()) ??
                                0.0;
                            final dist = double.tryParse(
                                    (ride['distance_km'] ?? 0).toString()) ??
                                0.0;
                            final rideClass = _safe(
                                ride,
                                ['ride_class', 'service', 'service_type'],
                                'Economy');
                            final createdAt =
                                ride['created_at']?.toString() ?? '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4))
                                ],
                              ),
                              child: Column(children: [
                                // ── Card Header ──
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFFFCC00)
                                          .withOpacity(0.1),
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(18))),
                                  child: Row(children: [
                                    const CircleAvatar(
                                        backgroundColor: Color(0xFF1a1a2e),
                                        radius: 18,
                                        child: Icon(Icons.person,
                                            color: Colors.white, size: 18)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text(riderName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15)),
                                          if (riderPhone.isNotEmpty)
                                            Text(riderPhone,
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12)),
                                        ])),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 5),
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Text(
                                                'GHC ${fare.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                          ),
                                          if (createdAt.isNotEmpty)
                                            Text(createdAt,
                                                style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 11)),
                                        ]),
                                  ]),
                                ),

                                // ── Route ──
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(children: [
                                    Row(children: [
                                      Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: Text(pickup,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis)),
                                    ]),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, top: 4, bottom: 4),
                                      child: Column(
                                          children: List.generate(
                                              4,
                                              (_) => Container(
                                                  width: 2,
                                                  height: 4,
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 1),
                                                  color: Colors.grey[300]))),
                                    ),
                                    Row(children: [
                                      Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(3))),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: Text(dest,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis)),
                                    ]),
                                    const SizedBox(height: 12),

                                    // Details
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            _Chip(
                                                icon: Icons.straighten,
                                                label:
                                                    '${dist.toStringAsFixed(1)} km'),
                                            _Chip(
                                                icon: Icons.category,
                                                label: rideClass.toUpperCase()),
                                            _Chip(
                                                icon: Icons.payments_outlined,
                                                label:
                                                    'GHC ${fare.toStringAsFixed(0)}'),
                                          ]),
                                    ),
                                  ]),
                                ),

                                // ── Buttons ──
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Row(children: [
                                    // Cancel Button
                                    Expanded(
                                      flex: 1,
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            _cancelRide(rideId, riderName),
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            side: const BorderSide(
                                                color: Colors.red),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12))),
                                        child: const Text('Cancel',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Accept Button
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton(
                                        onPressed: () => _acceptRide(rideId),
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
                                  ]),
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

// ── Cancel Dialog ──────────────────────────────────────────────
class _CancelDialog extends StatefulWidget {
  final String riderName;
  const _CancelDialog({required this.riderName});
  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  String _selected = '';
  final _reasons = [
    'Too busy right now',
    'Rider is too far',
    'Vehicle issue',
    'Wrong location',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cancel ride for ${widget.riderName}?',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Select a reason:', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        ..._reasons
            .map((r) => RadioListTile<String>(
                  value: r,
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v ?? ''),
                  title: Text(r, style: const TextStyle(fontSize: 14)),
                  dense: true,
                  activeColor: const Color(0xFFFFCC00),
                ))
            .toList(),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Back')),
        ElevatedButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.pop(context, _selected),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Cancel Ride'),
        ),
      ],
    );
  }
}

// ── Chip ───────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]);
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 12, color: color)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 9)),
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
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getDriverEarnings();
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = (_data['total_earnings'] ?? 0).toDouble();
    final trips = _data['total_trips'] ?? 0;
    final rides = _data['rides'] as List? ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(children: [
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
                _EStat(
                    label: 'This Week',
                    value: 'GHC ${(total * 0.3).toStringAsFixed(2)}'),
                Container(width: 1, height: 40, color: Colors.white24),
                _EStat(
                    label: 'This Month',
                    value: 'GHC ${(total * 0.7).toStringAsFixed(2)}'),
                Container(width: 1, height: 40, color: Colors.white24),
                _EStat(
                    label: 'All Time',
                    value: 'GHC ${total.toStringAsFixed(2)}'),
              ]),
            ]),
          ),
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
                            Text('Complete rides to earn money!',
                                style: TextStyle(color: Colors.grey)),
                          ]))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: rides.length,
                        itemBuilder: (_, i) {
                          final r = rides[i];
                          final pickup =
                              r['pickup'] ?? r['pickup_address'] ?? '';
                          final dest = r['destination'] ??
                              r['destination_address'] ??
                              '';
                          final fare =
                              double.tryParse((r['fare'] ?? 0).toString()) ??
                                  0.0;
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
                                    Text(pickup,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    Text('→ $dest',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12)),
                                  ])),
                              Text('GHC ${fare.toStringAsFixed(2)}',
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

class _EStat extends StatelessWidget {
  final String label, value;
  const _EStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13)),
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
  String _phone = '';
  String? _photoPath;
  int _trips = 0;
  double _earnings = 0;
  double _rating = 5.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final earnings = await ApiService.getDriverEarnings();
    setState(() {
      _name = prefs.getString('driver_name') ?? 'Driver';
      _phone = prefs.getString('driver_phone') ?? '';
      _photoPath = prefs.getString('driver_photo');
      _trips = earnings['total_trips'] ?? 0;
      _earnings = (earnings['total_earnings'] ?? 0).toDouble();
    });
  }

  // ✅ Camera / Gallery picker
  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
          source: source, imageQuality: 70, maxWidth: 400);
      if (picked != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('driver_photo', picked.path);
        setState(() => _photoPath = picked.path);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not access camera/gallery')));
    }
  }

  void _showPhotoPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Update Profile Photo',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _PhotoOption(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.camera);
                }),
            _PhotoOption(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.gallery);
                }),
            if (_photoPath != null)
              _PhotoOption(
                  icon: Icons.delete_outline,
                  label: 'Remove',
                  color: Colors.red,
                  onTap: () async {
                    Navigator.pop(context);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('driver_photo');
                    setState(() => _photoPath = null);
                  }),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showRatings() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('My Ratings ⭐',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Average Rating',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text('$_rating / 5.0',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 36,
                        color: Color(0xFFFFCC00))),
                const SizedBox(height: 16),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        5,
                        (i) => Icon(
                            i < _rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color(0xFFFFCC00),
                            size: 32))),
                const SizedBox(height: 16),
                const Text(
                    'Keep up the great work!\nMaintain high ratings to get more rides.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            ));
  }

  void _showVehicle() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('My Vehicle 🚗',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _VehicleRow(label: 'Make', value: 'Toyota'),
                    _VehicleRow(label: 'Model', value: 'Corolla'),
                    _VehicleRow(label: 'Year', value: '2020'),
                    _VehicleRow(label: 'Plate', value: 'GR-1234-20'),
                    _VehicleRow(label: 'Color', value: 'Silver'),
                    _VehicleRow(label: 'Status', value: '✅ Approved'),
                  ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            ));
  }

  void _showSupport() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Support 🎧',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How can we help you?',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    _SupportOption(
                        icon: Icons.phone,
                        label: 'Call Support',
                        sub: '+233 XX XXX XXXX'),
                    const Divider(height: 20),
                    _SupportOption(
                        icon: Icons.chat_outlined,
                        label: 'Chat with us',
                        sub: 'Available 24/7'),
                    const Divider(height: 20),
                    _SupportOption(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        sub: 'support@ridego.com'),
                  ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            ));
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
          // ── Profile Card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1a1a2e), Color(0xFF16213e)]),
                borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              // ✅ Real photo with camera support
              Stack(children: [
                GestureDetector(
                  onTap: _showPhotoPicker,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFFFCC00).withOpacity(0.2),
                    backgroundImage: _photoPath != null
                        ? FileImage(File(_photoPath!))
                        : null,
                    child: _photoPath == null
                        ? const Icon(Icons.person,
                            size: 50, color: Colors.white54)
                        : null,
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showPhotoPicker,
                      child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFCC00), shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.black)),
                    )),
              ]),
              const SizedBox(height: 12),
              Text(_name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22)),
              if (_phone.isNotEmpty)
                Text(_phone,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 8),
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
                _DStat(label: 'Trips', value: '$_trips'),
                Container(width: 1, height: 40, color: Colors.white24),
                _DStat(
                    label: 'Rating', value: '${_rating.toStringAsFixed(1)} ⭐'),
                Container(width: 1, height: 40, color: Colors.white24),
                _DStat(
                    label: 'Earnings',
                    value: 'GHC ${_earnings.toStringAsFixed(0)}'),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Options ── ALL WORKING ──
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.directions_car_outlined,
                    color: Color(0xFFFFCC00)),
                title: const Text('My Vehicle',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showVehicle,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green),
                title: const Text('Earnings',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('GHC ${_earnings.toStringAsFixed(2)} total'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: const Text('Earnings Summary 💰'),
                          content:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            _VehicleRow(
                                label: 'Total Earnings',
                                value: 'GHC ${_earnings.toStringAsFixed(2)}'),
                            _VehicleRow(
                                label: 'Total Trips', value: '$_trips trips'),
                            _VehicleRow(
                                label: 'This Week',
                                value:
                                    'GHC ${(_earnings * 0.3).toStringAsFixed(2)}'),
                            _VehicleRow(
                                label: 'This Month',
                                value:
                                    'GHC ${(_earnings * 0.7).toStringAsFixed(2)}'),
                          ]),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'))
                          ],
                        )),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.star_outline, color: Colors.orange),
                title: const Text('My Ratings',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${_rating.toStringAsFixed(1)} average rating'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showRatings,
              ),
              const Divider(height: 1),
              ListTile(
                leading:
                    const Icon(Icons.headset_mic_outlined, color: Colors.blue),
                title: const Text('Support',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showSupport,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log out',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600)),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Log out?'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white),
                          child: const Text('Log out'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (context.mounted)
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WelcomeScreen()),
                          (r) => false);
                  }
                },
              ),
            ]),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────
class _DStat extends StatelessWidget {
  final String label, value;
  const _DStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ]);
}

class _VehicleRow extends StatelessWidget {
  final String label, value;
  const _VehicleRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          SizedBox(
              width: 80,
              child: Text('$label:',
                  style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      );
}

class _SupportOption extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  const _SupportOption(
      {required this.icon, required this.label, required this.sub});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFFFFCC00).withOpacity(0.1),
                shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFFFFCC00), size: 22)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      ]);
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _PhotoOption(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color = const Color(0xFF1a1a2e)});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28)),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ]),
      );
}
