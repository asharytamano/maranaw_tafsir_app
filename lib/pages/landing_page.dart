import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'surah_list_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg.jpg"),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          child: Column(
            children: [
              // 🔹 Push content down para hindi dumikit sa logo
              const SizedBox(height: 200),

              // Bismillah
              Text(
                "بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ",
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 26,
                  color: Colors.amber[600],
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              // Welcome header
              Text(
                "Welcome to the Maranaw Tafsir App",
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Deepen your connection to the Qur'an with this app, featuring Abu Ahmad Tamano's Maranaw translation and tafsir. Listen to your favorite reciters, save verses to Favorites, and easily share them for study or on social media.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.merriweather(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.7,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                child: Text(
                  "For full Tafsir, please visit https://maranaw.com",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.merriweather(
                    fontSize: 14,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              const Spacer(),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SurahListPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Go to Surah List",
                          style: GoogleFonts.merriweather(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final url = Uri.parse(
                              "https://www.dropbox.com/scl/fi/iflp9ho8e7dmu7jyfk4d9/Maranao-Tafsir_-July2025.pdf?rlkey=uxcr5orzvh1jocvp83axud1ux&st=nvanhea9&dl=0");
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Download PDF",
                          style: GoogleFonts.merriweather(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Tafsir redirect

              const SizedBox(height: 20),

              // Footer
              Container(
                width: double.infinity,
                color: Colors.amber[700],
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Text(
                  "Translation and Tafsir by AbuAhmad Tamano.\nApp developed by Ashary Tamano.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.merriweather(
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
