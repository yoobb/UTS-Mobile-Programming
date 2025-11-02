import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final double total;
  final void Function(double paid, String paymentMethod) onPay;

  const PaymentPage({super.key, required this.total, required this.onPay});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  final List<String> paymentMethods = ['Cash', 'Card (Debit/Credit)', 'Transfer (QRIS/Bank)'];
  late String selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    selectedPaymentMethod = paymentMethods.first;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.total;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [

          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Metode Pembayaran',
                  border: InputBorder.none,
                ),
                value: selectedPaymentMethod,
                items: paymentMethods.map((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedPaymentMethod = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              title: const Text('Total Pembayaran'),
              trailing: Text('Rp ${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 12),
          ElevatedButton(

            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF778DA9), minimumSize: const Size.fromHeight(48)),
            onPressed: () {
              // Asumsi Paid = Total
              final paid = widget.total;

              if (paid <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Total pembayaran harus lebih dari nol')));
                return;
              }

              widget.onPay(paid, selectedPaymentMethod);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran Rp ${paid.toStringAsFixed(0)} berhasil dengan ${selectedPaymentMethod}')));
            },
            child: Text('Bayar (Total: Rp ${total.toStringAsFixed(0)})'),
          )
        ],
      ),
    );
  }
}