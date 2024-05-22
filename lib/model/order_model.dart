import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class Order1 {
  final String id;
  final int quantity;
  final double totalAmount;
  final String status;
  final DateTime date;
  final String userId;
  final List<Product> products;

  Order1({
    required this.id,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.date,
    required this.userId,
    required this.products,
  });

  factory Order1.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var productList = data['products'] as List<dynamic>? ?? [];
    var products =
        productList.map((productData) => Product.fromMap(productData)).toList();
    print("Products retrieved: $products"); // Debugging statement
    return Order1(
      id: doc.id,
      quantity: data['quantity'] ?? 0,
      totalAmount: data['totalAmount']?.toDouble() ?? 0.0,
      status: data['status'] ?? '',
      date: _parseDate(data['date']),
      userId: data['userId'] ?? '',
      products: products,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status,
      'date': date.toIso8601String(),
      'userId': userId,
      'products': products.map((product) => product.toMap()).toList(),
    };
  }

  static DateTime _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else {
      throw Exception('Invalid date type');
    }
  }
}
