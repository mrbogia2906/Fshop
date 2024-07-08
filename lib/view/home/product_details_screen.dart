import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/controller/cart_service.dart';
import '/model/product.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  ProductDetailsScreen(
      {required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final formattedPrice = NumberFormat.currency(
      locale: 'vi',
      symbol: '₫',
      decimalDigits: 0,
    ).format(product.price);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              image: DecorationImage(
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            product.name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                formattedPrice,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 16),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  Text('4.8 (48+ reviews)'),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Size:',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: ['S', 'M', 'L', 'XL', 'XXL']
                .map((size) => ChoiceChip(
                      label: Text(size),
                      selected:
                          size == 'M',
                      onSelected: (selected) {},
                    ))
                .toList(),
          ),
          SizedBox(height: 16),
          // Text(
          //   'Select Color: Grey-Blue',
          //   style: TextStyle(fontSize: 18),
          // ),
          // SizedBox(height: 8),
          // Wrap(
          //   spacing: 8.0, // Space between circles
          //   children: [
          //     Colors.red,
          //     Colors.green,
          //     Colors.blue,
          //     Colors.grey,
          //     Colors.black
          //   ]
          //       .map((color) => GestureDetector(
          //             onTap: () {
          //               // Handle color selection
          //             },
          //             child: CircleAvatar(
          //               backgroundColor: color,
          //               radius: 16,
          //             ),
          //           ))
          //       .toList(),
          // ),
          // SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            controller: TextEditingController(
                text: product.productInfo),
            maxLines: 4,
            readOnly: true,
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle add to cart
                cart.addItem(product);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text('Add to Cart', style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }
}
