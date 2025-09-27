import 'dart:convert';
import 'package:http/http.dart' as http;

class BisayanTranslation {
  /// Fetch Bisayan translation for a given surah
  static Future<Map<String, dynamic>?> fetch(int surahNumber) async {
    final surahStr = surahNumber.toString().padLeft(3, '0');

    // 🔹 URL of your GitHub raw JSON
    final url =
        "https://raw.githubusercontent.com/asharytamano/quran-translations/main/bisayan_surahs_json/$surahStr.json";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print("❌ Failed to fetch Bisayan translation: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching Bisayan translation: $e");
      return null;
    }
  }
}
