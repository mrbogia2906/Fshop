import 'package:cloud_firestore/cloud_firestore.dart';
import '/model/category_model.dart';
import '/model/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Future<List<Product>> getProducts2() async {
    var snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    var allProducts = await getProducts2();
    return allProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Stream<List<Category>> getCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  Stream<List<Product>> getProductsByCategori({String categoryId = ''}) {
    Query query = _firestore.collection('products');
    if (categoryId.isNotEmpty) {
      query = query.where('category', isEqualTo: categoryId);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<List<Product>> getSuggestedProducts({int limit = 5}) async {
    var snapshot = await _firestore.collection('products').limit(limit).get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }
}
