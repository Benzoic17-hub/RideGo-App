import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

// ══════════════════════════════════════════════════════════════
// RIDER HISTORY SCREEN (The "My Trips" Tab)
// ══════════════════════════════════════════════════════════════
class RiderHistoryScreen extends StatefulWidget {
  const RiderHistoryScreen({super.key});

  @override
  State<RiderHistoryScreen> createState() => _RiderHistoryScreenState();
}

class _RiderHistoryScreenState extends State<RiderHistoryScreen> {
  List<dynamic> _rides = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final rides = await ApiService.getRideHistory();
    if (mounted) {
      setState(() {
        _rides = rides;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FA), // Slightly off-white for contrast
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('My Trips',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFCC00)))
          : _rides.isEmpty
              ? _buildEmptyState()
              : _buildRideList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🚗', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text('No rides yet!',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const Text('Your trip history will appear here',
              style: TextStyle(color: Colors.black54, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRideList() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rides.length,
        itemBuilder: (_, i) {
          final ride = _rides[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ride['created_at'] ?? '',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const Divider(height: 25),
                _locationRow(Colors.green, ride['pickup'] ?? 'Pickup location'),
                const SizedBox(height: 10),
                _locationRow(Colors.red, ride['destination'] ?? 'Destination'),
                const Divider(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('GHC ${ride['fare']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Colors.black)),
                    Text(ride['status'].toString().toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _locationRow(Color color, String text) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500))),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// RIDER PROFILE SCREEN (The "Profile" Tab)
// ══════════════════════════════════════════════════════════════
class RiderProfileScreen extends StatefulWidget {
  const RiderProfileScreen({super.key});

  @override
  State<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  String _name = 'Rider';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'Rider';
      _email = prefs.getString('user_email') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Profile',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Dark Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFFFCC00),
                    child: Text(_name[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ),
                  const SizedBox(height: 15),
                  Text(_name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  Text(_email,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Settings List - FIXED CONTRAST (BLACK TEXT)
            _profileButton(Icons.notifications_outlined, "Notifications", () {
              _showSnackBar("No new notifications");
            }),
            _profileButton(Icons.lock_outline, "Privacy & Safety", () {
              _showSnackBar("Privacy settings updated");
            }),
            _profileButton(Icons.help_outline, "Help & Support", () {
              _showSnackBar("Opening support chat...");
            }),

            const SizedBox(height: 50),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => ApiService.logout(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Logout",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _profileButton(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.black),
      title: Text(title,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.bold)), // Changed to bold black
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
    );
  }
}
