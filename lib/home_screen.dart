import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_product_screen.dart';
import 'login_screen.dart';
import 'post_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      
      // 1. Premium Top Bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A), // Deep Navy Blue
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'BRACU-CART',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      // 2. Clickable Left Sidebar Drawer
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
              accountName: const Text('BRACU Student', style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? 'student@g.bracu.ac.bd'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF1E3A8A), size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.storefront, color: Color(0xFF1E3A8A)),
              title: const Text('Marketplace Feed', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: const Text('My Listings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border, color: Colors.grey),
              title: const Text('Saved Items'),
              onTap: () {},
            ),
            const Divider(),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout Account', style: TextStyle(color: Colors.redAccent)),
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

      // 3. Main Screen Layout Matrix
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // MILESTONE UPDATED: Pulling all posts (both available and sold) ordered by newest first
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading marketplace feed.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No active listings found.\nTap Sell / Share to list something!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    final String postType = data['postType'] ?? 'Sell';
                    final String title = data['title'] ?? 'No Title';
                    final String desc = data['description'] ?? '';
                    final String? imageBase64 = data['imageBase64'];
                    final double price = (data['price'] ?? 0.0).toDouble();
                    final bool isSold = data['isSold'] ?? false; // Track sold state flags

                    return InkWell(
                      onTap: () {
                        final Map<String, dynamic> dataPayload = Map<String, dynamic>.from(data);
                        dataPayload['id'] = docs[index].id;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailsScreen(data: dataPayload),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  // Base Product Image
                                  Container(
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: imageBase64 != null
                                        ? Image.memory(base64Decode(imageBase64), fit: BoxFit.cover)
                                        : const Icon(Icons.image, color: Colors.grey, size: 40),
                                  ),
                                  
                                  // Type Badge (Sell / Resource)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: postType == 'Resource' ? Colors.blue : Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        postType,
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),

                                  // VISUAL EXTRA: Translucent Solid Dark Overlay + Premium Centered "SOLD" Stamp
                                  if (isSold)
                                    Container(
                                      color: Colors.black.withOpacity(0.55),
                                      alignment: Alignment.center,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.redAccent, width: 2.5),
                                          borderRadius: BorderRadius.circular(6),
                                          color: Colors.black.withOpacity(0.4),
                                        ),
                                        child: const Text(
                                          'SOLD',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 14,
                                      // Slightly dim text if the item is gone
                                      color: isSold ? Colors.grey[500] : Colors.black,
                                      decoration: isSold ? TextDecoration.lineThrough : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    desc,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    postType == 'Resource' ? 'FREE' : '${price.toStringAsFixed(0)} BDT',
                                    style: TextStyle(
                                      color: isSold 
                                          ? Colors.grey[400] 
                                          : (postType == 'Resource' ? Colors.blue[800] : Colors.green[700]),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      decoration: isSold ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 4. Clean Signature Tech Footer Branding Layout
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 140),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.verified_user_outlined, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  'Powered by Signature Tech',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // 5. Floating Action Button correctly placed inside the Scaffold scope
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        label: const Text('Sell / Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }
}