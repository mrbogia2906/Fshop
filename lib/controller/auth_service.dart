import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> registerWithEmailAndPassword(
      String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'role':
              'user', // Default role is user, can be set to 'admin' as needed
        });

        // Save user data to Hive
        var userBox = Hive.box('userBox');
        userBox.put('userData', {
          'uid': user.uid,
          'name': name,
          'email': email,
          'role': 'user',
        });
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        DocumentSnapshot userSnapshot = await getUserInfo(user.uid);
        if (userSnapshot.exists) {
          var userData = userSnapshot.data() as Map<String, dynamic>;

          // Save user data to Hive
          var userBox = Hive.box('userBox');
          userBox.put('userData', userData);
        }
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      var userBox = Hive.box('userBox');
      userBox.delete('userData'); // Clear user data on logout
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<DocumentSnapshot> getUserInfo(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<int> getUserOrderCount(String userId) async {
    QuerySnapshot orderSnapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();
    return orderSnapshot.docs.length;
  }
}
