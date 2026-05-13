import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';

class RiderProfileScreen extends StatefulWidget {
  const RiderProfileScreen({super.key});
  @override
  State<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  String _name = '';
  String _phone = '';
  String _email = '';
  String _avatar = '👤';

  final List<String> _avatars = [
    '👤',
    '😎',
    '🧑',
    '👨',
    '👩',
    '🧔',
    '👱',
    '🧕',
    '👲',
    '🎩',
    '🚀',
    '🦁',
    '🐯',
    '🦊',
    '🐺',
    '🎭',
    '🦸',
    '🧙',
    '👮',
    '🕵️',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'Rider';
      _phone = prefs.getString('user_phone') ?? '';
      _email = prefs.getString('user_email') ?? '';
      _avatar = prefs.getString('user_avatar') ?? '👤';
    });
  }

  Future<void> _logout() async {
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
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted)
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (r) => false);
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Choose Your Avatar',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 4),
          const Text('Tap an avatar to select it',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                        await prefs.setString('user_avatar', a);
                        setState(() => _avatar = a);
                        if (mounted) Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _avatar == a
                              ? const Color(0xFFFFCC00).withOpacity(0.2)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _avatar == a
                                  ? const Color(0xFFFFCC00)
                                  : Colors.transparent,
                              width: 2),
                        ),
                        child: Center(
                            child:
                                Text(a, style: const TextStyle(fontSize: 30))),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(height: 20),

            // ── Profile Header ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(children: [
                Stack(children: [
                  GestureDetector(
                    onTap: _showAvatarPicker,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor:
                          const Color(0xFFFFCC00).withOpacity(0.15),
                      child:
                          Text(_avatar, style: const TextStyle(fontSize: 46)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showAvatarPicker,
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFFFFCC00),
                        radius: 15,
                        child: Icon(Icons.camera_alt,
                            size: 15, color: Colors.black),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Excellent',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 20)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                ]),
                Text(_phone.isNotEmpty ? _phone : 'Add phone number',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ]),
            ),
            const SizedBox(height: 12),

            // ── Quick Icons ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _QuickIcon(
                        icon: Icons.history, label: 'History', onTap: () {}),
                    _QuickIcon(
                        icon: Icons.headset_mic_outlined,
                        label: 'Support',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SupportScreen()))),
                    _QuickIcon(
                        icon: Icons.location_on_outlined,
                        label: 'Addresses',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddressesScreen()))),
                    _QuickIcon(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SettingsScreen(
                                    name: _name,
                                    phone: _phone,
                                    email: _email)))),
                  ]),
            ),
            const SizedBox(height: 12),

            // ── Ride Rating Card ──
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RideProfileScreen())),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child:
                        const Icon(Icons.star, color: Colors.green, size: 22),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('RideGo Star',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        Text('Ride index: 100/100 · Rating: 5.00',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ])),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            // ── Payment & Discounts ──
            Container(
              color: Colors.white,
              child: Column(children: [
                ListTile(
                  leading: _iconCircle(Icons.local_offer_outlined),
                  title: const Text('Discounts and gifts',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Enter promo code'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DiscountsScreen())),
                ),
                const Divider(height: 1, indent: 60),
                ListTile(
                  leading: _iconCircle(Icons.payment_outlined),
                  title: const Text('Payment methods',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('MTN MoMo'),
                  trailing:
                      Row(mainAxisSize: MainAxisSize.min, children: const [
                    Text('📱', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right),
                  ]),
                  onTap: () => _showPaymentMethods(),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // ── Earn as driver ──
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DriverRegisterScreen())),
              child: Container(
                color: const Color(0xFF1a1a2e),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFCC00), shape: BoxShape.circle),
                    child: const Icon(Icons.directions_car,
                        color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Text('Earn as a driver',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Color(0xFFFFCC00)),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            // ── Other Options ──
            Container(
              color: Colors.white,
              child: Column(children: [
                ListTile(
                  leading: _iconCircle(Icons.shield_outlined),
                  title: const Text('Safety',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SafetyScreen())),
                ),
                const Divider(height: 1, indent: 60),
                ListTile(
                  leading:
                      _iconCircle(Icons.cancel_outlined, color: Colors.green),
                  title: const Text('Great! Few canceled rides',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('This affects ride search speed'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 60),
                ListTile(
                  leading: _iconCircle(Icons.info_outline),
                  title: const Text('Information',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const InformationScreen())),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // ── Logout ──
            Container(
              color: Colors.white,
              child: ListTile(
                title: const Text('Log out',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: _logout,
              ),
            ),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }

  Widget _iconCircle(IconData icon, {Color color = Colors.black87}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration:
          BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
      child: Icon(icon, size: 22, color: color),
    );
  }

  void _showPaymentMethods() {
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
              const Text('Payment Methods',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 16),
              ...[
                {
                  'name': 'MTN MoMo',
                  'emoji': '📱',
                  'sub': 'Active',
                  'active': true
                },
                {
                  'name': 'Telecel Cash',
                  'emoji': '📱',
                  'sub': 'Tap to add',
                  'active': false
                },
                {
                  'name': 'AirtelTigo',
                  'emoji': '📱',
                  'sub': 'Tap to add',
                  'active': false
                },
                {
                  'name': 'Ghana Pay',
                  'emoji': '🏦',
                  'sub': 'Tap to add',
                  'active': false
                },
                {
                  'name': 'Cash',
                  'emoji': '💵',
                  'sub': 'Always available',
                  'active': false
                },
              ]
                  .map((p) => ListTile(
                        leading: Text(p['emoji'] as String,
                            style: const TextStyle(fontSize: 28)),
                        title: Text(p['name'] as String,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(p['sub'] as String),
                        trailing: p['active'] == true
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFFFFCC00))
                            : const Icon(Icons.add, color: Colors.grey),
                        onTap: () => Navigator.pop(context),
                      ))
                  .toList(),
            ]),
      ),
    );
  }
}

// ── Quick Icon Widget ──────────────────────────────────────────
class _QuickIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickIcon(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 56,
          height: 56,
          decoration:
              BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
          child: Icon(icon, size: 26, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SUPPORT SCREEN
// ══════════════════════════════════════════════════════════════
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final rides = [
      {
        'type': 'Delivery',
        'date': '18 Mar at 15:30',
        'route': 'Westland Blvd → Senchi St',
        'price': '23 GHC',
        'emoji': '📦'
      },
      {
        'type': 'Delivery',
        'date': '16 Mar at 14:24',
        'route': 'Naa Ata Street → Madina',
        'price': '18 GHC',
        'emoji': '📦'
      },
      {
        'type': 'Taxi Economy',
        'date': '16 Feb at 15:08',
        'route': 'Westland Blvd → Xpress Gas',
        'price': '15 GHC',
        'emoji': '🚗'
      },
    ];
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('What do you need\nhelp with?',
              style: TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 26, height: 1.2)),
          const SizedBox(height: 20),
          const Text('Rides and orders',
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              ...rides
                  .map((r) => Column(children: [
                        ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                                child: Text(r['emoji']!,
                                    style: const TextStyle(fontSize: 22))),
                          ),
                          title: Text('${r['type']} ${r['date']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: Text('${r['price']} · ${r['route']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12)),
                          trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.chat_bubble_outline,
                                  size: 18)),
                        ),
                        const Divider(height: 1),
                      ]))
                  .toList(),
              ListTile(
                leading: const Icon(Icons.list_alt, size: 22),
                title: const Text('All rides and orders',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Other',
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.folder_outlined, size: 22),
              title: const Text('All chats',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ADDRESSES SCREEN
// ══════════════════════════════════════════════════════════════
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});
  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  String _home = '';
  String _work = '';
  List<String> _others = [];
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _home = prefs.getString('addr_home') ?? '';
      _work = prefs.getString('addr_work') ?? '';
      _others = prefs.getStringList('addr_others') ?? [];
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('addr_home', _home);
    await prefs.setString('addr_work', _work);
    await prefs.setStringList('addr_others', _others);
  }

  void _add(String type) {
    _ctrl.clear();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(
                  'Add ${type == 'home' ? 'Home' : type == 'work' ? 'Work' : 'Address'}'),
              content: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                      hintText: 'Enter address',
                      prefixIcon: Icon(Icons.location_on))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (_ctrl.text.isNotEmpty) {
                      setState(() {
                        if (type == 'home')
                          _home = _ctrl.text;
                        else if (type == 'work')
                          _work = _ctrl.text;
                        else
                          _others.add(_ctrl.text);
                      });
                      await _save();
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: Colors.black),
                  child: const Text('Save'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: const Text('My addresses',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.bookmark_outline, color: Colors.grey),
                title: const Text('Add address',
                    style: TextStyle(color: Colors.grey)),
                trailing: GestureDetector(
                    onTap: () => _add('other'),
                    child: const Icon(Icons.add, color: Colors.grey)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.home_outlined, color: Colors.grey),
                title: Text(_home.isNotEmpty ? _home : 'Add home address',
                    style: TextStyle(
                        color: _home.isEmpty ? Colors.grey : Colors.black,
                        fontWeight: FontWeight.w500)),
                trailing: _home.isNotEmpty
                    ? IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          setState(() => _home = '');
                          _save();
                        })
                    : GestureDetector(
                        onTap: () => _add('home'),
                        child: const Icon(Icons.add, color: Colors.grey)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.work_outline, color: Colors.grey),
                title: Text(_work.isNotEmpty ? _work : 'Add work address',
                    style: TextStyle(
                        color: _work.isEmpty ? Colors.grey : Colors.black,
                        fontWeight: FontWeight.w500)),
                trailing: _work.isNotEmpty
                    ? IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          setState(() => _work = '');
                          _save();
                        })
                    : GestureDetector(
                        onTap: () => _add('work'),
                        child: const Icon(Icons.add, color: Colors.grey)),
              ),
              if (_others.isNotEmpty)
                ...(_others
                    .asMap()
                    .entries
                    .map((e) => Column(children: [
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.location_on_outlined),
                            title: Text(e.value,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() => _others.removeAt(e.key));
                                  _save();
                                }),
                          ),
                        ]))
                    .toList()),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SAFETY SCREEN
