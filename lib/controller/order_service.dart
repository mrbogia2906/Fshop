import 'package:cloud_firestore/cloud_firestore.dart';
import '/model/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getOrdersByStatus(String status) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: status)
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllOrders() {
    return _firestore.collection('orders').snapshots();
  }

  Future<void> createOrder(Order1 order) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection('orders').add({
      ...order.toMap(),
      'userId': userId,
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'status': status});
  }
}
