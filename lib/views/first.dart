// lib/views/screens/first_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../screens/home_view.dart'; // Ganti import ke HomeView
import '../../view_models/auth_view_model.dart';
import '../../models/user.dart';

class FirstView extends StatefulWidget {
  const FirstView({super.key});

  @override
  State<FirstView> createState() => _FirstViewState();
}

class _FirstViewState extends State<FirstView> {
  final _usernameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool isRegisterMode = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final username = _usernameCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan Username terlebih dahulu')));
      return;
    }

    bool success = false;
    String message = '';

    if (isRegisterMode) {
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Masukkan Nama Pembeli untuk registrasi')));
        return;
      }
      success = await authViewModel.register(username, name);
      message = success ? 'Registrasi berhasil. Masuk otomatis.' : 'Username sudah terdaftar atau registrasi gagal.';
    } else {
      success = await authViewModel.login(username);
      final loggedInUser = authViewModel.currentUser;
      message = success ? 'Login berhasil! Selamat datang, ${loggedInUser?.name}' : 'Username tidak ditemukan. Coba lagi atau Daftar.';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (success && authViewModel.currentUser != null) {
      _navigateToHome(context, authViewModel.currentUser!);
    }
  }

  void _navigateToHome(BuildContext context, User user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeView(user: user)),
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
                child: Center(child: Text('LOGO RESTORAN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0D1B2A)))),
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
                onPressed: () => _submit(context),
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