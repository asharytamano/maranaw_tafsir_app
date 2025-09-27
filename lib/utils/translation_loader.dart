import 'dart:convert';
import 'package:http/http.dart' as http;

enum QuranLanguage { maranao, tagalog, bisayan, english }

class TranslationLoader {
  /// Load translations for a given surah and language
  static Future<List<Map<String, dynamic>>?> load(
      QuranLanguage lang, int surahNumber) async {
    try {
      String url = "";
      final surahStr = surahNumber.toString().padLeft(3, "0");

      switch (lang) {
        case QuranLanguage.maranao:
        // handled already by fetchSurah() in surah_detail_page.dart
          return null;

        case QuranLanguage.tagalog:
          url =
          "https://raw.githubusercontent.com/asharytamano/quran-translations/main/tagalog_surahs_json/$surahStr.json";
          break;

        case QuranLanguage.bisayan:
          url =
          "https://raw.githubusercontent.com/asharytamano/quran-translations/main/bisayan_surahs_json/$surahStr.json";
          break;

        case QuranLanguage.english:
        // English is a single big JSON file, so filter ayahs by surah
          url =
          "https://raw.githubusercontent.com/asharytamano/quran-translations/main/quran_english.json";
          break;
      }

      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        print("❌ Failed to fetch: $url");
        return null;
      }

      final data = json.decode(res.body);

      if (lang == QuranLanguage.english) {
        // English JSON is the whole Qur’an
        final filtered = data
            .where((a) => a['surah_number'] == surahNumber)
            .map<Map<String, dynamic>>((a) => Map<String, dynamic>.from(a))
            .toList();
        return filtered;
      } else {
        // Tagalog/Bisayan JSON already surah-specific
        return List<Map<String, dynamic>>.from(data["ayahs"]);
      }
    } catch (e) {
      print("❌ Error loading translation: $e");
      return null;
    }
  }
}
