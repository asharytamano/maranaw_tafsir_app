import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkManager {
  static const String key = "favorites";

  /// Kunin lahat ng favorites
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];
    return data.map((e) => json.decode(e) as Map<String, dynamic>).toList();
  }

  /// Magdagdag ng favorite
  static Future<void> addFavorite(Map<String, dynamic> ayahData) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    final enriched = {
      "surah_number": ayahData["surah_number"],
      "ayah_number": ayahData["ayah_number"],
      "text_ar": ayahData["text_ar"],
      "text_mn": ayahData["text_mn"],
    };

    // Prevent duplicates
    final exists = favorites.any((f) =>
    f["surah_number"] == enriched["surah_number"] &&
        f["ayah_number"] == enriched["ayah_number"]);
    if (!exists) {
      favorites.add(enriched);
    }

    final data = favorites.map((e) => json.encode(e)).toList();
    await prefs.setStringList(key, data);
  }

  /// Mag-delete ng favorite (pwede by Map o by ints)
  static Future<void> removeFavorite(dynamic surahOrMap,
      [int? ayahNumber]) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    int surahNumber;

    if (surahOrMap is Map<String, dynamic>) {
      surahNumber = surahOrMap["surah_number"];
      ayahNumber = surahOrMap["ayah_number"];
    } else if (surahOrMap is int && ayahNumber != null) {
      surahNumber = surahOrMap;
    } else {
      throw ArgumentError(
          "removeFavorite requires either a Map or (surahNumber, ayahNumber).");
    }

    favorites.removeWhere((f) =>
    f["surah_number"] == surahNumber && f["ayah_number"] == ayahNumber);

    final data = favorites.map((e) => json.encode(e)).toList();
    await prefs.setStringList(key, data);
  }

  /// I-clear lahat ng favorites
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
