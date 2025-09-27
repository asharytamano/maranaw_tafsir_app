import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'surah_detail_page.dart';
import 'favorites_page.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  late Future<List<dynamic>> surahs;

  @override
  void initState() {
    super.initState();
    surahs = ApiService.fetchSurahList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Surahs",
          style: GoogleFonts.merriweather(color: Colors.black),
        ),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            tooltip: "View Favorites",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: surahs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No surahs found"));
            }

            final surahList = snapshot.data!;

            return ListView.builder(
              itemCount: surahList.length,
              itemBuilder: (context, index) {
                final surah = surahList[index];

                return Card(
                  color: Colors.black.withOpacity(0.65),
                  margin: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      surah['surah_name_en'] ?? "",
                      style: GoogleFonts.merriweather(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    subtitle: Text(
                      surah['surah_name_ar'] ?? "",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiri(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Text(
                      "Ayahs: ${surah['ayah_count']}",
                      style: GoogleFonts.merriweather(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SurahDetailPage(
                            surahNumber: surah['surah_number'],
                            surahNameEnglish: surah['surah_name_en'],
                            surahNameArabic: surah['surah_name_ar'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
