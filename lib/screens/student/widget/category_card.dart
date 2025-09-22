import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final double progress;
  final Color backgroundColor;
  final Color progressBarColor;
  final VoidCallback? onPressed;

  const CategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.progress,
    required this.backgroundColor,
    required this.progressBarColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            // Description
            Text(
              description,
              style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[700]),
            ),

            const SizedBox(height: 10),

            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              color: progressBarColor,
              backgroundColor: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }
}
