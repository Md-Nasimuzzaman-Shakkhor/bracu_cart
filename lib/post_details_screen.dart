import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const PostDetailsScreen({super.key, required this.data});

  void _launchWhatsApp(BuildContext context, String number, String itemTitle) async {
    String cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanNumber.startsWith('+')) {
      cleanNumber = '+880${cleanNumber.substring(cleanNumber.length - 10)}'; 
    }

    final String message = Uri.encodeComponent("Hello! I saw your post for '$itemTitle' on BRACU-CART and I am interested in buying it.");
    final Uri whatsappUri = Uri.parse("https://wa.me/$cleanNumber?text=$message");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp. Please check if it is installed.')),
        );
      }
    }
  }

  // Updates item status to true in Firestore collection
  void _markAsSold(BuildContext context, String? docId) async {
    if (docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not trace document ID reference.')),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).update({
        'isSold': true,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item successfully marked as Sold!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error marking as sold: $e");
    }
  }

  // Permanently removes listing out of Firestore backend safely
  void _deletePost(BuildContext context, String? docId) async {
    if (docId == null) return;
    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted successfully.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error deleting post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String postType = data['postType'] ?? 'Sell';
    final String title = data['title'] ?? 'No Title';
    final String desc = data['description'] ?? 'No Description';
    final String? imageBase64 = data['imageBase64'];
    
    // Grabs unique document record path index ID
    final String? docId = data['id']; 

    // Ownership Verification logic
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final String? postCreatorId = data['sellerId']; 
    final bool isOwner = (currentUserId != null && currentUserId == postCreatorId);

    // FIX: Read name dynamically with safe fallback string logic
    final String sellerName = data['sellerName'] ?? 'BRACU Student';

    return Scaffold(
      appBar: AppBar(title: Text(postType == 'Sell' ? 'Item Details' : 'Resource Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display Image if it's a sales post
            if (postType == 'Sell' && imageBase64 != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(imageBase64),
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Display Course Details if it's a resource post
            if (postType == 'Resource') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Code: ${data['courseCode'] ?? ''}', 
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16, 
                        color: Colors.blue,
                      ),
                    ),
                    Text('Course Name: ${data['courseName'] ?? ''}', style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            if (postType == 'Sell') ...[
              Text('${data['price'] ?? 0} BDT', style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
            ],

            // FIX: Premium Trust profile widget block added smoothly
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                    child: const Icon(Icons.person, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sellerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Verified BRACU Student Seller',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 32),

            // OWNER MANAGEMENT TOOLS (Visible only if current student uploaded this listing)
            if (isOwner) ...[
              if (postType == 'Sell') ...[
                ElevatedButton.icon(
                  onPressed: () => _markAsSold(context, docId),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('Mark as Sold', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Listing permanently?'),
                      content: const Text('Are you sure you want to delete this listing from BRACU-CART? This step cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _deletePost(context, docId);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text('Delete Listing', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ] 
            // BUYER ENGAGEMENT CONTROLS (Visible to everyone else checking out the item)
            else ...[
              if (postType == 'Sell') ...[
                ElevatedButton.icon(
                  onPressed: () => _launchWhatsApp(context, data['whatsapp'] ?? '', title),
                  icon: const Icon(Icons.phone),
                  label: const Text('Contact Seller via WhatsApp', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse(data['url'] ?? '');
                    if (await canLaunchUrl(url)) await launchUrl(url);
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Open Resource URL Link', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}