import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the new login screen

void main() {
  runApp(const BracuCartApp());
}

class BracuCartApp extends StatelessWidget {
  const BracuCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BRACU-CART',
      theme: ThemeData(
        primaryColor: const Color(0xFF003366),
        useMaterial3: true,
      ),
      // App now boots straight into the Login Screen!
      home: const LoginScreen(), 
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String userRole;
  final String userEmail;

  // We accept the role and email when navigating to this screen
  const HomeScreen({super.key, required this.userRole, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BRACU-CART 🛒', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF003366),
        centerTitle: true,
        actions: [
          // Logout Button to return to Login Screen
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, $userEmail', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            
            // Dynamic Role Badge UI (Changes color based on role!)
            Container(
              // Or keep .only but spell out top and bottom
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              //  To this:
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: userRole == 'admin' ? Colors.red.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Role: ${userRole.toUpperCase()}',
                style: TextStyle(color: userRole == 'admin' ? Colors.red.shade800 : Colors.green.shade800, fontWeight: FontWeight.bold),
              ),
            ),
            
            const Divider(),
            const SizedBox(height: 12),
            
            // Conditional Admin Widget
            if (userRole == 'admin') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.amber.shade100,
                child: const Text(
                  '⚠️ ADMIN PANEL: You can delete reported posts.',
                  style: TextStyle(color: const Color(0xFF7F5100), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text('Marketplace Feed:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildSamplePost('CSE423 Midpoint Line Notes', 'Resources', 'Free', 'Shared by: Shabab'),
                  _buildSamplePost('iPhone 13 Pro Max', 'Electronics', '75,000 BDT', 'Seller: Fahim'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSamplePost(String title, String category, String price, String owner) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$category • $owner'),
        trailing: Text(price, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ),
    );
  }
}