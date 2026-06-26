import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/image_helper.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Common controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Sell Post specific controllers
  final _priceController = TextEditingController();
  final _whatsappController = TextEditingController();

  // Resource Post specific controllers
  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _urlController = TextEditingController();

  String _postType = 'Sell'; // 'Sell' or 'Resource'
  String _selectedCategory = 'Books';
  String? _base64Image;
  bool _isLoading = false;

  final List<String> _categories = [
    'Books',
    'Electronics',
    'Food',
    'Resources',
    'Business',
    'Other'
  ];

  // SMART UTILITY FUNCTION: Converts "first.last@g.bracu.ac.bd" -> "First Last"
  String _extractNameFromEmail(String email) {
    try {
      String username = email.split('@').first;
      List<String> parts = username.split('.').map((part) {
        if (part.isEmpty) return '';
        return part[0].toUpperCase() + part.substring(1).toLowerCase();
      }).toList();
      return parts.join(' ').trim();
    } catch (e) {
      return 'BRACU Student'; // Safe fallback standard
    }
  }

  Future<void> _pickProductImage() async {
    final base64Str = await ImageHelper.pickAndCompressImage();
    if (base64Str != null) {
      setState(() {
        _base64Image = base64Str;
      });
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_postType == 'Sell' && _base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an item image for sales.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final String email = user?.email ?? '';
      
      // Compute the premium formatted string right here on the fly!
      final String calculatedName = email.isNotEmpty 
          ? _extractNameFromEmail(email) 
          : 'BRACU Student';

      final Map<String, dynamic> postData = {
        'postType': _postType,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _postType == 'Resource' ? 'Resources' : _selectedCategory,
        'sellerId': user?.uid,
        'sellerEmail': email,
        // SAVING: Now securely pushed as the official calculated student name string
        'sellerName': calculatedName,
        'isSold': false, 
        'isReported': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_postType == 'Sell') {
        postData['price'] = double.parse(_priceController.text.trim());
        postData['whatsapp'] = _whatsappController.text.trim();
        postData['imageBase64'] = _base64Image;
      } else {
        postData['courseCode'] = _courseCodeController.text.trim().toUpperCase();
        postData['courseName'] = _courseNameController.text.trim();
        postData['url'] = _urlController.text.trim();
      }

      await FirebaseFirestore.instance.collection('products').add(postData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_postType listing posted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish post: $e')),
      );
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
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _whatsappController.dispose();
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Listing')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('📦 Sell Item')),
                            selected: _postType == 'Sell',
                            onSelected: (val) => setState(() => _postType = 'Sell'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('📝 Academic Resource')),
                            selected: _postType == 'Resource',
                            onSelected: (val) => setState(() => _postType = 'Resource'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_postType == 'Sell') ...[
                      GestureDetector(
                        onTap: _pickProductImage,
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: _base64Image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    base64Decode(_base64Image!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Add item photo (Auto-compressed)', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_postType == 'Resource') ...[
                      TextFormField(
                        controller: _courseCodeController,
                        decoration: const InputDecoration(labelText: 'Course Code (e.g., CSE110, MAT110)', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _courseNameController,
                        decoration: const InputDecoration(labelText: 'Course Name', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: _postType == 'Sell' ? 'Listing Title' : 'Resource Title (e.g., Midterm Notes)', 
                        border: const OutlineInputBorder()
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 12),

                    if (_postType == 'Sell') ...[
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        items: _categories.where((cat) => cat != 'Resources').map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val!),
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description Details', border: OutlineInputBorder()),
                      maxLines: 3,
                      validator: (val) => val == null || val.isEmpty ? 'Enter description details' : null,
                    ),
                    const SizedBox(height: 12),

                    if (_postType == 'Sell') ...[
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price (BDT)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.isEmpty ? 'Enter pricing' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _whatsappController,
                        decoration: const InputDecoration(
                          labelText: 'WhatsApp Contact Number', 
                          hintText: '+8801XXXXXXXXX',
                          border: OutlineInputBorder()
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? 'WhatsApp layout required' : null,
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _urlController,
                        decoration: const InputDecoration(labelText: 'Resource URL Link (Drive / Dropbox)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.url,
                        validator: (val) => val == null || val.isEmpty ? 'Enter reference link URL' : null,
                      ),
                    ],

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitPost,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text('Publish $_postType Post', style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}