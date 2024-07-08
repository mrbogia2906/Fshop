import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/controller/order_service.dart';
import '/model/order_model.dart';
import '../order/order_confirm_screen.dart';
import '/controller/cart_service.dart';
import '/model/product.dart';

class CheckoutScreen extends StatelessWidget {
  final double totalAmount;

  CheckoutScreen({required this.totalAmount});

  void _submitOrder(BuildContext context) async {
    final user = Provider.of<CartProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) return;

    List<Product> products =
        cart.items.values.map((cartItem) => cartItem.product).toList();

    final order = Order1(
      id: '',
      quantity: cart.items.length,
      totalAmount: totalAmount,
      status: 'processing',
      date: DateTime.now(),
      userId: userId,
      products: products,
    );

    await OrderService().createOrder(order);
    cart.clear();

    Navigator.pushReplacementNamed(context, '/orderConfirmation');
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'vi',
      symbol: '₫',
      decimalDigits: 0,
    ).format(totalAmount);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Checkout',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Shipping Address
          ListTile(
            title: Text('Shipping Address'),
            trailing: Icon(Icons.edit),
          ),
          ListTile(
            title: Text('Nguyen Viet Khoa'),
            subtitle:
                Text('Cau Giay, Ha Noi, Viet Nam, 100000'),
          ),
          Divider(),
          // Payment Method
          ListTile(
            title: Text('Payment'),
            trailing: Icon(Icons.edit),
          ),
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text('MasterCard'),
            subtitle: Text('**** **** **** 0047'),
          ),
          Divider(),
          // Delivery Method
          ListTile(
            title: Text('Delivery method'),
            trailing: Icon(Icons.edit),
          ),
          ListTile(
            leading: Image.network(
                'https://static.ybox.vn/2024/4/1/1713148355815-logo.jpeg',
                fit: BoxFit.cover),
            title: Text('Normal (2-3 days)'),
          ),
          Divider(),
          // Order Summary
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order:', style: TextStyle(fontSize: 16)),
                Text(formattedPrice, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery:', style: TextStyle(fontSize: 16)),
                Text('Free', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(formattedPrice,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Submit Order Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _submitOrder(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Background color
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text('Submit Order'),
            ),
          ),
        ],
      ),
    );
  }
}
