import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from gallery, compresses it heavily, and returns a Base64 string
  static Future<String?> pickAndCompressImage() async {
    try {
      // 1. Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Caps resolution width to save server storage
        maxHeight: 800, // Caps resolution height
      );

      if (image == null) return null;

      // 2. Read file bytes
      final Uint8List imageBytes = await image.readAsBytes();

      // 3. Compress bytes to absolute minimum size (Quality 40% for high compression)
      final List<int> compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: 600,
        minHeight: 600,
        quality: 40, 
      );

      // 4. Convert the tiny compressed byte list into a Firestore-friendly string
      return base64Encode(compressedBytes);
    } catch (e) {
      print("Image processing failed: $e");
      return null;
    }
  }
}