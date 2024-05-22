import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/controller/auth_service.dart';
import 'main_screen.dart';
import 'admin/admin_dash.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              'Clothing For You',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Welcome Here',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email or Phone',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Forget Password?'),
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        User? user =
                            await authService.signInWithEmailAndPassword(
                                _emailController.text,
                                _passwordController.text);

                        if (user != null) {
                          final userSnapshot = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get();

                          if (userSnapshot.exists) {
                            final userRole = userSnapshot['role'];

                            setState(() {
                              _isLoading = false;
                            });

                            if (userRole == 'admin') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdminHomeScreen()),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainScreen()),
                              );
                            }
                          } else {
                            throw Exception('User role not found.');
                          }
                        } else {
                          throw Exception('Failed to sign in.');
                        }
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.toString()),
                        ));
                      }
                    },
                    child: Text('Sign In'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 80.0),
                    ),
                  ),
            // SizedBox(height: 16.0),
            // Text('Or Sign in with'),
            // SizedBox(height: 16.0),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     IconButton(
            //       icon: Icon(Icons.facebook),
            //       onPressed: () {
            //         // Implement Facebook sign-in logic
            //       },
            //     ),
            //     IconButton(
            //       icon: Icon(Icons.apple),
            //       onPressed: () {
            //         // Implement Apple sign-in logic
            //       },
            //     ),
            //     IconButton(
            //       icon: Icon(Icons.close),
            //       onPressed: () {
            //         // Implement other sign-in logic
            //       },
            //     ),
            //   ],
            // ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationScreen()),
                );
              },
              child: Text(
                'Create an Account? Sign up',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