// ══════════════════════════════════════════════════════════════
class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});
  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  List<String> _contacts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _contacts = prefs.getStringList('trusted_contacts') ?? []);
  }

  void _addContact() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Add Trusted Contact'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Name', prefixIcon: Icon(Icons.person))),
                const SizedBox(height: 12),
                TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        hintText: 'Phone number',
                        prefixIcon: Icon(Icons.phone))),
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                      _contacts.add('${nameCtrl.text}|${phoneCtrl.text}');
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setStringList('trusted_contacts', _contacts);
                      setState(() {});
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: Colors.black),
                  child: const Text('Add'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_contacts.isNotEmpty ? 1 : 0) / 6.0;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFFd6eaf8), Color(0xFFf0f8ff)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
            ),
            child: Column(children: [
              const Text('🛡️', style: TextStyle(fontSize: 64)),
              Text('PRE-RIDE CHECK ${(_contacts.isNotEmpty ? 1 : 0)}/6',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 22)),
              const Text('Steps to help make rides safer and easier',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFFFFCC00)),
              ),
            ]),
          ),

          // Emergency & Support
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                  child: _ActionBtn(
                      icon: Icons.emergency,
                      label: 'Emergency',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('📞 Emergency: Call 191')));
                      })),
              const SizedBox(width: 12),
              Expanded(
                  child: _ActionBtn(
                      icon: Icons.headset_mic_outlined,
                      label: 'Support',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SupportScreen())))),
            ]),
          ),

          // Contacts & Actions
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Add trusted contacts',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (_contacts.isEmpty)
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.blue, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ]),
                onTap: _addContact,
              ),
              ..._contacts.map((c) {
                final parts = c.split('|');
                return Column(children: [
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFCC00),
                        child: Icon(Icons.person, color: Colors.black)),
                    title: Text(parts[0],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(parts.length > 1 ? parts[1] : ''),
                    trailing: IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          _contacts.remove(c);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setStringList(
                              'trusted_contacts', _contacts);
                          setState(() {});
                        }),
                  ),
                ]);
              }).toList(),
              const Divider(height: 1, indent: 60),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Add profile photo',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Colors.blue, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ]),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 1, indent: 60),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Add email',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('In case you misplace your phone'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Colors.blue, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ]),
                onTap: () {},
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Articles
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.shield_outlined, color: Colors.grey),
                title: const Text('How to ride safely',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Important to read · 2 min',
                    style: TextStyle(color: Colors.orange, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 60),
              ListTile(
                leading:
                    const Icon(Icons.pan_tool_outlined, color: Colors.grey),
                title: const Text('How to get help during a ride',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle:
                    const Text('Read · 2 min', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 60),
              ListTile(
                leading:
                    const Icon(Icons.drive_eta_outlined, color: Colors.grey),
                title: const Text('Learn driver safety standards',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle:
                    const Text('Read · 2 min', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ]),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Icon(icon, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

// ══════════════════════════════════════════════════════════════
// DISCOUNTS SCREEN
// ══════════════════════════════════════════════════════════════
class DiscountsScreen extends StatelessWidget {
  const DiscountsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Discounts',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Column(children: [
        Container(
          color: Colors.white,
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.confirmation_number_outlined),
              title: const Text('Enter promo code',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text('Enter Promo Code'),
                        content: TextField(
                            controller: ctrl,
                            decoration: const InputDecoration(
                                hintText: 'e.g. RIDEGO20')),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      '❌ Code "${ctrl.text}" is invalid or expired')));
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFCC00),
                                foregroundColor: Colors.black),
                            child: const Text('Apply'),
                          ),
                        ],
                      )),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.card_giftcard_outlined),
              title: const Text('Get discounts',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ]),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          '📤 Invite link copied! Share with friends for discounts'))),
              icon: const Icon(Icons.people),
              label: const Text('Invite friends',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// INFORMATION SCREEN
// ══════════════════════════════════════════════════════════════
class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Information',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Column(children: [
        const SizedBox(height: 12),
        Container(
          color: Colors.white,
          child: Column(children: [
            ListTile(
              title: const Text('Partners',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text('Our Partners'),
                        content: const Text(
                            'RideGo partners with:\n\n📱 MTN MoMo\n📱 Telecel Cash\n📱 AirtelTigo Money\n🏦 Ghana Pay\n\nFor seamless payments across Ghana.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'))
                        ],
                      )),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('About',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── About Screen ───────────────────────────────────────────────
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text('About'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Column(children: [
        const SizedBox(height: 40),
        Center(
            child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e),
              borderRadius: BorderRadius.circular(24)),
          child: Center(
              child: RichText(
                  text: const TextSpan(children: [
            TextSpan(
                text: 'Ride',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
            TextSpan(
                text: 'Go',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFCC00))),
          ]))),
        )),
        const SizedBox(height: 16),
        const Text('RideGo',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
        const Text('Version 1.0.0 · 2026',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 32),
        Container(
          color: Colors.white,
          child: Column(children: [
            ListTile(
                title: const Text('License Agreement'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {}),
            const Divider(height: 1),
            ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {}),
            const Divider(height: 1),
            ListTile(
                title: const Text('User Data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {}),
          ]),
        ),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            Text('Informational service provided by:',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('RideGo Ghana Ltd., Accra, Ghana',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('© 2026 RideGo',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}

// ── Ride Profile Screen ────────────────────────────────────────
class RideProfileScreen extends StatelessWidget {
  const RideProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Container(
          height: 300,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF90EE90), Color(0xFFFFFF90)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child: SafeArea(
              child: Column(children: [
            Row(children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context)),
              const Spacer(),
              const Text('Your ride profile',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const Spacer(),
              const SizedBox(width: 48),
            ]),
            const SizedBox(height: 8),
            const CircleAvatar(
                radius: 46,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 50, color: Colors.white70)),
            const SizedBox(height: 10),
            const Text('RideGo Star',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const Text('Few cancellations and high ratings from drivers',
                style: TextStyle(fontSize: 13, color: Colors.black54)),
          ])),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFCC00), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ride index',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Text('100',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 32)),
                      const Text(' out of 100',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const Spacer(),
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 32),
                    ]),
                  ]),
            )),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ]),
              child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rating from\ndrivers',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    SizedBox(height: 12),
                    Text('5.00',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 32)),
                  ]),
            ),
          ]),
        ),
        ...[
          'Search time as usual',
          'Multiple ride requests',
          'Drivers are more likely to accept your ride requests',
        ]
            .map((t) => ListTile(
                  leading: const CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 14,
                      child: Icon(Icons.check, color: Colors.white, size: 14)),
                  title: Text(t,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ))
            .toList(),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SETTINGS SCREEN
