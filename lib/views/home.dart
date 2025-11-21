// lib/views/home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../models/menu_item.dart';
import '../models/user.dart';
// --- IMPORTS UNTUK VIEWS DAN VIEWMODELS ---
import 'menu_page.dart';
import 'orders_page.dart';
import 'payment_page.dart';
import 'history_page.dart';
import 'first.dart';
import 'admin_menu_page.dart';
import 'admin_orders_page.dart'; // Import AdminOrdersPage
// ----------------------------------------------------
import '../view_models/auth_view_model.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/history_view_model.dart';
import '../view_models/menu_view_model.dart';
import '../view_models/admin_order_view_model.dart'; // Import AdminOrderViewModel

const Color COLOR_DARK_PRIMARY = Color(0xFF0D1B2A);
const Color COLOR_SECONDARY_ACCENT = Color(0xFF778DA9);

// --- BASE WIDGET ---

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    // Memuat menu dan data awal yang relevan
    Future.microtask(() {
      final menuVM = Provider.of<MenuViewModel>(context, listen: false);
      menuVM.loadMenu();

      // BARU: Muat juga data resep dari API (Contoh: mencari 'Chicken')
      menuVM.loadApiMeals('Chicken');

      // [BARU: Muat data Dessert & Drink dari API]
      menuVM.loadApiDrinksDesserts();

      if (widget.user.isAdmin) {
        // ADMIN: Muat pesanan pending saat Admin login
        final adminOrderVM = Provider.of<AdminOrderViewModel>(context, listen: false);
        adminOrderVM.loadPendingOrders();
      } else if (widget.user.id != null) {
        // CUSTOMER: Muat History-nya sendiri
        final historyVM = Provider.of<HistoryViewModel>(context, listen: false);
        historyVM.loadHistory(widget.user.id!);
      }
    });
  }

  void _logout() {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    authVM.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const FirstPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Periksa peran user untuk menentukan layout
    if (widget.user.isAdmin) {
      return AdminHomeLayout(user: widget.user, onLogout: _logout);
    } else {
      return CustomerHomeLayout(user: widget.user, onLogout: _logout);
    }
  }
}

// --- ADMIN LAYOUT (Hanya Menu, Admin Orders, dan Admin Menu) ---

class AdminHomeLayout extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;
  const AdminHomeLayout({super.key, required this.user, required this.onLogout});

  @override
  State<AdminHomeLayout> createState() => _AdminHomeLayoutState();
}

class _AdminHomeLayoutState extends State<AdminHomeLayout> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab untuk Admin
  final List<Tab> bottomTabs = [
    const Tab(icon: Icon(Icons.menu_book), text: 'Menu'),
    const Tab(icon: Icon(Icons.receipt_long), text: 'Admin Orders'), // Index 1
    const Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin Menu'), // Index 2
  ];

  late List<Widget> tabViews;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: bottomTabs.length, vsync: this);

    // Listener untuk memuat ulang data saat pindah ke tab Admin Orders (Index 1)
    _tabController.addListener(() {
      if (_tabController.index == 1 && _tabController.indexIsChanging == false) {
        // Panggil refresh data setiap kali tab ini diakses
        Provider.of<AdminOrderViewModel>(context, listen: false).loadPendingOrders();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuVM = Provider.of<MenuViewModel>(context);

    // INISIALISASI TABVIEWS DENGAN LOGIKA OTORISASI
    tabViews = [
      // Tab 0: MenuPage (Admin View, onAdd: null)
      MenuPage(menu: menuVM.menuItems, onAdd: null),
      // Tab 1: Admin Orders (Pesanan Pending dari semua Customer)
      const AdminOrdersPage(),
      // Tab 2: Admin Menu (Kelola Item Menu)
      const AdminMenuPage(),
    ];

    return Scaffold(
      appBar: CustomAppBar(title: 'EatMood - Admin', actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Center(child: Text('${widget.user.name} (Admin)', style: const TextStyle(color: Colors.white))),
        ),
        IconButton(icon: const Icon(Icons.logout), onPressed: widget.onLogout),
      ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Welcome, ${widget.user.name}. Gunakan tab Admin Orders untuk menerima pesanan pelanggan.', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: COLOR_DARK_PRIMARY)),
          ),
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

// --- CUSTOMER LAYOUT (Full Access) ---

class CustomerHomeLayout extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;
  const CustomerHomeLayout({super.key, required this.user, required this.onLogout});

  @override
  State<CustomerHomeLayout> createState() => _CustomerHomeLayoutState();
}

class _CustomerHomeLayoutState extends State<CustomerHomeLayout> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab untuk Customer
  final List<Tab> bottomTabs = [
    const Tab(icon: Icon(Icons.menu_book), text: 'Menu'),
    const Tab(icon: Icon(Icons.shopping_cart), text: 'Orders'),
    const Tab(icon: Icon(Icons.payment), text: 'Payment'),
    const Tab(icon: Icon(Icons.history), text: 'History'),
  ];

  late final List<Widget> tabViews;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: bottomTabs.length, vsync: this);

    // Inisialisasi tabViews menggunakan data dari Provider
    tabViews = [
      MenuPage(menu: [], onAdd: _addToCart),
      OrderPage(onProceed: () => _tabController.animateTo(2)),
      PaymentPage(onPay: _performCheckout),
      const HistoryPage(),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  void _addToCart(MenuItem item, int qty) {
    Provider.of<CartViewModel>(context, listen: false).addToCart(item, qty);
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ditambahkan $qty x ${item.name}')));
    }
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
      // Saat checkout, status defaultnya adalah 'pending'
      final record = await cartVM.prepareCheckout(paid, paymentMethod, user.id!, user.name);
      await historyVM.saveRecord(record);

      _tabController.animateTo(bottomTabs.indexWhere((tab) => tab.text == 'History'));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran Rp ${paid.toStringAsFixed(0)} berhasil dengan ${paymentMethod}. Menunggu konfirmasi Admin.')));
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checkout gagal: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuVM = Provider.of<MenuViewModel>(context);
    final cartVM = Provider.of<CartViewModel>(context);

    final width = MediaQuery.of(context).size.width;
    final String buyerName = widget.user.name;

    // Pastikan MenuPage di tabViews menggunakan data menu terbaru
    tabViews[0] = MenuPage(menu: menuVM.menuItems, onAdd: _addToCart); // onAdd valid untuk Customer

    return Scaffold(
      appBar: CustomAppBar(title: 'EatMood', actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Center(child: Text(buyerName, style: const TextStyle(color: Colors.white))),
        ),
        IconButton(icon: const Icon(Icons.logout), onPressed: widget.onLogout),
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
                    Expanded(child: Text('Welcome, $buyerName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
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
                    Text('Welcome, $buyerName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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