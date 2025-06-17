import 'dart:typed_data';
import 'package:image/image.dart' as img;

enum FilterType {
  none,
  vintage,
  blackAndWhite,
  sepia,
  cool,
  warm,
  dramatic,
  bright,
  contrast,
  saturated,
}

class PhotoFilter {
  final FilterType type;
  final String name;
  final String description;

  const PhotoFilter({
    required this.type,
    required this.name,
    required this.description,
  });

  static const List<PhotoFilter> filters = [
    PhotoFilter(
      type: FilterType.none,
      name: 'Original',
      description: 'No filter applied',
    ),
    PhotoFilter(
      type: FilterType.vintage,
      name: 'Vintage',
      description: 'Warm, nostalgic look',
    ),
    PhotoFilter(
      type: FilterType.blackAndWhite,
      name: 'B&W',
      description: 'Classic monochrome',
    ),
    PhotoFilter(
      type: FilterType.sepia,
      name: 'Sepia',
      description: 'Antique brown tone',
    ),
    PhotoFilter(
      type: FilterType.cool,
      name: 'Cool',
      description: 'Blue undertones',
    ),
    PhotoFilter(
      type: FilterType.warm,
      name: 'Warm',
      description: 'Orange undertones',
    ),
    PhotoFilter(
      type: FilterType.dramatic,
      name: 'Dramatic',
      description: 'High contrast',
    ),
    PhotoFilter(
      type: FilterType.bright,
      name: 'Bright',
      description: 'Enhanced brightness',
    ),
    PhotoFilter(
      type: FilterType.contrast,
      name: 'Contrast',
      description: 'Enhanced contrast',
    ),
    PhotoFilter(
      type: FilterType.saturated,
      name: 'Vibrant',
      description: 'Enhanced colors',
    ),
  ];

  static Uint8List applyFilter(Uint8List imageBytes, FilterType filterType) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    img.Image processedImage;

    switch (filterType) {
      case FilterType.none:
        processedImage = image;
        break;
      case FilterType.vintage:
        processedImage = _applyVintageFilter(image);
        break;
      case FilterType.blackAndWhite:
        processedImage = img.grayscale(image);
        break;
      case FilterType.sepia:
        processedImage = img.sepia(image);
        break;
      case FilterType.cool:
        processedImage = _applyCoolFilter(image);
        break;
      case FilterType.warm:
        processedImage = _applyWarmFilter(image);
        break;
      case FilterType.dramatic:
        processedImage = img.contrast(image, contrast: 150);
        break;
      case FilterType.bright:
        processedImage = img.adjustColor(image, brightness: 1.3);
        break;
      case FilterType.contrast:
        processedImage = img.contrast(image, contrast: 120);
        break;
      case FilterType.saturated:
        processedImage = img.adjustColor(image, saturation: 1.3);
        break;
    }

    return Uint8List.fromList(img.encodeJpg(processedImage, quality: 90));
  }

  static img.Image _applyVintageFilter(img.Image image) {
    // Apply vintage effect: sepia + slight vignette + reduced contrast
    var processed = img.sepia(image);
    processed = img.contrast(processed, contrast: 90);
    processed = img.adjustColor(processed, brightness: 1.1);
    return processed;
  }

  static img.Image _applyCoolFilter(img.Image image) {
    // Apply cool filter: increase blue, decrease red
    return img.adjustColor(image,
        saturation: 1.1
    );
  }

  static img.Image _applyWarmFilter(img.Image image) {
    // Apply warm filter: increase red/yellow, decrease blue
    return img.adjustColor(image,
        saturation: 1.1
    );
  }
}