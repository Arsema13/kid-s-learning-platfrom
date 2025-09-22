import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressContent extends StatefulWidget {
  const ProgressContent({super.key});

  @override
  State<ProgressContent> createState() => _ProgressContentState();
}

class _ProgressContentState extends State<ProgressContent> {
  Map<String, dynamic>? progressData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProgress();
  }

  Future<void> fetchProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (doc.exists && doc.data()!.containsKey('progress')) {
      setState(() {
        progressData = doc['progress'];
        isLoading = false;
      });
    } else {
      // Initialize if not exist
      await docRef.set({
        'progress': {
          'overall': 0.0,
          'maths': 0.0,
          'amharic': 0.0,
          'science': 0.0,
          'stories': 0.0,
          'culture': 0.0,
        }
      });
      setState(() {
        progressData = {
          'overall': 0.0,
          'maths': 0.0,
          'amharic': 0.0,
          'science': 0.0,
          'stories': 0.0,
          'culture': 0.0,
        };
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Progress",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : progressData == null
              ? const Center(child: Text("No progress found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircularPercentIndicator(
                          radius: 120.0,
                          lineWidth: 12.0,
                          animation: true,
                          animationDuration: 1000,
                          percent: progressData!['overall'],
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${(progressData!['overall'] * 100).toInt()}%",
                                style: GoogleFonts.poppins(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Overall",
                                style: GoogleFonts.poppins(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor: Colors.grey[300]!,
                          progressColor: Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Subject Progress",
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      _buildAnimatedBar("Maths & Numbers", progressData!['maths'], Colors.blue),
                      const SizedBox(height: 16),
                      _buildAnimatedBar("Amharic Alphabet", progressData!['amharic'], Colors.redAccent),
                      const SizedBox(height: 16),
                     
                    ],
                  ),
                ),
    );
  }

  Widget _buildAnimatedBar(String title, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value),
          duration: const Duration(milliseconds: 800),
          builder: (context, val, _) => LinearProgressIndicator(
            value: val,
            minHeight: 14,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text("${(value * 100).toInt()}%", style: GoogleFonts.poppins()),
      ],
    );
  }
}
