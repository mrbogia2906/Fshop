import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'controller/auth_service.dart';
import 'view/cart/carts_screen.dart';
import 'controller/product_service.dart';
import 'controller/cart_service.dart';
import 'controller/order_service.dart';
import 'controller/chat_service.dart';
import 'view/admin/admin_dash.dart';
import 'view/login/login_screen.dart';
import 'view/main_screen.dart';
import 'view/home/home_screen.dart';
import 'view/cart/checkout_screen.dart';
import 'view/order/order_confirm_screen.dart';
import 'view/order/orders_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ProductService>(create: (_) => ProductService()),
        Provider<ChatService>(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        Provider<OrderService>(create: (_) => OrderService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'First App',
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        initialRoute: '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/home': (context) => MainScreen(),
          '/cart': (context) => CartsScreen(),
          '/checkout': (context) =>
              CheckoutScreen(totalAmount: 0), // Pass the actual amount
          '/orderConfirmation': (context) => OrderConfirmationScreen(),
          '/orders': (context) => OrdersScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    var userBox = Hive.box('userBox');
    String? storedUserId = userBox.get('userId');

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          userBox.put('userId', snapshot.data!.uid);
          return FutureBuilder<DocumentSnapshot>(
            future: authService.getUserInfo(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }

              if (userSnapshot.hasData && userSnapshot.data != null) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final userRole = userData['role'];

                if (userRole == 'admin') {
                  return AdminHomeScreen();
                } else {
                  return MainScreen();
                }
              }

              return LoginScreen();
            },
          );
        } else if (storedUserId != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: authService.getUserInfo(storedUserId),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }

              if (userSnapshot.hasData && userSnapshot.data != null) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final userRole = userData['role'];

                if (userRole == 'admin') {
                  return AdminHomeScreen();
                } else {
                  return MainScreen();
                }
              }

              return LoginScreen();
            },
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
