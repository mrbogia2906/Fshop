import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/model/order_model.dart';
import '/model/product.dart';

// Helper method to format the date
String formatDate(DateTime date) {
  final hours = date.hour.toString().padLeft(2, '0');
  final minutes = date.minute.toString().padLeft(2, '0');
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} $hours:$minutes';
}

class OrderDetailsScreen extends StatelessWidget {
  final Order1 order;

  OrderDetailsScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'vi',
      symbol: '₫',
      decimalDigits: 0,
    ).format(order.totalAmount);
    print("Displaying order details: ${order.products}"); // Debugging statement
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Order Details',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order No: ${order.id}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
                'Date: ${formatDate(order.date)}'), // Use the formatDate method
            SizedBox(height: 8),
            Text(
              'Status: ${order.status}',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 8),
            Text('Total Amount: $formattedPrice',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Products:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: order.products.length,
                itemBuilder: (context, index) {
                  var product = order.products[index];
                  return ProductItem(product: product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;

  ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'vi',
      symbol: '₫',
      decimalDigits: 0,
    ).format(product.price);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(
                      product.imageUrl), // Use placeholder image URL
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Size: ${product.size}',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('Qty: ${product.quantity}',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text(formattedPrice,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
