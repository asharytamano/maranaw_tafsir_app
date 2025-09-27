import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkManager {
  static const String _favoritesKey = "favorites";

  // 🔹 Get all favorites
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    return favoritesJson
        .map((item) => Map<String, dynamic>.from(json.decode(item)))
        .toList();
  }

  // 🔹 Add favorite
  static Future<void> addFavorite(Map<String, dynamic> ayah) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    // Check kung existing na para hindi madoble
    final exists = favorites.any((f) =>
    f['surah_number'] == ayah['surah_number'] &&
        f['ayah_number'] == ayah['ayah_number']);

    if (!exists) {
      favorites.add(ayah);
      final favoritesJson =
      favorites.map((item) => json.encode(item)).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
    }
  }

  // 🔹 Remove favorite
  static Future<void> removeFavorite(Map<String, dynamic> ayah) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    favorites.removeWhere((f) =>
    f['surah_number'] == ayah['surah_number'] &&
        f['ayah_number'] == ayah['ayah_number']);

    final favoritesJson =
    favorites.map((item) => json.encode(item)).toList();
    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  // 🔹 Clear all favorites (optional)
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }
}
