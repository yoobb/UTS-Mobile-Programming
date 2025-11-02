// lib/screens/home.dart
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../models/menu_item.dart';
import '../models/order_item.dart';
import '../models/payment.dart';
import 'menu_page.dart';
import 'orders_page.dart';
import 'payment_page.dart';
import 'history_page.dart';
import 'first.dart';
// Import baru
import '../models/user.dart';
import '../data/database_helper.dart';


const Color COLOR_DARK_PRIMARY = Color(0xFF0D1B2A);
const Color COLOR_SECONDARY_ACCENT = Color(0xFF778DA9);

class HomePage extends StatefulWidget {
  final User user; // Ganti dari buyerName ke User
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<MenuItem> menu = [];
  final List<OrderItem> cart = [];
  List<PaymentRecord> history = []; // Ubah menjadi non-final untuk update

  final dbHelper = DatabaseHelper.instance; // Inisiasi DB helper

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMenu();
    _loadHistory(); // Panggil fungsi untuk memuat history dari DB
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ... (metode _loadMenu tetap sama)
  void _loadMenu() {
    menu.clear();
    menu.addAll([
      MenuItem(id: 'm1', name: 'Spaghetti', price: 45000, description: 'Spaghetti lembut dengan saus daging tomat khas Italia, disajikan hangat dengan taburan keju parmesan.', image: 'assets/images/spaghetti.jpg', category: 'Main Course'),
      MenuItem(id: 'm2', name: 'Mac and Cheese', price: 40000, description: 'Makaroni berpadu dengan saus keju yang lembut dan creamy, disajikan hangat dengan taburan keju panggang di atasnya.', image: 'assets/images/mac.jpg', category: 'Main Course'),
      MenuItem(id: 'm3', name: 'Fish and Chips', price: 55000, description: 'Ikan fillet goreng renyah disajikan dengan kentang goreng dan saus tartar segar khas Inggris.', image: 'assets/images/fnc.jpg', category: 'Main Course'),
      MenuItem(id: 'm4', name: 'Chicken Cordon Bleu', price: 50000, description: 'Dada ayam isi smoked beef dan keju leleh, dibalut tepung roti renyah dan disajikan dengan saus krim lembut.', image: 'assets/images/ccb.jpg', category: 'Main Course'),
      MenuItem(id: 'm5', name: 'Carbonara', price: 45000, description: 'Spaghetti lembut dengan saus krim keju dan smoked beef, menciptakan rasa gurih dan creamy khas Italia.', image: 'assets/images/carbonara.jpg', category: 'Main Course'),
      MenuItem(id: 'm6', name: 'Chicken Steak', price: 55000, description: 'Steak ayam panggang dengan saus lada hitam pilihan, disajikan bersama sayuran rebus dan kentang goreng.', image: 'assets/images/chickensteak.jpg', category: 'Main Course'),
      MenuItem(id: 'm7', name: 'Grilled Salmon', price: 80000, description: 'Ikan salmon segar yang dipanggang sempurna dengan bumbu lemon butter, menghasilkan cita rasa lembut dan kaya aroma.', image: 'assets/images/grilledsalmon.jpg', category: 'Main Course'),
      MenuItem(id: 'm8', name: 'BBQ Ribs', price: 95000, description: 'Iga sapi empuk yang dipanggang perlahan dengan saus BBQ manis dan smoky, disajikan dengan kentang goreng dan sayuran segar.', image: 'assets/images/bbqribs.jpg', category: 'Main Course'),
      MenuItem(id: 'm9', name: 'Chicken Wings', price: 45000, description: 'Sayap ayam renyah dengan pilihan saus pedas, madu, atau BBQ — sempurna untuk camilan atau teman santai.', image: 'assets/images/chickenwings.jpg', category: 'Main Course'),
      MenuItem(id: 'm10', name: 'Mini Burger', price: 40000, description: 'Tiga mini burger dengan daging sapi juicy, keju meleleh, dan saus spesial, cocok untuk sharing atau camilan ringan.', image: 'assets/images/miniburger.jpg', category: 'Main Course'),
      MenuItem(id: 'm11', name: 'Beef Burger', price: 55000, description: 'Burger daging sapi premium dengan keju cheddar, selada segar, tomat, dan saus spesial dalam roti panggang lembut.', image: 'assets/images/beefburger.jpg', category: 'Main Course'),
      MenuItem(id: 'd1', name: 'Lava Cake', price: 25000, description: 'Kue cokelat lembut dengan lelehan cokelat hangat di dalamnya. Disajikan dengan taburan gula halus atau es krim untuk sensasi manis yang sempurna.', image: 'assets/images/lavacake.jpg', category: 'Dessert'),
      MenuItem(id: 'd2', name: 'Cheese Burnt Matcha', price: 28000, description: 'Perpaduan unik antara keju lembut dan aroma matcha yang khas, dengan lapisan atas yang sedikit gosong untuk cita rasa gurih dan manis yang seimbang.', image: 'assets/images/cbm.jpg', category: 'Dessert'),
      MenuItem(id: 'd3', name: 'Tiramisu', price: 30000, description: 'Dessert klasik Italia yang terbuat dari lapisan sponge cake lembut, kopi, dan krim mascarpone, menghasilkan rasa manis dan pahit yang elegan.', image: 'assets/images/tiramisu.jpg', category: 'Dessert'),
      MenuItem(id: 'd4', name: 'Pudding', price: 18000, description: 'Puding lembut bertekstur halus dengan rasa manis yang ringan, disajikan dingin untuk memberikan kesegaran di setiap suapan.', image: 'assets/images/pudding.jpg', category: 'Dessert'),
      MenuItem(id: 'd5', name: 'Waffle with Ice Cream', price: 30000, description: 'Waffle hangat dengan tekstur renyah di luar dan lembut di dalam, disajikan bersama satu scoop es krim pilihan dan sirup manis.', image: 'assets/images/wafflewice.jpg', category: 'Dessert'),
      MenuItem(id: 'd6', name: 'Ice Cream', price: 20000, description: 'Es krim lembut dan manis dengan berbagai varian rasa favorit seperti vanilla, cokelat, dan stroberi — sempurna untuk penutup yang menyegarkan.', image: 'assets/images/icecream.jpg', category: 'Dessert'),
      MenuItem(id: 'd7', name: 'Honey Pancake', price: 25000, description: 'Tumpukan pancake empuk disiram madu alami dan butter lembut, memberikan rasa manis yang menenangkan.', image: 'assets/images/honeypan.jpg', category: 'Dessert'),
      MenuItem(id: 'd8', name: 'Churros', price: 25000, description: 'Camilan khas Spanyol berupa adonan goreng panjang yang renyah di luar dan lembut di dalam, disajikan dengan saus cokelat atau karamel.', image: 'assets/images/churros.jpg', category: 'Dessert'),
      MenuItem(id: 'd9', name: 'Brownies', price: 22000, description: 'Kue cokelat padat dengan tekstur fudgy dan aroma cokelat pekat, cocok dinikmati hangat bersama es krim atau kopi.', image: 'assets/images/brownies.jpg', category: 'Dessert'),
      MenuItem(id: 'b1', name: 'Sweet Ice tea', price: 15000, description: 'Teh dingin manis yang menyegarkan, cocok dinikmati kapan saja.', image: 'assets/images/sicetea.jpg', category: 'Drink'),
      MenuItem(id: 'b2', name: 'Ice Tea', price: 12000, description: 'Teh hitam dingin tanpa gula dengan aroma khas yang ringan dan menyegarkan.', image: 'assets/images/icetea.jpg', category: 'Drink'),
      MenuItem(id: 'b3', name: 'lemon Tea', price: 18000, description: 'Teh dingin berpadu dengan perasan lemon segar, memberi sensasi asam manis alami.', image: 'assets/images/lemontea.jpg', category: 'Drink'),
      MenuItem(id: 'b4', name: 'Lychee Tea', price: 20000, description: 'Teh aromatik yang dipadukan dengan rasa manis dan wangi buah leci.', image: 'assets/images/lycheetea.jpg', category: 'Drink'),
      MenuItem(id: 'b5', name: 'Americano', price: 25000, description: 'Espresso murni yang dicampur air panas, menghasilkan rasa kopi kuat dan ringan sekaligus.', image: 'assets/images/americano.jpg', category: 'Drink'),
      MenuItem(id: 'b6', name: 'Caramel Macchiato', price: 30000, description: 'Perpaduan espresso, susu hangat, dan sirup karamel lembut yang manis dan creamy.', image: 'assets/images/caramelm.jpg', category: 'Drink'),
    ]);
  }

