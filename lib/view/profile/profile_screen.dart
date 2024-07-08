import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '/controller/auth_service.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  int _orderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    var box = Hive.box('userBox');
    var userData = box.get('userData');
    if (userData != null && userData is Map) {
      setState(() {
        _userData = Map<String, dynamic>.from(userData as Map);
      });
      await _loadOrderCount(userData['uid']);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadOrderCount(String userId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    int orderCount = await authService.getUserOrderCount(userId);
    setState(() {
      _orderCount = orderCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildProfileHeader(),
                _buildProfileOption(
                  icon: Icons.people,
                  title: "Your Profile",
                  subtitle: "Personal info",
                  onTap: () {
                    // Navigate to addresses page
                  },
                ), // User profile header
                _buildProfileOption(
                  icon: Icons.shopping_bag_outlined,
                  title: "My Orders",
                  subtitle: "Already have $_orderCount orders",
                  onTap: () {
                    // Navigate to orders page
                    Navigator.pushNamed(context, '/orders');
                  },
                ),
                _buildProfileOption(
                  icon: Icons.location_on_outlined,
                  title: "Shipping Addresses",
                  subtitle: " Addresses",
                  onTap: () {
                    // Navigate to addresses page
                  },
                ),
                _buildProfileOption(
                  icon: Icons.payment,
                  title: "Payment Method",
                  subtitle: "Momo",
                  onTap: () {
                    // Navigate to payment methods page
                  },
                ),
                _buildProfileOption(
                  icon: Icons.star_border,
                  title: "My reviews",
                  subtitle: "Reviews",
                  onTap: () {
                    // Navigate to reviews page
                  },
                ),
                _buildProfileOption(
                  icon: Icons.settings,
                  title: "Setting",
                  subtitle: "FAQ, Contact",
                  onTap: () {
                    // Navigate to settings page
                  },
                ),
                _buildLogoutButton(),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          // CircleAvatar(
          //   radius: 40,
          //   backgroundImage: NetworkImage(
          //       _userData?['photoURL'] ?? 'https://via.placeholder.com/150'),
          // ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData?['name'] ?? 'Username',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  _userData?['email'] ?? 'email@example.com',
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: ElevatedButton(
        onPressed: () async {
          await context.read<AuthService>().signOut();
          var box = Hive.box('userBox');
          box.delete('userData'); // Clear user data on logout
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        },
        child: Text('Logout', style: TextStyle(color: Colors.white),),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: Size.fromHeight(50),
        ),
      ),
    );
  }
}
