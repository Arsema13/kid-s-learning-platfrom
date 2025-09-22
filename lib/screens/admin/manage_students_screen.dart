import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../widgets/student_card.dart';

class ManageStudentsScreen extends StatelessWidget {
  const ManageStudentsScreen({super.key});

  Future<List<StudentModel>> fetchStudents() async {
    final snapshot = await FirebaseFirestore.instance.collection('students').get();
    return snapshot.docs
        .map((doc) => StudentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Students")),
      body: FutureBuilder<List<StudentModel>>(
        future: fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          final students = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return StudentCard(
                student: student,
                onTap: () {
                  // TODO: Navigate to student detail or edit
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Tapped on ${student.name}")),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
