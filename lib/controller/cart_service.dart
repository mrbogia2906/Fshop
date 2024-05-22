import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/model/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  void addItem(Product product) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product, quantity: 1),
      );
    }
    await _updateCartInFirestore(userId);
    notifyListeners();
  }

  void removeItem(String productId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _items.remove(productId);
    await _updateCartInFirestore(userId);
    notifyListeners();
  }

  void clear() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _items = {};
    await _updateCartInFirestore(userId);
    notifyListeners();
  }

  void decreaseItem(String productId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items.update(
          productId,
          (existingCartItem) => CartItem(
            product: existingCartItem.product,
            quantity: existingCartItem.quantity - 1,
          ),
        );
      } else {
        _items.remove(productId);
      }
      await _updateCartInFirestore(userId);
      notifyListeners();
    }
  }

  Future<void> _updateCartInFirestore(String userId) async {
    await _firestore.collection('carts').doc(userId).set({
      'items': _items.values.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
    });
  }
}

class CartItem {
  final Product product;
  final int quantity;
  double get totalPrice => product.price * quantity;

  CartItem({required this.product, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }
}
