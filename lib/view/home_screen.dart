import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'banner_slider.dart';
import '/controller/product_service.dart';
import '/model/category_model.dart';
import '/model/product.dart';
import 'product_details_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 250, 250, 250),
        elevation: 0,
        title: Text(
          'Find your clothes',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              color: Colors.grey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              }),
        ],
      ),
      body: ListView(
        children: [
          // Auto-scrolling Banner
          BannerWidget(),
          // Category Selector
          StreamBuilder<List<Category>>(
            stream: productService.getCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Center(child: Text("No categories available"));
              }
              var categories = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CategoryButton(
                            text: 'All',
                            isSelected: selectedCategory == '',
                            onPressed: () {
                              setState(() {
                                selectedCategory = '';
                              });
                            },
                          ),
                          ...categories.map((category) {
                            return CategoryButton(
                              text: category.name,
                              isSelected: selectedCategory == category.name,
                              onPressed: () {
                                setState(() {
                                  selectedCategory = category.name;
                                });
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16),
            child: Text(
              'New Arrivals',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Product Grid
          Padding(
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
          ),
        ],
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  CategoryButton(
      {required this.text, required this.isSelected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? Colors.black : Colors.grey[200],
          primary: isSelected ? Colors.white : Colors.black,
        ),
        child: Text(text),
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
