import 'package:flutter/material.dart';
import 'main.dart'; // Allows us to navigate back to HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Helper function to handle navigation to the HomeScreen
  void _navigateToHome(BuildContext context, String role, String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(userRole: role, userEmail: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'BRACU-CART 🛒',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
                ),
                const SizedBox(height: 8),
                const Text('Login with your @g.bracu.ac.bd account', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                
                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'BRACU Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                
                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),

                // Real Login Button (Will connect to Firebase later)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003366)),
                    onPressed: () {
                      // Firebase logic goes here next week
                    },
                    child: const Text('Sign In', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // 🔥 QUICK ACCESS DEMO SECTION (Delete this block before production)
                const Text('⚡ DEMO QUICK ACCESS ⚡', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _navigateToHome(context, 'user', 'demo.student@g.bracu.ac.bd'),
                        child: const Text('Enter as User'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _navigateToHome(context, 'admin', 'demo.admin@g.bracu.ac.bd'),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                        child: const Text('Enter as Admin', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}