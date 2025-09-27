import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkManager {
  static const String _favoritesKey = "favorites";

  /// Add an ayah to favorites
  static Future<void> addFavorite(Map<String, dynamic> ayahData) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];

    // Include English translation in the stored map
    final updatedAyah = {
      'surah_number': ayahData['surah_number'],
      'ayah_number': ayahData['ayah_number'],
      'text_ar': ayahData['text_ar'],
      'text_mn': ayahData['text_mn'],             // Maranao
      'translation_tl': ayahData['translation_tl'], // Tagalog
      'translation_bis': ayahData['translation_bis'], // Bisayan
      'translation_en': ayahData['translation_en'],   // English
    };

    favorites.add(json.encode(updatedAyah));
    await prefs.setStringList(_favoritesKey, favorites);
  }

  /// Get all favorites
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.map((f) => json.decode(f) as Map<String, dynamic>).toList();
  }

  /// Remove a favorite by surah + ayah number
  static Future<void> removeFavorite(int surahNumber, int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    favorites.removeWhere((f) {
      final decoded = json.decode(f);
      return decoded['surah_number'] == surahNumber &&
          decoded['ayah_number'] == ayahNumber;
    });
    await prefs.setStringList(_favoritesKey, favorites);
  }

  /// Clear all favorites
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }
}
