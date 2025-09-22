import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  late ConfettiController _confettiController;

  final List<Map<String, dynamic>> mockAwards = const [
    {
      "title": "Math Whiz",
      "description": "Completed all Maths Levels",
      "icon": Icons.star,
      "color": Colors.orange,
    },
    {
      "title": "Reading Champ",
      "description": "Finished all Amharic Lessons",
      "icon": Icons.book,
      "color": Colors.purple,
    },
    {
      "title": "Consistency King",
      "description": "Logged in for 7 days straight",
      "icon": Icons.calendar_today,
      "color": Colors.blue,
    },
    {
      "title": "Quiz Master",
      "description": "Scored 100% in all quizzes",
      "icon": Icons.emoji_events,
      "color": Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Play confetti for 3 seconds when screen loads
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
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
            child: GridView.builder(
              itemCount: mockAwards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final award = mockAwards[index];
                return AnimatedAwardCard(
                  title: award['title'],
                  description: award['description'],
                  icon: award['icon'],
                  color: award['color'],
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
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
