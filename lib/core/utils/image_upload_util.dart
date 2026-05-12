import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadUtil {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image and returns it as an XFile. 
  /// XFile is cross-platform (Web/Mobile) and does not depend on dart:io.
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      return image;
    } catch (e) {
      debugPrint("Error picking image: $e");
      return null;
    }
  }

  /// Picks an image and returns it as a base64 encoded string.
  /// This is used to stay within Firebase Firestore free tier limits.
  static Future<String?> pickImageAsBase64({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await pickImage(source: source);
      
      if (image == null) return null;

      final Uint8List imageBytes = await image.readAsBytes();
      final String base64String = base64Encode(imageBytes);
      return base64String;
    } catch (e) {
      debugPrint("Error picking image as base64: $e");
      return null;
    }
  }

  /// Converts a base64 encoded string to a Uint8List so it can be displayed using Image.memory()
  static Uint8List? base64ToImage(String base64String) {
    try {
      if (base64String.contains('base64,')) {
        base64String = base64String.split('base64,').last;
      }
      return base64Decode(base64String);
    } catch (e) {
      debugPrint("Error decoding base64 string: $e");
      return null;
    }
  }
}
