import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const PostDetailsScreen({super.key, required this.data});

  // The Product Owner magic: Launching WhatsApp directly saves weeks of chat dev time!
  void _launchWhatsApp(BuildContext context, String number, String itemTitle) async {
    // Clean up the number layout safely
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

  @override
  Widget build(BuildContext context) {
    final String postType = data['postType'] ?? 'Sell';
    final String title = data['title'] ?? 'No Title';
    final String desc = data['description'] ?? 'No Description';
    final String? imageBase64 = data['imageBase64'];

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
                    // Line 67 fix inside lib/post_details_screen.dart
Text(
  'Course Code: ${data['courseCode'] ?? ''}', 
  style: const TextStyle(
    fontWeight: FontWeight.bold, 
    fontSize: 16, 
    color: Colors.blue, // Fixed here!
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

            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 32),

            // Contextual Action Buttons based on your Vision Strategy
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
        ),
      ),
    );
  }
}