// ══════════════════════════════════════════════════════════════
class SettingsScreen extends StatefulWidget {
  final String name, phone, email;
  const SettingsScreen(
      {super.key,
      required this.name,
      required this.phone,
      required this.email});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _traffic = false;
  bool _noCall = false;
  bool _shareGps = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 12),
          Container(
              color: Colors.white,
              child: Column(children: [
                _tile(
                    widget.name.isNotEmpty ? widget.name : 'Add name', 'Name'),
                const Divider(height: 1),
                _tile(widget.phone.isNotEmpty ? widget.phone : 'Add phone',
                    'Phone'),
                const Divider(height: 1),
                _tile(widget.email.isNotEmpty ? widget.email : 'Add email',
                    'Email'),
              ])),
          const SizedBox(height: 12),
          Container(
              color: Colors.white,
              child: Column(children: [
                const ListTile(
                    title: Text('Theme and map',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16))),
                const Divider(height: 1),
                SwitchListTile(
                    title: const Text('Display traffic'),
                    value: _traffic,
                    onChanged: (v) => setState(() => _traffic = v),
                    activeColor: const Color(0xFFFFCC00)),
                const Divider(height: 1),
                ListTile(
                    title: const Text('App language'),
                    subtitle: const Text('English'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {}),
              ])),
          const SizedBox(height: 12),
          Container(
              color: Colors.white,
              child: Column(children: [
                SwitchListTile(
                    title: const Text("Don't call me"),
                    subtitle: const Text(
                        "We'll ask the driver not to call unless it's an emergency"),
                    value: _noCall,
                    onChanged: (v) => setState(() => _noCall = v),
                    activeColor: const Color(0xFFFFCC00)),
                const Divider(height: 1),
                SwitchListTile(
                    title: const Text('Share my location with driver'),
                    subtitle: const Text(
                        'The driver will be able to see your location until you get in the car'),
                    value: _shareGps,
                    onChanged: (v) => setState(() => _shareGps = v),
                    activeColor: const Color(0xFFFFCC00)),
              ])),
          const SizedBox(height: 12),
          Container(
              color: Colors.white,
              child: Column(children: [
                const ListTile(
                    title: Text('Notifications',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16))),
                const Divider(height: 1),
                ListTile(
                    title: const Text('More'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {}),
                const Divider(height: 1),
                ListTile(
                    title: const Text('Log out'),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (context.mounted)
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WelcomeScreen()),
                            (r) => false);
                    }),
              ])),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _tile(String label, String sub) => ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(sub),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      );
}
