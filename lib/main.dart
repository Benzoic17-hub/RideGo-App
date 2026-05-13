import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/api_service.dart';
import 'screens/rider/login_screen.dart';
import 'screens/rider/home_screen.dart';
import 'screens/driver/driver_home_screen.dart';
import 'screens/driver/driver_home_screen.dart' show DriverLoginScreen;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://kgaomzwmyeyioglawehq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtnYW9tendteWV5aW9nbGF3ZWhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNTUyNTgsImV4cCI6MjA5MzczMTI1OH0.RJ-Gg_qK6dSIYfWCWCBcr57SuZ_1316wmkhvNs3-2dE',
  );
  runApp(const RideGoApp());
}

class RideGoApp extends StatelessWidget {
  const RideGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RideGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFFCC00),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFCC00)),
      ),
      home: const SplashScreen(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ANIMATED SPLASH SCREEN
// ══════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _logoCtrl;
  late Animation<Color?> _bgColor;
  late Animation<double> _logoScale;
  late Animation<Alignment> _logoAlign;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _bgColor = ColorTween(
      begin: const Color(0xFFFFCC00),
      end: const Color(0xFF1a1a2e),
    ).animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

    _logoScale = Tween<double>(begin: 1.2, end: 0.5)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut));

    _logoAlign = AlignmentTween(begin: Alignment.center, end: Alignment.topLeft)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut));

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _bgCtrl, curve: const Interval(0.0, 0.5)));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _bgCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userType = prefs.getString('user_type');
    if (!mounted) return;
    if (token != null && userType == 'rider') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const RiderHomeScreen()));
    } else if (token != null && userType == 'driver') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DriverHomeScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
    }
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bgCtrl, _logoCtrl]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _bgColor.value,
          body: Stack(
            children: [
              AlignTransition(
                alignment: _logoAlign,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: RichText(
                        text: const TextSpan(children: [
                          TextSpan(
                              text: 'Ride',
                              style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                          TextSpan(
                              text: 'Go',
                              style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFFCC00))),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// WELCOME SCREEN
// ══════════════════════════════════════════════════════════════
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(children: [
            const SizedBox(height: 40),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(children: [
                TextSpan(
                    text: 'Ride',
                    style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                TextSpan(
                    text: 'Go',
                    style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFCC00))),
              ]),
            ),
            const SizedBox(height: 8),
            const Text('Safe, fast rides across Ghana 🇬🇭',
                style: TextStyle(color: Colors.white60, fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 60),

            // Rider Card
            _buildCard(
              context,
              emoji: '🚗',
              title: 'Rider',
              subtitle: 'Book rides across Ghana',
              loginLabel: 'Login as Rider',
              registerLabel: 'Create Rider Account',
              btnColor: const Color(0xFFFFCC00),
              btnText: Colors.black,
              outlineColor: Colors.white30,
              outlineText: Colors.white,
              onLogin: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RiderLoginScreen())),
              onRegister: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RiderRegisterScreen())),
            ),
            const SizedBox(height: 20),

            // Driver Card
            _buildCard(
              context,
              emoji: '🚙',
              title: 'Driver',
              subtitle: 'Earn money driving with RideGo',
              loginLabel: 'Login as Driver',
              registerLabel: 'Become a Driver',
              btnColor: Colors.white12,
              btnText: Colors.white,
              outlineColor: const Color(0xFFFFCC00),
              outlineText: const Color(0xFFFFCC00),
              onLogin: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DriverLoginScreen())),
              onRegister: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DriverRegisterScreen())),
            ),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required String loginLabel,
    required String registerLabel,
    required Color btnColor,
    required Color btnText,
    required Color outlineColor,
    required Color outlineText,
    required VoidCallback onLogin,
    required VoidCallback onRegister,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ]),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 13)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: btnText,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(loginLabel,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onRegister,
            style: OutlinedButton.styleFrom(
              foregroundColor: outlineText,
              side: BorderSide(color: outlineColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(registerLabel,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// RIDER REGISTER SCREEN
// ══════════════════════════════════════════════════════════════
class RiderRegisterScreen extends StatefulWidget {
  const RiderRegisterScreen({super.key});
  @override
  State<RiderRegisterScreen> createState() => _RiderRegisterScreenState();
}

class _RiderRegisterScreenState extends State<RiderRegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_name.text.isEmpty ||
        _email.text.isEmpty ||
        _phone.text.isEmpty ||
        _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }
    setState(() => _loading = true);
    final data = await ApiService.riderRegister(_name.text.trim(),
        _email.text.trim(), _phone.text.trim(), _password.text);
    setState(() => _loading = false);
    if (data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user_type', 'rider');
      await prefs.setString('user_name', data['user']['name']);
      await prefs.setString('user_email', data['user']['email']);
      await prefs.setString('user_phone', data['user']['phone'] ?? '');
      if (mounted)
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const RiderHomeScreen()));
    } else {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message'] ?? 'Registration failed'),
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
          foregroundColor: Colors.white,
          title: const Text('Create Rider Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 8),
          const Text('Join RideGo',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 32),
          _field(_name, 'Full Name', Icons.person),
          const SizedBox(height: 14),
          _field(_email, 'Email address', Icons.email_outlined,
              type: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _field(_phone, 'Phone (e.g. 0244123456)', Icons.phone,
              type: TextInputType.phone),
          const SizedBox(height: 14),
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
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _register,
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
                  : const Text('Create Account',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Already have an account? Login',
                style: TextStyle(color: Color(0xFFFFCC00))),
          ),
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
// DRIVER REGISTER SCREEN
// ══════════════════════════════════════════════════════════════
class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});
  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _license = TextEditingController();
  final _carMake = TextEditingController();
  final _carModel = TextEditingController();
  final _carYear = TextEditingController();
  final _carPlate = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _license.dispose();
    _carMake.dispose();
    _carModel.dispose();
    _carYear.dispose();
    _carPlate.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_name.text.isEmpty ||
        _email.text.isEmpty ||
        _phone.text.isEmpty ||
        _password.text.isEmpty ||
        _license.text.isEmpty ||
        _carMake.text.isEmpty ||
        _carModel.text.isEmpty ||
        _carYear.text.isEmpty ||
        _carPlate.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await ApiService.driverRegister(
        _name.text.trim(),
        _email.text.trim(),
        _phone.text.trim(),
        _password.text,
        _license.text.trim(),
        _carMake.text.trim(),
        _carModel.text.trim(),
        _carYear.text.trim(),
        _carPlate.text.trim(),
      );
      setState(() => _loading = false);
      if (data['success'] == true) {
        if (mounted) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                    title: const Text('Application Submitted! 🎉'),
                    content: const Text(
                        'Your driver application has been submitted. Wait for admin approval.'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCC00),
                            foregroundColor: Colors.black),
                        child: const Text('OK'),
                      )
                    ],
                  ));
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(data['message'] ?? 'Registration failed'),
              backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Connection failed.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text('Become a Driver')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Drive with RideGo',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const Text('Earn up to GHC 7,000 per week',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 24),
          const Text('👤 Personal Info',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 12),
          _field(_name, 'Full Name', Icons.person),
          const SizedBox(height: 12),
          _field(_email, 'Email', Icons.email_outlined,
              type: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _field(_phone, 'Phone (0244123456)', Icons.phone,
              type: TextInputType.phone),
          const SizedBox(height: 12),
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
          const SizedBox(height: 24),
          const Text('🚗 Vehicle Info',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 12),
          _field(_license, 'License Number', Icons.credit_card),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field(_carMake, 'Car Make', Icons.directions_car)),
            const SizedBox(width: 12),
            Expanded(
                child:
                    _field(_carModel, 'Model', Icons.directions_car_outlined)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _field(_carYear, 'Year', Icons.calendar_today,
                    type: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _field(_carPlate, 'Plate No.', Icons.pin)),
          ]),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _register,
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
                  : const Text('Submit Application',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
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
