import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSettingsScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  const AdminSettingsScreen({super.key, this.onThemeChanged});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  void _toggleDarkMode(bool value) {
    setState(() => _darkMode = value);
    widget.onThemeChanged?.call(value);
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _notificationsEnabled = value);
    await prefs.setBool('notifications', value);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logged out successfully!")),
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SwitchListTile(
                title: const Text(
                  "Dark Mode 🌙",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Toggle between light and dark theme"),
                value: _darkMode,
                onChanged: _toggleDarkMode,
                secondary: const Icon(Icons.dark_mode),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SwitchListTile(
                title: const Text(
                  "Notifications 🔔",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Enable or disable notifications"),
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                secondary: const Icon(Icons.notifications),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Logout 🚪",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
