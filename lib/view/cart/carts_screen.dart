import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/controller/cart_service.dart';
import 'checkout_screen.dart';
import '/model/product.dart';

class CartsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final formattedPrice = NumberFormat.currency(
      locale: 'vi',
      symbol: '₫',
      decimalDigits: 0,
    ).format(cart.totalAmount);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: Text(
          'My Cart',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            color: Colors.black,
            onPressed: () {
              cart.clear();
            },
          ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(16.0),
                    children: [
                      ...cart.items.values.map((cartItem) => CartItemWidget(
                            cartItem: cartItem,
                            onRemove: () {
                              cart.removeItem(cartItem.product.id);
                            },
                            onIncrease: () {
                              cart.addItem(cartItem.product);
                            },
                            onDecrease: () {
                              cart.decreaseItem(cartItem.product.id);
                            },
                          )),
                      Divider(),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, -1),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sub Total', style: TextStyle(fontSize: 16)),
                          Text(formattedPrice, style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shipping', style: TextStyle(fontSize: 16)),
                          Text('Free', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(formattedPrice,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CheckoutScreen(
                                        totalAmount: cart.totalAmount,
                                      )),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Background color
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  CartItemWidget({
    required this.cartItem,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'vi',
      symbol: '₫',
      decimalDigits: 0,
    ).format(cartItem.totalPrice);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: NetworkImage(cartItem.product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cartItem.product.name, style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text('Size: ${cartItem.product.size}',
                  style: TextStyle(color: Colors.grey)),
              SizedBox(height: 4),
              Text(formattedPrice,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: onDecrease,
                  ),
                  Text('${cartItem.quantity}'),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: onIncrease,
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: onRemove,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
