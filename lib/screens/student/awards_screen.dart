import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  late ConfettiController _confettiController;

  List<Map<String, dynamic>> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });

    fetchUserAchievements();
  }

  /// Sample Awards Data
  List<Map<String, dynamic>> sampleAwards = [
    {
      "title": "First Steps",
      "description": "Completed your first lesson!",
      "icon": "book",
      "color": 0xFFFFA726, // Orange
    },
    {
      "title": "Rising Star",
      "description": "Finished 5 lessons in a row!",
      "icon": "emoji_events",
      "color": 0xFFFFC107, // Amber
    },
    {
      "title": "Consistency King",
      "description": "Logged in and studied 7 days in a row!",
      "icon": "calendar_today",
      "color": 0xFF4CAF50, // Green
    },
    {
      "title": "Achiever",
      "description": "Completed all lessons of a category!",
      "icon": "emoji_events",
      "color": 0xFF2196F3, // Blue
    },
    {
      "title": "Early Bird",
      "description": "Studied before 8 AM for 3 consecutive days!",
      "icon": "calendar_today",
      "color": 0xFFE91E63, // Pink
    },
    {
      "title": "Knowledge Seeker",
      "description": "Attempted 10 quizzes!",
      "icon": "book",
      "color": 0xFF9C27B0, // Purple
    },
  ];

  Future<void> fetchUserAchievements() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // For testing, you can load sample awards
      setState(() {
        _achievements = sampleAwards;
        _isLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _achievements =
              List<Map<String, dynamic>>.from(data['achievements'] ?? []);
          _isLoading = false;
        });
      } else {
        // No achievements yet, use sample data or leave empty
        setState(() {
          _achievements = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching achievements: $e");
      setState(() {
        _achievements = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text("🏆 My Awards"),
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? Center(
                    child: Lottie.asset(
                      'assets/lottie/loading.json', // put your loading Lottie here
                      width: 150,
                      height: 150,
                    ),
                  )
                : _achievements.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              'assets/lottie/socialv no data.json', // Lottie for empty state
                              width: 150,
                              height: 150,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No awards yet! Keep learning to earn them 🎉",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        itemCount: _achievements.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                        itemBuilder: (context, index) {
                          final award = _achievements[index];

                          IconData iconData = Icons.star; // default
                          if (award['icon'] == "book") iconData = Icons.book;
                          if (award['icon'] == "emoji_events")
                            iconData = Icons.emoji_events;
                          if (award['icon'] == "calendar_today")
                            iconData = Icons.calendar_today;

                          Color color = Colors.orange;
                          if (award['color'] != null) {
                            color = Color(award['color']);
                          }

                          return AnimatedAwardCard(
                            title: award['title'] ?? "",
                            description: award['description'] ?? "",
                            icon: iconData,
                            color: color,
                          );
                        },
                      ),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
                Colors.yellow
              ],
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 8,
              gravity: 0.3,
              particleDrag: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedAwardCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const AnimatedAwardCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  State<AnimatedAwardCard> createState() => _AnimatedAwardCardState();
}

class _AnimatedAwardCardState extends State<AnimatedAwardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.color.withOpacity(0.8), widget.color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 50, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
