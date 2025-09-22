
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String _kidName = "User";
  String _avatarEmoji = "👧";

  int _lessonsCompleted = 0;
  int _totalLessons = 20; // example
  int _badgesEarned = 0;
  int _totalBadges = 5; // example
  int _points = 0;

  List<Map<String, dynamic>> _achievements = [];

  late AnimationController _animationController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _kidName = data['kidName'] ?? "User";
          _avatarEmoji = data['avatarEmoji'] ?? "👧";

          _lessonsCompleted = data['progress']?['lessonsCompleted'] ?? 0;
          _points = data['progress']?['points'] ?? 0;
          _badgesEarned = data['progress']?['badgesEarned'] ?? 0;

          _achievements =
              List<Map<String, dynamic>>.from(data['achievements'] ?? []);

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.orange[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar and Name
                  ScaleTransition(
                    scale: CurvedAnimation(
                        parent: _animationController, curve: Curves.elasticOut),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.orange[200],
                          child: Text(
                            _avatarEmoji,
                            style: const TextStyle(fontSize: 50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _kidName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Keep learning and have fun!',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      _buildStatCard(
                          "Lessons Completed",
                          "$_lessonsCompleted/$_totalLessons",
                          Colors.blue),
                      _buildStatCard("Badges Earned",
                          "$_badgesEarned/$_totalBadges", Colors.purple),
                      _buildStatCard("Points", "$_points", Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Achievements
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Achievements",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: _achievements.isEmpty
                            ? Center(
                                child: Text(
                                  "No achievements yet!",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final badge = _achievements[index];
                                  final colors = [
                                    Colors.primaries[Random()
                                        .nextInt(Colors.primaries.length)]
                                        .shade200,
                                    Colors.primaries[Random()
                                        .nextInt(Colors.primaries.length)]
                                        .shade400,
                                  ];
                                  return Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: colors,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                          offset: const Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          badge['emoji'] ?? "🎯",
                                          style: const TextStyle(fontSize: 36),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          badge['title'] ?? "",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemCount: _achievements.length,
                              ),
                      )
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.5), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}