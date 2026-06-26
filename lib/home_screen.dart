import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String userRole;
  final String userEmail;

  const HomeScreen({
    super.key, 
    required this.userRole, 
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = userRole == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('BRACU-CART Dashboard 🛒'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Welcome back,',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Text(
              userEmail,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 20),

            // Conditional Admin Dashboard Panel
            if (isAdmin) ...[
              Card(
                color: Colors.amber[50],
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.amber, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: Colors.amber, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Admin Control Panel Active',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown),
                            ),
                            Text(
                              'You have moderation access to remove reports, ban scam listings, and clear flags.',
                              style: TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // General Student Marketplace View Placeholder
            const Text(
              'Recent Campus Listings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Text(
                  'No listings available yet.\nDatabase setup coming up next!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}