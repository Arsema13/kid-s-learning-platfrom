import 'package:flutter/material.dart';
import 'lesson_detail_screen.dart';

class LevelsScreen extends StatelessWidget {
  final String categoryId;
  final String categoryTitle;

  const LevelsScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    final levels = [
      {"number": 1, "icon": "🚀", "color": Colors.red},
      {"number": 2, "icon": "🦄", "color": Colors.blue},
      {"number": 3, "icon": "🐯", "color": Colors.green},
      {"number": 4, "icon": "🌈", "color": Colors.purple},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("$categoryTitle Levels"),
        backgroundColor: Colors.purple,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 per row
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonDetailScreen(
                    categoryId: categoryId,
                    level: level["number"] as int,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (level["color"] as Color).withOpacity(0.7),
                    (level["color"] as Color).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(level["icon"] as String, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 10),
                    Text(
                      "Level ${level["number"]}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
