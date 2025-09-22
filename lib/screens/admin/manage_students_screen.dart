import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../widgets/student_card.dart';

class ManageStudentsScreen extends StatelessWidget {
  const ManageStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Students"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('kidName')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          final students = snapshot.data!.docs
              .map((doc) => StudentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return StudentCard(
                student: student,
                onTap: () {
                  // TODO: Navigate to student detail/edit screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Tapped on ${student.kidName}")),
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
