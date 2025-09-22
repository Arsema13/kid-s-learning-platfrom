import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  // Fetch total number of students
  Future<int> fetchTotalStudents() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.length;
  }

  // Fetch total number of lessons completed
  Future<int> fetchTotalLessonCompletions() async {
    final snapshot = await FirebaseFirestore.instance.collection('lessons').get();
    int total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('completedBy')) {
        total += (data['completedBy'] as List).length;
      }
    }
    return total;
  }

  // Fetch total number of awards
  Future<int> fetchTotalAwards() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    int total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('achievements')) {
        total += (data['achievements'] as List).length;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports"), backgroundColor: Colors.orangeAccent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Student Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: fetchTotalStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text("Total Students"),
                    trailing: Text(snapshot.data.toString()),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text("Lesson Completion", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: fetchTotalLessonCompletions(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: const Text("Lessons Completed"),
                    trailing: Text(snapshot.data.toString()),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text("Awards Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: fetchTotalAwards(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: const Text("Total Awards"),
                    trailing: Text(snapshot.data.toString()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
