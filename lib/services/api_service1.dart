import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://maranaw.com/api";

  /// Get surah list
  static Future<List<dynamic>> fetchSurahList() async {
    final res = await http.get(Uri.parse("$baseUrl/surah_list_json.php"));
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return decoded['surahs'] ?? [];
    } else {
      throw Exception("Failed to load surah list");
    }
  }

  /// Get surah ayahs
  static Future<Map<String, dynamic>> fetchSurahMeta(int surahNumber,
      {bool includeTafsir = false}) async {
    final tafsirFlag = includeTafsir ? "&include=tafsir" : "";
    final res = await http.get(
      Uri.parse("$baseUrl/surah_json.php?surah=$surahNumber$tafsirFlag"),
    );
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return decoded['data'] ?? {};
    } else {
      throw Exception("Failed to load surah $surahNumber");
    }
  }

  /// Get reciters list
  static Future<List<dynamic>> fetchReciters() async {
    final res = await http.get(Uri.parse("$baseUrl/reciters_json.php"));
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return decoded['reciters'] ?? [];
    } else {
      throw Exception("Failed to load reciters");
    }
  }
}
