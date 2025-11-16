import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/user.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/menu_view_model.dart'; // Import MenuViewModel
import 'home.dart';
import '../models/menu_item.dart'; // Import MenuItem

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final _usernameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool isRegisterMode = false;

  @override
  void initState() {
    super.initState();
    _ensureAdminAndMenuSeeded();
  }

  // Data menu awal yang akan disimpan ke database jika kosong
  final List<MenuItem> initialMenu = [
    MenuItem(id: 'm1', name: 'Spaghetti', price: 45000, description: 'Spaghetti lembut dengan saus daging tomat khas Italia, disajikan hangat dengan taburan keju parmesan.', image: 'assets/images/spaghetti.jpg', category: 'Main Course'),
    MenuItem(id: 'm2', name: 'Mac and Cheese', price: 40000, description: 'Makaroni berpadu dengan saus keju yang lembut dan creamy, disajikan hangat dengan taburan keju panggang di atasnya.', image: 'assets/images/mac.jpg', category: 'Main Course'),
    MenuItem(id: 'd1', name: 'Lava Cake', price: 25000, description: 'Kue cokelat lembut dengan lelehan cokelat hangat di dalamnya.', image: 'assets/images/lavacake.jpg', category: 'Dessert'),
    MenuItem(id: 'b5', name: 'Americano', price: 25000, description: 'Espresso murni yang dicampur air panas, menghasilkan rasa kopi kuat dan ringan sekaligus.', image: 'assets/images/americano.jpg', category: 'Drink'),
  ];

  // Fungsi untuk memastikan admin terdaftar dan menu awal ada
  Future<void> _ensureAdminAndMenuSeeded() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final menuViewModel = Provider.of<MenuViewModel>(context, listen: false);

    // 1. Pastikan Admin terdaftar
    final adminUser = await authViewModel.dbHelper.getAdminUser();
    if (adminUser == null) {
      await authViewModel.dbHelper.insertUser(User(username: 'admin', name: 'Admin Resto', role: 'admin'));
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akun Admin (admin/Admin Resto) telah dibuat otomatis.')));
      }
    }

    // 2. Isi menu awal jika kosong
    await menuViewModel.seedInitialMenu(initialMenu);
  }

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
      // Semua user yang mendaftar manual akan memiliki role 'customer'
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
      MaterialPageRoute(builder: (_) => HomePage(user: user)),
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

            // Tambahkan catatan untuk Admin Login
            const Text(
              'Catatan: Login sebagai Admin dengan Username: admin',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

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