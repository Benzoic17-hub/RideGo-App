import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);

    final res = await ApiService.riderRegister(
      _name.text,
      _email.text,
      _phone.text,
      _password.text,
    );

    setState(() => _loading = false);

    if (res['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', res['token']);
      await prefs.setString('user_name', res['user']['name']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RiderHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}