  // Metode baru untuk memuat history dari database
  void _loadHistory() async {
    // Pastikan user.id tidak null setelah login/register
    if (widget.user.id != null) {
      final loadedHistory = await dbHelper.getHistoryByUserId(widget.user.id!);
      setState(() {
        history = loadedHistory;
      });
    }
  }

  void addToCart(MenuItem item, int qty) {
    final found = cart.indexWhere((o) => o.item.id == item.id);
    if (found >= 0) {
      setState(() => cart[found].qty += qty);
    } else {
      setState(() => cart.add(OrderItem(item: item, qty: qty)));
    }
  }

  void removeFromCart(String itemId) {
    setState(() => cart.removeWhere((o) => o.item.id == itemId));
  }

  void updateCartQuantity(String itemId, int newQty) {
    final foundIndex = cart.indexWhere((o) => o.item.id == itemId);
    if (foundIndex >= 0) {
      setState(() {
        if (newQty > 0) {
          cart[foundIndex].qty = newQty;
        } else {
          // Remove if quantity is 0 or less
          cart.removeAt(foundIndex);
        }
      });
    }
  }


  double cartTotal() => cart.fold(0.0, (p, c) => p + c.total);

  void checkout(double paid, String paymentMethod) async { // Ubah ke async
    final total = cartTotal();
    final change = paid - total;

    final List<OrderItem> itemsPurchased = List.from(cart);

    final record = PaymentRecord(
      userId: widget.user.id!, // Gunakan ID User
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      buyerName: widget.user.name, // Gunakan nama terdaftar
      total: total,
      paid: paid,
      change: change,
      paymentMethod: paymentMethod,
      items: itemsPurchased,
    );

    // Simpan record ke database
    await dbHelper.insertPaymentRecord(record);

    // Muat ulang history dari database dan update UI
    await _loadHistory();

    setState(() {
      cart.clear();
      _tabController.index = 3;
    });
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;

    final String buyerName = widget.user.name; // Gunakan nama dari objek User

    const String currentAppBarTitle = 'EatMood';

    return Scaffold(

      appBar: CustomAppBar(title: currentAppBarTitle, actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Center(child: Text(buyerName, style: const TextStyle(color: Colors.white))),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () { //

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const FirstPage()),
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
                    Image.asset('assets/images/logo.png', height: 64, errorBuilder: (_, __, ___) => const SizedBox()),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Welcome, $buyerName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    ElevatedButton.icon(
                      onPressed: () => _tabController.animateTo(1),
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('View Cart'),
                      style: ElevatedButton.styleFrom(backgroundColor: COLOR_SECONDARY_ACCENT),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Image.asset('assets/images/logo.png', height: 64, errorBuilder: (_, __, ___) => const SizedBox()),
                    const SizedBox(height: 8),
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
              children: [
                MenuPage(menu: menu, onAdd: addToCart),
                OrdersPage(
                  cart: cart,
                  onRemove: removeFromCart,
                  onProceed: () => _tabController.index = 2,
                  onUpdateQty: updateCartQuantity,
                ),
                // Gunakan checkout yang sudah diubah (async dan save ke DB)
                PaymentPage(total: cartTotal(), onPay: checkout),
                HistoryPage(history: history),
              ],
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
          tabs: const [
            Tab(icon: Icon(Icons.menu_book), text: 'Menu'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Orders'),
            Tab(icon: Icon(Icons.payment), text: 'Payment'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
    );
  }
}