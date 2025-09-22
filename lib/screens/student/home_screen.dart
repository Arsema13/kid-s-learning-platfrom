import 'package:flutter/material.dart';
import 'lesson_content_screen.dart';
import 'awards_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hi!',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  String _userName = "User"; // default

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the two categories manually
    final List<Map<String, dynamic>> _categories = [
      {
        'id': 'amharic',
        'title': 'Amharic',
        'description': 'Learn the Amharic language 🌟',
        'emoji': '📚',
        'colors': [Colors.orange.shade300, Colors.orange.shade100],
      },
      {
        'id': 'maths',
        'title': 'Maths',
        'description': 'Sharpen your math skills 🧮',
        'emoji': '🧮',
        'colors': [Colors.blue.shade400, Colors.blue.shade200],
      },
    ];

    // Screens for bottom navigation
    final List<Widget> _screens = [
      // Home screen
      SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _animationController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $_userName! 👋',
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'What would you like to explore today?',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final card = _categories[index];

                  return AnimatedScale(
                    scale: 1.0,
                    duration: Duration(milliseconds: 400 + index * 100),
                    curve: Curves.easeOutBack,
                    child: LearningCard(
                      title: card['title'],
                      subtitle: card['description'],
                      emoji: card['emoji'],
                      colors: card['colors'],
                      onStartLearning: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonContentScreen(
                              categoryId: card['id'],
                              categoryTitle: card['title'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // Learn screen (can be a separate LearnScreen or same as Home)
      
      // Awards screen
      const AwardsScreen(),
      // Progress screen
            ProgressContent(),
      // Profile screen
       ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined), label: 'Awards'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: 'Progress'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange[700],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class LearningCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> colors;
  final VoidCallback onStartLearning;

  const LearningCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colors,
    required this.onStartLearning,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onStartLearning,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 60),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: onStartLearning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("Start 🚀"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
