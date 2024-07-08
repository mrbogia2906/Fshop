import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String productInfo;
  final String size;
  final int quantity;
  final String category;
  final String imageUrl; // Add the imageUrl field

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.productInfo,
    required this.size,
    required this.quantity,
    required this.category,
    required this.imageUrl,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      productInfo: data['productInfo'] ?? '',
      size: data['size'] ?? '',
      quantity: data['quantity']?.toInt() ?? 0,
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'productInfo': productInfo,
      'size': size,
      'quantity': quantity,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      productInfo: data['productInfo'] ?? '',
      size: data['size'] ?? '',
      quantity: data['quantity']?.toInt() ?? 0,
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
