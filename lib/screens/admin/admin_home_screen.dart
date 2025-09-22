import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_students_screen.dart';
import 'add_lesson_screen.dart';
import 'reports_screen.dart';
import 'admin_settings_screen.dart';
import 'add_student_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFFFDCB6E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, Admin!",
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildCard(
                    context,
                    "Manage Students",
                    Icons.group,
                    Colors.blueAccent,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManageStudentsScreen()),
                    ),
                  ),
                  _buildCard(
                    context,
                    "Add Student",
                    Icons.library_add,
                    Colors.orangeAccent,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddStudentScreen()),
                    ),
                  ),
                  _buildCard(
                    context,
                    "Add Lesson", // New card for adding lessons
                    Icons.menu_book,
                    Colors.teal,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddLessonScreen()),
                    ),
                  ),
                  _buildCard(
                    context,
                    "View Reports",
                    Icons.bar_chart,
                    Colors.greenAccent,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ReportsScreen()),
                    ),
                  ),
                  _buildCard(
                    context,
                    "Settings",
                    Icons.settings,
                    Colors.purpleAccent,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminSettingsScreen()),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color,
      VoidCallback onTap) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 36),
        title: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
