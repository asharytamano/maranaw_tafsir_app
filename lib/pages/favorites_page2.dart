import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

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
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final favs = await BookmarkManager.getFavorites();
    setState(() {
      favorites = favs;
    });
  }

  Future<void> removeFavorite(Map<String, dynamic> ayah) async {
    await BookmarkManager.removeFavorite(ayah);
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Favorites",
            style: GoogleFonts.merriweather(),
          ),
          backgroundColor: Colors.orange,
        ),
        body: favorites.isEmpty
            ? Center(
          child: Text(
            "No favorites yet.",
            style: GoogleFonts.merriweather(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final ayah = favorites[index];
            return Card(
              color: Colors.black87,
              margin:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Arabic text
                    Text(
                      ayah['text_ar'] ?? "",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiri(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Maranaw translation
                    Text(
                      ayah['text_mn'] ?? "",
                      style: GoogleFonts.merriweather(
                        fontSize: 16,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          tooltip: "Remove",
                          onPressed: () => removeFavorite(ayah),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share,
                              color: Colors.white),
                          tooltip: "Share",
                          onPressed: () {
                            Share.share(
                                "${ayah['text_ar']}\n\n${ayah['text_mn']}");
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
