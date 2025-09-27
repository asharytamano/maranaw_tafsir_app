import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/bookmark_manager.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahNameEnglish;
  final String surahNameArabic;

  const SurahDetailPage({
    super.key,
    required this.surahNumber,
    required this.surahNameEnglish,
    required this.surahNameArabic,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  List<Map<String, dynamic>> ayahs = [];
  bool loading = true;

  String selectedReciter = "sudais";
  final AudioPlayer _audioPlayer = AudioPlayer();

  final ScrollController _scrollController = ScrollController();
  List<GlobalKey> _itemKeys = [];

  int? currentlyPlayingAyah;
  bool isPlaying = false;
  bool continuousPlay = true;
  int? expandedAyahIndex;

  // repeat mode
  bool repeatAyah = false;
  bool repeatSurah = false;

  @override
  void initState() {
    super.initState();
    fetchSurah();
    _loadReciterPref();

    _audioPlayer.onPlayerComplete.listen((_) {
      if (currentlyPlayingAyah != null) {
        if (repeatAyah) {
          _playAyah(ayahs[currentlyPlayingAyah!]['ayah_number'],
              index: currentlyPlayingAyah);
        } else if (repeatSurah) {
          final next = (currentlyPlayingAyah! + 1);
          if (next < ayahs.length) {
            _playAyah(ayahs[next]['ayah_number'], index: next);
          } else {
            _playAyah(ayahs.first['ayah_number'], index: 0);
          }
        } else if (continuousPlay) {
          final next = (currentlyPlayingAyah! + 1);
          if (next < ayahs.length) {
            _playAyah(ayahs[next]['ayah_number'], index: next);
          } else {
            setState(() => isPlaying = false);
          }
        } else {
          setState(() => isPlaying = false);
        }
      }
    });
  }

  // load last selected reciter
  Future<void> _loadReciterPref() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("selectedReciter");
    if (saved != null) {
      setState(() => selectedReciter = saved);
    }
  }

  // save selected reciter
  Future<void> _saveReciterPref(String reciterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedReciter", reciterId);
  }

  Future<void> fetchSurah() async {
    final res = await http.get(Uri.parse(
        "https://maranaw.com/api/surah_json.php?surah=${widget.surahNumber}"));
    final data = json.decode(res.body);

    setState(() {
      ayahs = List<Map<String, dynamic>>.from(data['data']['ayahs']);
      if (ayahs.isNotEmpty && ayahs.first['ayah_number'] == 0) {
        ayahs.removeAt(0);
      }
      _itemKeys = List.generate(ayahs.length, (_) => GlobalKey());
      loading = false;
    });
  }

  String _mapReciterBaseUrl(String reciterId) {
    switch (reciterId) {
      case "sudais":
        return "https://verses.quran.com/Sudais/mp3/";
      case "afasy":
        return "https://verses.quran.com/Alafasy/mp3/";
      case "ghamdi":
        return "https://everyayah.com/data/Ghamadi_40kbps/";
      case "rifai":
        return "https://everyayah.com/data/Hani_Rifai_192kbps/";
      case "abdulbasit":
        return "https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/";
      case "menshawi":
        return "https://everyayah.com/data/Menshawi_32kbps/";
      case "fares":
        return "https://everyayah.com/data/Fares_Abbad_64kbps/";
      case "matroud":
        return "https://everyayah.com/data/Abdullah_Matroud_128kbps/";
      default:
        return "https://verses.quran.com/Sudais/mp3/";
    }
  }

  Future<void> _playAyah(int ayahNumber, {int? index}) async {
    final surahStr = widget.surahNumber.toString().padLeft(3, '0');
    final ayahStr = ayahNumber.toString().padLeft(3, '0');
    final baseUrl = _mapReciterBaseUrl(selectedReciter);
    final url = "$baseUrl$surahStr$ayahStr.mp3";

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));

      setState(() {
        currentlyPlayingAyah = index;
        isPlaying = true;
      });

      if (index != null) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _centerOnIndex(index));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Audio not available.",
              style: GoogleFonts.merriweather(),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() => isPlaying = false);
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
      currentlyPlayingAyah = null;
    });
  }

  Future<void> _centerOnIndex(int index) async {
    if (index < 0 || index >= _itemKeys.length) return;
    final ctx = _itemKeys[index].currentContext;
    if (ctx == null) return;

    await Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "${widget.surahNameEnglish} (${widget.surahNameArabic})",
          style: GoogleFonts.merriweather(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 🔹 Reciter + Play/Stop row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedReciter,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: "sudais",
                        child: Row(
                          children: [
                            Icon(Icons.mic,
                                size: 18, color: Colors.orange),
                            SizedBox(width: 6),
                            Text("Abdurrahman As-Sudais"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "afasy",
                        child: Row(
                          children: [
                            Icon(Icons.mic,
                                size: 18, color: Colors.orange),
                            SizedBox(width: 6),
                            Text("Mishary Rashid Alafasy"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "ghamdi",
                        child: Row(
                          children: [
                            Icon(Icons.mic,
                                size: 18, color: Colors.orange),
                            SizedBox(width: 6),
                            Text("Saad Al-Ghamdi"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "rifai",
                        child: Row(
                          children: [
                            Icon(Icons.mic,
                                size: 18, color: Colors.orange),
                            SizedBox(width: 6),
                            Text("Hani Ar-Rifai"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "abdulbasit",
                        child: Row(
                          children: [
                            Icon(Icons.mic,
                                size: 18, color: Colors.orange),
                            SizedBox(width: 6),
                            Text("Abdulbasit Abdussamad"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "menshawi",
                        child: Row(
                          children: [
                            Icon(Icons.mic,
                                size: 18, color: Colors.orange),
                            SizedBox(width: 6),
                            Text("Menshawi"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "fares",
                        child: Row(
                          children: [
                            Icon(Icons.mic,
                                size: 18, color: Colors.orange),
                            SizedBox(width: 6),
                            Text("Fares Abbad"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "matroud",
                        child: Row(
                          children: [
                            Icon(Icons.mic,
                                size: 18, color: Colors.orange),
                            SizedBox(width: 6),
                            Text("Abdullah Matroud"),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedReciter = val);
                        _saveReciterPref(val); // save last reciter
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.black),
                  tooltip: "Play All",
                  onPressed: () {
                    if (ayahs.isNotEmpty) {
                      _playAyah(ayahs.first['ayah_number'], index: 0);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop, color: Colors.black),
                  tooltip: "Stop",
                  onPressed: _stopAudio,
                ),
              ],
            ),
          ),
          const Divider(height: 0),

          // 🔹 Bismillah (except Surah 9)
          if (widget.surahNumber != 9)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

          // 🔹 Ayah list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: ayahs.length,
              itemBuilder: (context, index) {
                final ayah = ayahs[index];
                final bool isExpanded = expandedAyahIndex == index;
                final bool isThisPlaying =
                    index == currentlyPlayingAyah && isPlaying;

                return Card(
                  key: _itemKeys[index],
                  color: Colors.black87,
                  elevation: isThisPlaying ? 10 : 2,
                  shadowColor:
                  isThisPlaying ? Colors.orangeAccent : Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: isThisPlaying
                        ? const BorderSide(
                        color: Colors.orangeAccent, width: 2)
                        : BorderSide.none,
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Arabic text
                        Text(
                          ayah['text_ar'] ?? "",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.amiri(
                            fontSize: 24,
                            color: Colors.white,
                            height: 2.0,
                          ),
                        ),

                        // Translation (toggle)
                        if (isExpanded) ...[
                          const SizedBox(height: 8),
                          Text(
                            ayah['text_mn'] ?? "",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.merriweather(
                              fontSize: 16,
                              color: Colors.orangeAccent,
                              height: 1.4,
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // Action bar
                        Container(
                          decoration: BoxDecoration(
                            color: isThisPlaying
                                ? Colors.orange.shade700
                                : Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                          height: 44,
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              // Ayah badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${widget.surahNumber}:${ayah['ayah_number']}",
                                  style: GoogleFonts.merriweather(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),

                              // ▶️ / ⏸
                              IconButton(
                                iconSize: 22,
                                icon: Icon(
                                  isThisPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (isThisPlaying) {
                                    _pauseAudio();
                                  } else {
                                    _playAyah(ayah['ayah_number'],
                                        index: index);
                                  }
                                },
                              ),

                              // ❤️
                              IconButton(
                                iconSize: 22,
                                icon: const Icon(Icons.favorite_border,
                                    color: Colors.red),
                                onPressed: () async {
                                  final ayahData = {
                                    'surah_number': widget.surahNumber,
                                    'ayah_number': ayah['ayah_number'],
                                    'text_ar': ayah['text_ar'],
                                    'text_mn': ayah['text_mn'],
                                  };
                                  await BookmarkManager.addFavorite(
                                      ayahData);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Added to Favorites",
                                          style:
                                          GoogleFonts.merriweather(),
                                        ),
                                        duration:
                                        const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),

                              // 📤
                              IconButton(
                                iconSize: 22,
                                icon: const Icon(Icons.share,
                                    color: Colors.white),
                                onPressed: () {
                                  final shareText =
                                      "${ayah['text_ar']} "
                                      "\n\n${ayah['text_mn'] ?? ""} "
                                      "\n\n(${widget.surahNumber}:${ayah['ayah_number']})";
                                  Share.share(shareText);
                                },
                              ),

                              // 🔁
                              IconButton(
                                iconSize: 22,
                                icon: Icon(
                                  repeatAyah
                                      ? Icons.repeat_one
                                      : Icons.repeat,
                                  color: repeatAyah || repeatSurah
                                      ? Colors.greenAccent
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (!repeatAyah && !repeatSurah) {
                                      repeatAyah = true;
                                      repeatSurah = false;
                                    } else if (repeatAyah) {
                                      repeatAyah = false;
                                      repeatSurah = true;
                                    } else {
                                      repeatAyah = false;
                                      repeatSurah = false;
                                    }
                                  });
                                },
                              ),

                              // 👁
                              IconButton(
                                iconSize: 22,
                                icon: Icon(
                                  isExpanded
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    expandedAyahIndex =
                                    isExpanded ? null : index;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
