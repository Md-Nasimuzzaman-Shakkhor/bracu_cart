import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        primaryColor: const Color(0xFF1E3A8A),
        useMaterial3: true,
      ),
      home: const LoginScreen(), 
    );
  }
}