import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../models/menu_item.dart';
import '../models/user.dart';
// --- IMPORTS YANG BENAR DENGAN NAMA FILE LAMA ---
import 'menu_page.dart';
import 'orders_page.dart';
import 'payment_page.dart';
import 'history_page.dart';
import 'first.dart'; // Menggunakan first.dart
import 'admin_menu_page.dart'; // Import AdminMenuPage (BARU)
// ----------------------------------------------------
import '../view_models/auth_view_model.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/history_view_model.dart';
import '../view_models/menu_view_model.dart'; // Import MenuViewModel (BARU)

const Color COLOR_DARK_PRIMARY = Color(0xFF0D1B2A);
const Color COLOR_SECONDARY_ACCENT = Color(0xFF778DA9);

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  // Hapus list menu statis, karena akan dimuat dari ViewModel

  // Tentukan jumlah tab, bisa 4 (Customer) atau 5 (Admin)
  int get _tabCount => widget.user.isAdmin ? 5 : 4;

  @override
  void initState() {
    super.initState();
    // Inisialisasi TabController dengan jumlah tab dinamis
    _tabController = TabController(length: _tabCount, vsync: this);

    // Memuat menu dan history saat halaman dimuat
    Future.microtask(() {
      final menuVM = Provider.of<MenuViewModel>(context, listen: false);
      menuVM.loadMenu(); // Muat menu dari database

      final historyVM = Provider.of<HistoryViewModel>(context, listen: false);
      if (widget.user.id != null) {
        historyVM.loadHistory(widget.user.id!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Hapus _loadMenu karena sekarang data dimuat dari ViewModel

  void _addToCart(MenuItem item, int qty) {
    Provider.of<CartViewModel>(context, listen: false).addToCart(item, qty);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ditambahkan $qty x ${item.name}')));
  }

  void _performCheckout(double paid, String paymentMethod) async {
    final cartVM = Provider.of<CartViewModel>(context, listen: false);
    final historyVM = Provider.of<HistoryViewModel>(context, listen: false);
    final user = widget.user;

    if (user.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: User ID tidak ditemukan.')));
      }
      return;
    }

    try {
      final record = await cartVM.prepareCheckout(
          paid,
          paymentMethod,
          user.id!,
          user.name
      );

      await historyVM.saveRecord(record);

      _tabController.index = widget.user.isAdmin ? 3 : 2; // Pindah ke tab History atau Payment/Orders

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran Rp ${paid.toStringAsFixed(0)} berhasil dengan ${paymentMethod}')));
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checkout gagal: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final cartVM = Provider.of<CartViewModel>(context);
    final menuVM = Provider.of<MenuViewModel>(context); // Ambil MenuViewModel

    final width = MediaQuery.of(context).size.width;
    final String buyerName = widget.user.name;
    final bool isAdmin = widget.user.isAdmin;

    const String currentAppBarTitle = 'EatMood';

    // List widget TabBarView
    final List<Widget> tabViews = [
      // MenuPage sekarang mengambil menu dari MenuViewModel
      MenuPage(menu: menuVM.menuItems, onAdd: _addToCart),
      OrderPage(onProceed: () => _tabController.index = (isAdmin ? 3 : 2)),
      PaymentPage(onPay: _performCheckout),
      HistoryPage(),
    ];

    // List tab di BottomNavigationBar
    final List<Widget> bottomTabs = [
      const Tab(icon: Icon(Icons.menu_book), text: 'Menu'),
      const Tab(icon: Icon(Icons.shopping_cart), text: 'Orders'),
      const Tab(icon: Icon(Icons.payment), text: 'Payment'),
      const Tab(icon: Icon(Icons.history), text: 'History'),
    ];

    if (isAdmin) {
      tabViews.add(const AdminMenuPage()); // Tambahkan halaman Admin
      bottomTabs.add(const Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin Menu'));
    }

    return Scaffold(
      appBar: CustomAppBar(title: currentAppBarTitle, actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Center(child: Text(buyerName, style: const TextStyle(color: Colors.white))),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            authVM.logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const FirstPage()), // Panggil FirstPage
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ]),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return Row(
                  children: [
                    Image.asset('assets/images/logoresto.jpeg', height: 64, errorBuilder: (_, __, ___) => const SizedBox()),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Welcome, $buyerName${isAdmin ? ' (Admin)' : ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),

                    Consumer<CartViewModel>(
                      builder: (context, cartVM, child) => ElevatedButton.icon(
                        onPressed: () => _tabController.animateTo(1),
                        icon: Badge(
                            label: Text('${cartVM.cart.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                            isLabelVisible: cartVM.cart.isNotEmpty,
                            child: const Icon(Icons.shopping_cart_outlined)
                        ),
                        label: const Text('View Cart'),
                        style: ElevatedButton.styleFrom(backgroundColor: COLOR_SECONDARY_ACCENT),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Text('Welcome, $buyerName${isAdmin ? ' (Admin)' : ''}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                );
              }
            }),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabViews,
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        color: const Color(0xFFE0E1DD),
        child: TabBar(
          controller: _tabController,
          labelColor: COLOR_DARK_PRIMARY,
          unselectedLabelColor: Colors.grey,
          indicatorColor: COLOR_SECONDARY_ACCENT,
          tabs: bottomTabs,
        ),
      ),
    );
  }
}