import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;

class ImageHasher {
  /// Normalizes an image, computes a standard SHA256 hash and a perceptual difference hash (dHash).
  /// 
  /// The [dHash] is robust against minor resizing, compression, and brightness changes.
  static Future<Map<String, String>?> processImage(Uint8List imageBytes) async {
    try {
      // 1. Decode image
      img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) return null;

      // --- Perceptual Hash (dHash) ---
      // Resize to 9x8 for dHash
      img.Image dHashImg = img.copyResize(decodedImage, width: 9, height: 8);
      dHashImg = img.grayscale(dHashImg);
      
      int hashBits = 0;
      int bitIndex = 0;
      String pHashHex = '';
      
      for (int y = 0; y < 8; y++) {
        for (int x = 0; x < 8; x++) {
          final leftPixel = dHashImg.getPixel(x, y);
          final rightPixel = dHashImg.getPixel(x + 1, y);
          
          // Compare luminance
          if (leftPixel.luminance > rightPixel.luminance) {
            hashBits |= (1 << (63 - bitIndex));
          }
          bitIndex++;
          
          if (bitIndex % 4 == 0) {
            int nibble = (hashBits >> (64 - 4)) & 0x0F;
            pHashHex += nibble.toRadixString(16);
            hashBits = hashBits << 4;
          }
        }
      }

      // --- SHA256 (Normalized) ---
      // Crop to center square
      int minDim = decodedImage.width < decodedImage.height ? decodedImage.width : decodedImage.height;
      img.Image cropped = img.copyCrop(
        decodedImage,
        x: (decodedImage.width - minDim) ~/ 2,
        y: (decodedImage.height - minDim) ~/ 2,
        width: minDim,
        height: minDim,
      );

      // Resize to 512px
      img.Image resized = img.copyResize(cropped, width: 512, height: 512);

      // Grayscale
      img.Image grayscaled = img.grayscale(resized);

      // Compress to JPEG (strips EXIF by default when re-encoding)
      Uint8List normalizedBytes = img.encodeJpg(grayscaled, quality: 85);

      // SHA256
      final sha256Hash = sha256.convert(normalizedBytes).toString();

      return {
        'sha256': sha256Hash,
        'phash': pHashHex, // using dHash implementation
      };
    } catch (e) {
      return null;
    }
  }
}
