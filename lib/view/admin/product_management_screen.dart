import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../model/product.dart';
import '../../controller/product_service.dart';
import 'create_product_screen.dart';
import 'update_product_screen.dart'; // Import the update product screen

class ProductManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Product Management',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Product>>(
        stream: productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("No products available"));
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Product product = snapshot.data![index];
              final formattedPrice = NumberFormat.currency(
                locale: 'vi',
                symbol: '₫',
                decimalDigits: 0,
              ).format(product.price);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateProductScreen(product: product),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(formattedPrice),
                            Text('Quantity: ${product.quantity}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => CreateProductScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
