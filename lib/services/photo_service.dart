import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

class PhotoService {
  static const String _editHistoryKey = 'edit_history';
  static const String _savedPhotosKey = 'saved_photos';

  // Image adjustment methods
  static Uint8List adjustBrightness(Uint8List imageBytes, double brightness) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final adjusted = img.adjustColor(image, brightness: 1.0 + (brightness / 100.0));
    return Uint8List.fromList(img.encodeJpg(adjusted, quality: 90));
  }

  static Uint8List adjustContrast(Uint8List imageBytes, double contrast) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final adjusted = img.contrast(image, contrast: contrast.toInt());
    return Uint8List.fromList(img.encodeJpg(adjusted, quality: 90));
  }

  static Uint8List adjustSaturation(Uint8List imageBytes, double saturation) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final adjusted = img.adjustColor(image, saturation: saturation);
    return Uint8List.fromList(img.encodeJpg(adjusted, quality: 90));
  }

  static Uint8List adjustHue(Uint8List imageBytes, double hue) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final adjusted = img.adjustColor(image, hue: hue);
    return Uint8List.fromList(img.encodeJpg(adjusted, quality: 90));
  }

  // Rotation and flip methods
  static Uint8List rotateImage(Uint8List imageBytes, int degrees) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    img.Image rotated;
    switch (degrees % 360) {
      case 90:
        rotated = img.copyRotate(image, angle: 90);
        break;
      case 180:
        rotated = img.copyRotate(image, angle: 180);
        break;
      case 270:
        rotated = img.copyRotate(image, angle: 270);
        break;
      default:
        rotated = image;
    }

    return Uint8List.fromList(img.encodeJpg(rotated, quality: 90));
  }

  static Uint8List flipHorizontal(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final flipped = img.flipHorizontal(image);
    return Uint8List.fromList(img.encodeJpg(flipped, quality: 90));
  }

  static Uint8List flipVertical(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final flipped = img.flipVertical(image);
    return Uint8List.fromList(img.encodeJpg(flipped, quality: 90));
  }

  // Crop image
  static Uint8List cropImage(Uint8List imageBytes, int x, int y, int width, int height) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final cropped = img.copyCrop(image, x: x, y: y, width: width, height: height);
    return Uint8List.fromList(img.encodeJpg(cropped, quality: 90));
  }

  // Resize image
  static Uint8List resizeImage(Uint8List imageBytes, int width, int height) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final resized = img.copyResize(image, width: width, height: height);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 90));
  }

  // Save image to device
  static Future<String?> saveImageToGallery(Uint8List imageBytes, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('\${directory.path}/\$filename.jpg');
      await file.writeAsBytes(imageBytes);

      // Save to shared preferences for app gallery
      await _saveToAppGallery(file.path);

      return file.path;
    } catch (e) {
      print('Error saving image: \$e');
      return null;
    }
  }

  static Future<void> _saveToAppGallery(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedPhotos = prefs.getStringList(_savedPhotosKey) ?? [];
      savedPhotos.add(filePath);
      await prefs.setStringList(_savedPhotosKey, savedPhotos);
    } catch (e) {
      print('Error saving to app gallery: \$e');
    }
  }

  // Get saved photos
  static Future<List<String>> getSavedPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_savedPhotosKey) ?? [];
    } catch (e) {
      print('Error getting saved photos: \$e');
      return [];
    }
  }

  // Save edit history
  static Future<void> saveEditHistory(Map<String, dynamic> editData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_editHistoryKey) ?? [];

      // Keep only last 10 edits
      if (history.length >= 10) {
        history.removeAt(0);
      }

      history.add(editData.toString());
      await prefs.setStringList(_editHistoryKey, history);
    } catch (e) {
      print('Error saving edit history: \$e');
    }
  }

  // Get image dimensions
  static Map<String, int>? getImageDimensions(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    return {
      'width': image.width,
      'height': image.height,
    };
  }

  // Compress image
  static Uint8List compressImage(Uint8List imageBytes, {int quality = 85}) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }
}