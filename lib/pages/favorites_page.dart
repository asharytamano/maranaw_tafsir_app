import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/bookmark_manager.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favorites = [];

  // 🔹 language toggle (dropdown)
  String selectedLanguage = "maranao";

  // 🔹 track selected/highlighted ayah index
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await BookmarkManager.getFavorites();

    setState(() {
      favorites = favs;

      // 🔹 Auto-highlight the last added favorite
      if (favorites.isNotEmpty) {
        selectedIndex = favorites.length - 1; // last item
      } else {
        selectedIndex = null;
      }
    });
  }

  Future<void> _removeFavorite(Map<String, dynamic> ayah) async {
    await BookmarkManager.removeFavorite(
      ayah['surah_number'],
      ayah['ayah_number'],
    );
    await _loadFavorites();
  }

  String _getTranslation(Map<String, dynamic> ayah) {
    switch (selectedLanguage) {
      case "tagalog":
        return ayah['translation_tl'] ?? "—";
      case "bisayan":
        return ayah['translation_bis'] ?? "—";
      case "english":
        return ayah['translation_en'] ?? "—";
      case "maranao":
      default:
        return ayah['text_mn'] ?? "—";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: Colors.orange,
        actions: [
          // 🔹 Language Dropdown in AppBar
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String>(
              value: selectedLanguage,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: "maranao",
                  child: Text("Maranao – Abu Ahmad Tamano"),
                ),
                DropdownMenuItem(
                  value: "tagalog",
                  child: Text("Tagalog – Rowwad Translation Center"),
                ),
                DropdownMenuItem(
                  value: "bisayan",
                  child: Text("Bisayan – Rowwad Translation Center"),
                ),
                DropdownMenuItem(
                  value: "english",
                  child: Text("English – Rowwad Translation Center"),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedLanguage = val);
                }
              },
            ),
          ),
        ],
      ),
      body: favorites.isEmpty
          ? const Center(child: Text("No favorites yet."))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final ayah = favorites[index];
          final translation = _getTranslation(ayah);
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() => selectedIndex = index);
            },
            child: Card(
              margin:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: Colors.black87,
              elevation: isSelected ? 10 : 2,
              shadowColor:
              isSelected ? Colors.orangeAccent : Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: isSelected
                    ? const BorderSide(
                    color: Colors.orangeAccent, width: 2)
                    : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Surah:Ayah badge
                    Text(
                      "${ayah['surah_number']}:${ayah['ayah_number']}",
                      style: GoogleFonts.merriweather(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Arabic text
                    Text(
                      ayah['text_ar'] ?? "",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Translation
                    Text(
                      translation,
                      style: GoogleFonts.merriweather(
                        fontSize: 14,
                        color: Colors.orangeAccent,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Action Row (icons only)
                    Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.orange.shade700
                            : Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 6),
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 📋 Copy
                          IconButton(
                            iconSize: 20,
                            tooltip: "Copy",
                            icon: const Icon(Icons.copy,
                                color: Colors.blue),
                            onPressed: () {
                              final copyText =
                                  "${ayah['text_ar']}\n\n$translation\n\n(${ayah['surah_number']}:${ayah['ayah_number']})";
                              Clipboard.setData(
                                  ClipboardData(text: copyText));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text("Copied to clipboard"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),

                          // 📤 Share
                          IconButton(
                            iconSize: 20,
                            tooltip: "Share",
                            icon: const Icon(Icons.share,
                                color: Colors.green),
                            onPressed: () {
                              final shareText =
                                  "${ayah['text_ar']}\n\n$translation\n\n(${ayah['surah_number']}:${ayah['ayah_number']})";
                              Share.share(shareText);
                            },
                          ),

                          // 🗑 Remove
                          IconButton(
                            iconSize: 20,
                            tooltip: "Remove",
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () => _removeFavorite(ayah),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
