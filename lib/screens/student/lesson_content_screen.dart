import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson_detail_screen.dart';

class LessonContentScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const LessonContentScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<LessonContentScreen> createState() => _LessonContentScreenState();
}

class _LessonContentScreenState extends State<LessonContentScreen> {
  Map<int, double> levelProgress = {}; // Level => progress (0.0-1.0)
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLevelProgress();
  }

  Future<void> _fetchLevelProgress() async {
    try {
      Map<int, double> progressMap = {};

      if (widget.categoryId.toLowerCase() == 'maths') {
        // 🔹 Fetch Maths lessons from level-specific collections (maths_1, maths_2, ...)
        for (int lvl = 1; lvl <= 4; lvl++) {
          final snapshot = await FirebaseFirestore.instance
              .collection('maths_$lvl')
              .get();

          final docs = snapshot.docs;
          if (docs.isEmpty) {
            progressMap[lvl] = 0.0;
            continue;
          }

          int completed = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['completed'] == true;
          }).length;

          progressMap[lvl] = completed / docs.length;
        }
      } else {
        // 🔹 Fetch Amharic or other categories from contents
        final snapshot = await FirebaseFirestore.instance
            .collection('contents')
            .where('categoryId', isEqualTo: widget.categoryId)
            .get();

        Map<int, List<DocumentSnapshot>> lessonsPerLevel = {};
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final level = data['level'] as int? ?? 1;
          lessonsPerLevel.putIfAbsent(level, () => []);
          lessonsPerLevel[level]!.add(doc);
        }

        lessonsPerLevel.forEach((level, lessons) {
          int completed = lessons.where((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return d['progress'] != null && d['progress'] >= 1.0;
          }).length;
          progressMap[level] =
              lessons.isNotEmpty ? completed / lessons.length : 0.0;
        });
      }

      setState(() {
        levelProgress = progressMap;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching level progress: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> levelEmojis = ["🌱", "🚀", "🧠", "👑"];
    final List<List<Color>> gradients = [
      [Colors.greenAccent, Colors.tealAccent],
      [Colors.orangeAccent, Colors.deepOrangeAccent],
      [Colors.blueAccent, Colors.indigoAccent],
      [Colors.purpleAccent, Colors.pinkAccent],
    ];

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: List.generate(4, (index) {
            final level = index + 1;
            final progress = levelProgress[level] ?? 0.0;
            final prevProgress = levelProgress[level - 1] ?? 1.0;
            final isUnlocked = level == 1 || prevProgress >= 0.6;

            return GestureDetector(
              onTap: isUnlocked
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonDetailScreen(
                            categoryId: widget.categoryId,
                            level: level,
                          ),
                        ),
                      ).then((_) => _fetchLevelProgress());
                    }
                  : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isUnlocked
                        ? gradients[index]
                        : [Colors.grey.shade300, Colors.grey.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(4, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(levelEmojis[index], style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text(
                      "Level $level",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.white : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isUnlocked
                          ? (progress >= 1.0
                              ? "🎉 Completed!"
                              : "Progress: ${(progress * 100).toInt()}%")
                          : "🔒 Locked — Finish previous level",
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked ? Colors.white70 : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: isUnlocked ? Colors.white24 : Colors.grey[400],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUnlocked ? Colors.white : Colors.black26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isUnlocked)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LessonDetailScreen(
                                categoryId: widget.categoryId,
                                level: level,
                              ),
                            ),
                          ).then((_) => _fetchLevelProgress());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(progress >= 1.0 ? "Review" : "Start"),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
