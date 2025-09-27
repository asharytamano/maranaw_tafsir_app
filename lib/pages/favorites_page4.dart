import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/bookmark_manager.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favorites = [];
  List<Map<String, dynamic>> filteredFavorites = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await BookmarkManager.getFavorites();
    setState(() {
      favorites = favs;
      filteredFavorites = favs;
    });
  }

  Future<void> _removeFavorite(Map<String, dynamic> ayah) async {
    await BookmarkManager.removeFavorite(ayah);
    _loadFavorites();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Removed from Favorites",
            style: GoogleFonts.merriweather(),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _filterFavorites(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredFavorites = favorites.where((ayah) {
        final ar = (ayah['text_ar'] ?? "").toString().toLowerCase();
        final mn = (ayah['text_mn'] ?? "").toString().toLowerCase();
        final tl = (ayah['translation_tl'] ?? "").toString().toLowerCase();
        final bis = (ayah['translation_bis'] ?? "").toString().toLowerCase();
        final ref =
        "[${ayah['surah_number']}:${ayah['ayah_number']}]".toLowerCase();

        return ar.contains(searchQuery) ||
            mn.contains(searchQuery) ||
            tl.contains(searchQuery) ||
            bis.contains(searchQuery) ||
            ref.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "Favorites",
          style: GoogleFonts.merriweather(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              onChanged: _filterFavorites,
              style: GoogleFonts.merriweather(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search favorites...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: filteredFavorites.isEmpty
          ? Center(
        child: Text(
          searchQuery.isEmpty
              ? "No favorites yet"
              : "No results for \"$searchQuery\"",
          style: GoogleFonts.merriweather(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: filteredFavorites.length,
        itemBuilder: (context, index) {
          final ayah = filteredFavorites[index];

          // 🔹 Pick best available translation + label
          String? translation;
          String? label;
          if (ayah['text_mn'] != null &&
              ayah['text_mn'].toString().isNotEmpty) {
            translation = ayah['text_mn'];
            label = "[Maranao]";
          } else if (ayah['translation_tl'] != null &&
              ayah['translation_tl'].toString().isNotEmpty) {
            translation = ayah['translation_tl'];
            label = "[Tagalog]";
          } else if (ayah['translation_bis'] != null &&
              ayah['translation_bis'].toString().isNotEmpty) {
            translation = ayah['translation_bis'];
            label = "[Bisayan]";
          }

          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: Colors.black87,
            child: ListTile(
              title: Text(
                "[${ayah['surah_number']}:${ayah['ayah_number']}]  ${ayah['text_ar']}",
                textAlign: TextAlign.right,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  color: Colors.white,
                  height: 1.8,
                ),
              ),
              subtitle: translation != null
                  ? Text(
                "$label $translation",
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                  color: Colors.orangeAccent,
                ),
              )
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFavorite(ayah),
              ),
            ),
          );
        },
      ),
    );
  }
}
