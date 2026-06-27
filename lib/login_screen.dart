import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
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
  final _db = FirebaseFirestore.instance; 

  bool _isLoginMode = true; 
  bool _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Security Matrix Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
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

    if (!email.endsWith('@g.bracu.ac.bd') && !email.endsWith('@bracu.ac.bd')) {
      _showErrorDialog('Access Restricted: You must use a valid BRACU institutional email address.');
      return;
    }

    if (password.isEmpty || password.length < 6) {
      _showErrorDialog('Password must be at least 6 characters long.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLoginMode) {
        // Authenticate existing workspace session
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        // Create an institutional ecosystem user entry mapping
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password,
        );

        // Securely write entry metadata tracking dynamic UIDs
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'role': 'student', 
        });
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'An institutional auth exception occurred.');
    } catch (e) {
      _showErrorDialog('An unexpected system synchronization error occurred. Please retry.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Live testing automation pipeline bypass script optimized for loose rules
  Future<void> _bypassLogin(String role, String mockEmail) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Authenticate local workspace testing session anonymously
      UserCredential userCredential = await _auth.signInAnonymously();
      
      // 2. Set structural mock doc inside Firestore collection bypass parameters
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'email': mockEmail,
        'role': role,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showErrorDialog('Signature Workspace Engine: Bypass sync drop failed. Ensure database rules are set to public write mode. Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      backgroundColor: const Color(0xFFF8FAFC), // Premium light slate canvas
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Sleek Navy Institutional App Branding Header
                const Icon(Icons.shopping_bag_outlined, size: 76, color: Color(0xFF1E3A8A)),
                const SizedBox(height: 12),
                const Text(
                  'BRACU-CART',
                  style: TextStyle(
                    fontSize: 30, 
                    fontWeight: FontWeight.w900, 
                    color: Color(0xFF1E3A8A), 
                    letterSpacing: 2.0,
                  ),
                ),
                const Text(
                  'The Premium Institutional Student Marketplace',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 28),
                
                // 2. Main Authentication Context Container Card
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey[200]!, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          _isLoginMode ? 'Sign In to Workspace' : 'Create Student Profile',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A)),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'BRACU Email Address',
                            hintText: 'student@g.bracu.ac.bd',
                            prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF1E3A8A)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Account Security Key',
                            prefixIcon: const Icon(Icons.lock_open_outlined, color: Color(0xFF1E3A8A)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const CircularProgressIndicator(color: Color(0xFF1E3A8A))
                            : ElevatedButton(
                                onPressed: _submitAuth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _isLoginMode ? 'Access Portal' : 'Register Profile',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoginMode = !_isLoginMode;
                    });
                  },
                  child: Text(
                    _isLoginMode
                        ? "New to the hub? Create an Account"
                        : "Already registered? Access Portal Here",
                    style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(height: 1, thickness: 1.2),
                ),
                
                // 3. Clean Dashboard Quick Testing Environment Triggers
                const Text(
                  '🛠️ ACTIVE WORKSPACE TESTING ACCELERATION',
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _bypassLogin('student', 'student.demo@bracu.ac.bd'),
                        icon: const Icon(Icons.face, size: 18),
                        label: const Text('Bypass Student'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E3A8A),
                          side: const BorderSide(color: Color(0xFF1E3A8A)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _bypassLogin('admin', 'demo.admin@g.bracu.ac.bd'),
                        icon: const Icon(Icons.admin_panel_settings_outlined, size: 18, color: Colors.white),
                        label: const Text('Bypass Admin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // 4. Premium Brand Footer Footprint Implementation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 13, color: Colors.grey[400]),
                    const SizedBox(width: 5),
                    Text(
                      'Ecosystem Powered by Signature Tech',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
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