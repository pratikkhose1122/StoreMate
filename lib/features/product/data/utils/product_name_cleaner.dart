class ProductNameCleaner {
  static final Map<String, String> _brandCasing = {
    'boat': 'boAt',
    'oneplus': 'OnePlus',
    'iphone': 'iPhone',
    'ipad': 'iPad',
    'realme': 'realme',
    'mi': 'Mi',
    'jbl': 'JBL',
    'hp': 'HP',
    'lg': 'LG',
    'oppo': 'OPPO',
    'vivo': 'vivo',
    'samsung': 'Samsung',
    'apple': 'Apple',
    'sony': 'Sony',
    'philips': 'Philips',
    'xiaomi': 'Xiaomi',
    'redmi': 'Redmi',
    'nokia': 'Nokia',
    'motorola': 'Motorola',
    'lenovo': 'Lenovo',
    'dell': 'Dell',
    'asus': 'Asus',
    'acer': 'Acer',
    'canon': 'Canon',
    'nikon': 'Nikon',
    'panasonic': 'Panasonic',
    'godrej': 'Godrej',
    'amul': 'Amul',
    'britannia': 'Britannia',
    'parle': 'Parle',
    'nestle': 'Nestle',
    'cadbury': 'Cadbury',
    'colgate': 'Colgate',
    'dettol': 'Dettol',
    'savlon': 'Savlon',
    'himalaya': 'Himalaya',
    'patanjali': 'Patanjali',
    'dabur': 'Dabur',
    'mtr': 'MTR',
    'haldiram': 'Haldiram',
    'itc': 'ITC',
    'aashirvaad': 'Aashirvaad',
    'pepsico': 'Pepsico',
    'cocacola': 'CocaCola',
    'portronics': 'Portronics',
    'zebronics': 'Zebronics',
    'ambrane': 'Ambrane',
    'syska': 'Syska',
    'ubon': 'Ubon',
    'oraimo': 'Oraimo',
    'nothing': 'Nothing',
    'anker': 'Anker',
  };

  /// Cleans and formats a product name extracted from OCR.
  static String clean(String raw, {String? brand}) {
    if (raw.isEmpty) return raw;

    String text = raw;

    // 1. Collapse multiple whitespace/newlines
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 2. Strip leading/trailing junk
    text = text.replaceAll(RegExp(r'^[\W_]+|[\W_]+$'), '');

    // 3. Concatenated word splitting (Common Tech Patterns)
    text = text.replaceAll(RegExp(r'SUPERFASTCHARGER', caseSensitive: false), 'Super Fast Charger');
    text = text.replaceAll(RegExp(r'USBC', caseSensitive: false), 'USB-C');
    text = text.replaceAll(RegExp(r'TYPEC', caseSensitive: false), 'Type-C');

    // 4. Remove duplicate consecutive words (case insensitive)
    final words = text.split(' ');
    final deduplicated = <String>[];
    String lastLower = '';
    
    for (final word in words) {
      final lower = word.toLowerCase();
      if (lower != lastLower) {
        deduplicated.add(word);
        lastLower = lower;
      }
    }
    
    // 5. Title case with model number & brand preservation
    final finalWords = <String>[];
    for (final word in deduplicated) {
      final lower = word.toLowerCase();
      
      // Preserve brand casing if it exists in our map
      if (_brandCasing.containsKey(lower)) {
        finalWords.add(_brandCasing[lower]!);
        continue;
      }

      // Preserve model number tokens (contains letters, digits, and maybe hyphens/slashes)
      if (RegExp(r'[A-Z0-9\-\/]{2,}').hasMatch(word) && RegExp(r'\d').hasMatch(word)) {
        finalWords.add(word); // Keep original casing
        continue;
      }

      // Title case
      if (word.length > 1) {
        finalWords.add('${word[0].toUpperCase()}${word.substring(1).toLowerCase()}');
      } else {
        finalWords.add(word.toUpperCase());
      }
    }

    String result = finalWords.join(' ');

    // 6. Prepend brand if supplied and not already at start
    if (brand != null && brand.isNotEmpty) {
      final cleanBrand = clean(brand);
      if (!result.toLowerCase().startsWith(cleanBrand.toLowerCase())) {
        result = '$cleanBrand $result';
      }
    }

    return result.trim();
  }
}
