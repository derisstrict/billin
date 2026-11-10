import 'package:billin/common/c_colors.dart';
import 'package:billin/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:billin/common/navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text('Beranda')), // ganti dengan HomePage()
    Center(child: ProfilePage()), // ganti dengan ProfilePage()
  ];

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Scaffold(body: Center(child: Text('Scan'))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Navbar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        onScanTap: _openScanner,
      ),
    );
  }
}
