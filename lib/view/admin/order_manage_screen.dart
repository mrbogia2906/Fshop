import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //package for currency formatting

import '../order/order_detail_screen.dart';
import '../../model/order_model.dart';
import '../../controller/order_service.dart';

class OrderManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Manage Orders', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: OrderService().getAllOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var orders = snapshot.data!.docs
              .map((doc) => Order1.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              return OrderCard(
                order: order,
                onUpdateStatus: (status) {
                  OrderService().updateOrderStatus(order.id, status);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order1 order;
  final Function(String) onUpdateStatus;

  OrderCard({required this.order, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(order.totalAmount);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ${order.id}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Quantity: ${order.quantity}'),
              Text(formattedPrice),
              Text('Status: ${order.status}',
                  style: TextStyle(color: Colors.blue)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => onUpdateStatus('delivered'),
                    child: Text('Delivered'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => onUpdateStatus('canceled'),
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
