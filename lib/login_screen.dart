import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Add this import
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance; // 2. Initialize Firestore instance

  bool _isLoginMode = true; 
  bool _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showErrorDialog('Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _showErrorDialog('Password must be at least 6 characters long.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential;
      String role = 'student'; // Default role

      // Determine tentative role for demonstration/routing
      if (email.endsWith('@g.bracu.ac.bd')) {
        role = 'admin';
      }
      
      if (_isLoginMode) {
        // 🔐 Log In Existing User
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Fetch their real assigned role straight from the database!
        final userDoc = await _db.collection('users').doc(userCredential.user!.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          role = userDoc.data()!['role'] ?? 'student';
        }

      } else {
        // 📝 Register New User
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // 🗄️ Save profile details into the Cloud Firestore Database
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'role': role, // Saves 'admin' if BRACU mail ends with @g.bracu.ac.bd, else 'student'
          'createdAt': Timestamp.now(),
        });
      }

      if (!mounted) return;

// Change that block to just this clean layout:
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const HomeScreen(),
  ),
);

    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'Authentication failed.');
    } catch (e) {
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

void _bypassLogin(String role, String email) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const HomeScreen(),
    ),
  );
}

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'BRACU-CART',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              Text(
                _isLoginMode ? 'Your Campus Marketplace' : 'Create Student Account',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),
              
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'BRACU Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.brown,
                        ),
                        onPressed: _submitAuth,
                        child: Text(
                          _isLoginMode ? 'Log In' : 'Sign Up',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
              
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                  });
                },
                child: Text(
                  _isLoginMode
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Log In",
                  style: const TextStyle(color: Colors.brown),
                ),
              ),
              
              const Divider(height: 40, thickness: 1),
              
              const Text(
                '⚡ DEMO BYPASS OPTIONS',
                style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _bypassLogin('student', 'student.demo@bracu.ac.bd'),
                    child: const Text('Enter as Student'),
                  ),
                  ElevatedButton(
                    onPressed: () => _bypassLogin('admin', 'demo.admin@g.bracu.ac.bd'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[300]),
                    child: const Text('Enter as Admin'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}