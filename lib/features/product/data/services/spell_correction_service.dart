import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

class CorrectedWord {
  final String original;
  final String corrected;
  final double confidence;
  final List<String> alternatives;

  const CorrectedWord({
    required this.original,
    required this.corrected,
    required this.confidence,
    this.alternatives = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'original': original,
      'corrected': corrected,
      'confidence': confidence,
      'alternatives': alternatives,
    };
  }

  @override
  String toString() => 'CorrectedWord(orig: $original, corr: $corrected, conf: $confidence, alts: $alternatives)';
}

class SpellCorrectionService {
  static final Set<String> _dictionary = {};
  static bool _isLoaded = false;

  /// Loads all dictionary files from assets/dictionaries/.
  static Future<void> init() async {
    if (_isLoaded) return;
    
    final files = [
      'brands.txt',
      'electronics.txt',
      'grocery.txt',
      'pharmacy.txt',
      'hardware.txt',
      'general.txt',
    ];

    for (final file in files) {
      try {
        final content = await rootBundle.loadString('assets/dictionaries/$file');
        final lines = content.split('\n');
        for (var line in lines) {
          final word = line.trim();
          if (word.isNotEmpty) {
            _dictionary.add(word); // Store original casing (for brands)
          }
        }
      } catch (e) {
        debugPrint('Failed to load dictionary file: $file - $e');
      }
    }
    
    _isLoaded = true;
    debugPrint('SpellCorrectionService initialized with ${_dictionary.length} words.');
  }

  /// Calculates Levenshtein distance between two strings.
  static int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }

  /// Corrects a single word and returns a CorrectedWord object with confidence and alternatives.
  static CorrectedWord _correctToken(String original) {
    final lowerOriginal = original.toLowerCase();

    // Skip short words or numeric patterns or model numbers
    if (original.length < 3 || 
        RegExp(r'^\d+$').hasMatch(original) || 
        RegExp(r'^[A-Z0-9][-A-Z0-9/]*[0-9]$', caseSensitive: false).hasMatch(original)) {
      return CorrectedWord(original: original, corrected: original, confidence: 1.0);
    }

    // Exact match (case insensitive)
    String? exactMatch;
    for (final dictWord in _dictionary) {
      if (dictWord.toLowerCase() == lowerOriginal) {
        exactMatch = dictWord;
        break;
      }
    }

    if (exactMatch != null) {
      // Return the dictionary casing if it's a known word, else keep original if it was uppercase etc.
      // But for simplicity, we prefer the dictionary casing (e.g., boAt, iPhone)
      return CorrectedWord(original: original, corrected: exactMatch, confidence: 1.0);
    }

    // Fuzzy matching
    List<Map<String, dynamic>> matches = [];
    for (final dictWord in _dictionary) {
      final lowerDictWord = dictWord.toLowerCase();
      // Optimization: Only check words with similar length (±2 chars)
      if ((lowerDictWord.length - lowerOriginal.length).abs() > 2) continue;

      int distance = _levenshtein(lowerOriginal, lowerDictWord);
      
      // Threshold: max 2 edits, and must be strictly less than 40% of word length
      if (distance <= 2 && distance < (original.length * 0.4)) {
        matches.add({
          'word': dictWord,
          'distance': distance,
          'confidence': 1.0 - (distance / original.length)
        });
      }
    }

    if (matches.isEmpty) {
      return CorrectedWord(original: original, corrected: original, confidence: 1.0);
    }

    matches.sort((a, b) => (a['distance'] as int).compareTo(b['distance'] as int));

    final bestMatch = matches.first;
    final topAlternatives = matches.take(3).map((m) => m['word'] as String).toList();

    return CorrectedWord(
      original: original,
      corrected: bestMatch['word'] as String,
      confidence: bestMatch['confidence'] as double,
      alternatives: topAlternatives,
    );
  }

  /// Processes a full text string and returns a list of CorrectedWords
  static List<CorrectedWord> correctWords(String input) {
    if (!_isLoaded) {
      debugPrint('Warning: SpellCorrectionService not initialized. Returning raw text.');
      // Fallback
      return input.split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => CorrectedWord(original: w, corrected: w, confidence: 1.0))
        .toList();
    }

    final tokens = input.split(RegExp(r'\s+'));
    final results = <CorrectedWord>[];

    for (final token in tokens) {
      if (token.isEmpty) continue;
      results.add(_correctToken(token));
    }

    return results;
  }

  /// Convenience method to get just the corrected string
  static String correctText(String input) {
    final words = correctWords(input);
    return words.map((w) => w.corrected).join(' ');
  }
}
