import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'home.dart';
import '../data/database_helper.dart'; // Import baru
import '../models/user.dart'; // Import baru


class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final _usernameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(); // Untuk field Nama Pembeli saat register
  bool isRegisterMode = false;
  final dbHelper = DatabaseHelper.instance;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final username = _usernameCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan Username terlebih dahulu')));
      return;
    }

    if (isRegisterMode) {
      // Logic Registrasi
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Masukkan Nama Pembeli untuk registrasi')));
        return;
      }
      try {
        final existingUser = await dbHelper.getUserByUsername(username);
        if (existingUser != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Username sudah terdaftar. Silakan login.')));
          return;
        }

        final newUser = User(username: username, name: name);
        final newId = await dbHelper.insertUser(newUser);

        if (newId > 0) {
          final registeredUser = User(id: newId, username: username, name: name);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registrasi berhasil. Masuk otomatis.')));
          _navigateToHome(registeredUser);
        } else {
          throw Exception('Gagal menyimpan data user.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registrasi gagal: ${e.toString()}')));
      }
    } else {
      // Logic Login
      final user = await dbHelper.getUserByUsername(username);
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login berhasil! Selamat datang, ${user.name}')));
        _navigateToHome(user);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username tidak ditemukan. Coba lagi atau Daftar.')));
      }
    }
  }

  void _navigateToHome(User user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(user: user)), // Kirim objek User
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final padding = w > 800 ? 48.0 : (w > 600 ? 32.0 : 16.0);

    return Scaffold(
      appBar: CustomAppBar(title: isRegisterMode ? 'Daftar Akun' : 'Login'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/logoresto.jpeg',
              height: 250,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 250,
                child: Center(child: Text('LOGO RESTORAN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)))),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            if (isRegisterMode) ...[
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Pembeli', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF778DA9), foregroundColor: Colors.white),
                onPressed: _submit,
                child: Text(isRegisterMode ? 'Daftar' : 'Masuk'),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                setState(() {
                  isRegisterMode = !isRegisterMode;
                  _nameCtrl.clear();
                  _usernameCtrl.clear();
                });
              },
              child: Text(
                isRegisterMode ? 'Sudah punya akun? Login di sini' : 'Belum punya akun? Daftar di sini',
                style: const TextStyle(color: Color(0xFF0D1B2A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}