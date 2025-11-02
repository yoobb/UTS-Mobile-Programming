import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'home.dart';


class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final padding = w > 800 ? 48.0 : (w > 600 ? 32.0 : 16.0);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Login'),
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
                child: Center(child: Text('LOGO RESTORAN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)))), // Placeholder jika file tidak ditemukan
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Pembeli', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF778DA9), foregroundColor: Colors.white),
                onPressed: () {
                  final name = _nameCtrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan nama terlebih dahulu')));
                    return;
                  }
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(buyerName: name)));
                },
                child: const Text('Masuk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}