import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'order_detail_screen.dart';
import '/model/order_model.dart';
import '/controller/order_service.dart';
import 'package:provider/provider.dart'; // Import Provider to access the OrderService

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Delivered', 'Processing', 'Canceled'];

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('MY ORDERS', style: TextStyle(color: Colors.black)),
          centerTitle: true,
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
          ),
        ),
        body: TabBarView(
          children: _tabs.map((tab) {
            return StreamBuilder<QuerySnapshot>(
              stream: orderService.getOrdersByStatus(tab.toLowerCase()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No orders found"));
                }
                return ListView(
                  padding: EdgeInsets.all(16.0),
                  children: snapshot.data!.docs.map((doc) {
                    var order = Order1.fromFirestore(doc);
                    return OrderCard(order: order);
                  }).toList(),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order1 order;

  OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'vi',
      symbol: '₫',
      decimalDigits: 0,
    ).format(order.totalAmount);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order No${order.id}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(order.date),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity: ${order.quantity.toString().padLeft(2, '0')}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total Amount: $formattedPrice',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Order Details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsScreen(order: order),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Detail', style: TextStyle(color: Colors.white),),
                ),
                Text(
                  order.status,
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
