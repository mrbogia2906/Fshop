import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/model/product.dart';
import 'product_details_screen.dart';
import '/controller/product_service.dart';

class ProductList extends StatelessWidget {
  final String selectedCategory;
  final ProductService productService;

  ProductList({required this.selectedCategory, required this.productService});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<Product>>(
        stream: productService.getProductsByCategori(categoryId: selectedCategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("No products available"));
          }
          var products = snapshot.data!;
          return GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              Product product = products[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailsScreen(product: product),
                    ),
                  );
                },
                child: ProductCard(product: product),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'vi',
      symbol: '₫',
      decimalDigits: 0,
    ).format(product.price);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            image: DecorationImage(
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(product.name, style: TextStyle(fontSize: 16)),
        SizedBox(height: 4),
        Text(formattedPrice,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
