import 'package:flutter/material.dart';
import 'bottom_navigation_widget.dart';
import '../home_screen.dart';

import '../awards_screen.dart';
import '../progress_screen.dart';
import '../profile_screen.dart';

class MainBottomNavigation extends StatefulWidget {
  const MainBottomNavigation({super.key});

  @override
  State<MainBottomNavigation> createState() => _MainBottomNavigationState();
}

class _MainBottomNavigationState extends State<MainBottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens =  [
    HomePage(),
  
    AwardsScreen(), // <- This will show when Awards tab is clicked
    ProgressContent(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
