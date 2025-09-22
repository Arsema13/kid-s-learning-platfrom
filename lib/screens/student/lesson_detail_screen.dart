import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonDetailScreen extends StatefulWidget {
  final String categoryId;
  final int level;

  const LessonDetailScreen({
    super.key,
    required this.categoryId,
    required this.level,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late Future<List<QueryDocumentSnapshot>> _lessonsFuture;
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = fetchLessons();
  }

  Future<List<QueryDocumentSnapshot>> fetchLessons() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('contents')
          .where('categoryId', isEqualTo: widget.categoryId)
          .where('level', isEqualTo: widget.level)
          .orderBy('lessonNumber')
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint("⚠️ No lessons found for ${widget.categoryId}, level ${widget.level}");
      }

      currentIndex = 0;
      _pageController = PageController(initialPage: currentIndex);

      return snapshot.docs;
    } catch (e) {
      debugPrint("❌ Error fetching lessons: $e");
      return [];
    }
  }

  Future<void> markLessonCompleted(DocumentSnapshot lesson) async {
    try {
      await FirebaseFirestore.instance
          .collection('contents')
          .doc(lesson.id)
          .update({'completed': true});

      setState(() {
        lesson.reference.update({'completed': true});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson marked as completed ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating progress: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: _lessonsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('🚫 No lessons found for this level.')),
          );
        }

        final lessons = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Level ${widget.level} - Lesson ${lessons[currentIndex]['lessonNumber'] ?? ''}',
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: lessons.length,
                  onPageChanged: (index) {
                    setState(() => currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    final videoUrl = lesson['videoUrl'] ?? '';
                    final youtubeId = YoutubePlayer.convertUrlToId(videoUrl);
                    final isCompleted = lesson['completed'] ?? false;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            lesson['description'] ?? 'No Description',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          if (youtubeId != null)
                            YoutubePlayer(
                              controller: YoutubePlayerController(
                                initialVideoId: youtubeId,
                                flags: const YoutubePlayerFlags(
                                  autoPlay: false,
                                ),
                              ),
                              showVideoProgressIndicator: true,
                            ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: isCompleted
                                ? null
                                : () => markLessonCompleted(lesson),
                            icon: const Icon(Icons.check_circle),
                            label: Text(
                              isCompleted ? "Completed" : "Mark as Completed",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isCompleted ? Colors.grey : Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: currentIndex > 0
                          ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                          : null,
                      child: const Text("Previous"),
                    ),
                    ElevatedButton(
                      onPressed: currentIndex < lessons.length - 1
                          ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                          : null,
                      child: const Text("Next"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
