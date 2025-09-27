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

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await BookmarkManager.getFavorites();
    setState(() => favorites = favs);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "Favorites",
          style: GoogleFonts.merriweather(),
        ),
      ),
      body: favorites.isEmpty
          ? Center(
        child: Text(
          "No favorites yet",
          style: GoogleFonts.merriweather(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final ayah = favorites[index];
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
              subtitle: ayah['text_mn'] != null &&
                  ayah['text_mn'].toString().isNotEmpty
                  ? Text(
                ayah['text_mn'],
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
