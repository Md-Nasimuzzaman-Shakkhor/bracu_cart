import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'post_details_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Listings History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: currentUserId == null
          ? const Center(child: Text('Please log in to view your listings.'))
          : StreamBuilder<QuerySnapshot>(
              // Query filters specifically for listings created by this exact student
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('sellerId', isEqualTo: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading your history.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'You haven\'t posted any items or resources yet!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final String title = data['title'] ?? 'No Title';
                    final String postType = data['postType'] ?? 'Sell';
                    final String? imageBase64 = data['imageBase64'];
                    final double price = (data['price'] ?? 0.0).toDouble();
                    final bool isSold = data['isSold'] ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: imageBase64 != null
                              ? Image.memory(base64Decode(imageBase64), fit: BoxFit.cover)
                              : const Icon(Icons.image, color: Colors.grey),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: isSold ? TextDecoration.lineThrough : null,
                            color: isSold ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(top: 4, right: 8),
                              decoration: BoxDecoration(
                                color: postType == 'Resource' ? Colors.blue[50] : Colors.green[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                postType,
                                style: TextStyle(
                                  color: postType == 'Resource' ? Colors.blue[800] : Colors.green[800],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              postType == 'Resource' ? 'FREE' : '${price.toStringAsFixed(0)} BDT',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSold ? Colors.grey : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSold ? Colors.red[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isSold ? 'SOLD' : 'ACTIVE',
                            style: TextStyle(
                              color: isSold ? Colors.red[700] : Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
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
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}