import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'screens/auth/login_screen.dart';
import 'screens/obat/obat_screen.dart';
import 'screens/profile/profile_screen.dart';

class HalamanAwal extends StatefulWidget {
  const HalamanAwal({super.key});

  @override
  State<HalamanAwal> createState() => _HalamanAwalState();
}

class _HalamanAwalState extends State<HalamanAwal> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    ObatListScreen(),
    LoginScreen(),
    ProfileScreen(),
  ];

  final items = <Widget>[
    Icon(Icons.medical_information, size: 30),
    Icon(Icons.home, size: 30),
    Icon(Icons.article_outlined, size: 30),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(title: Text("Hallo, Admin")),
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        items: items,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        color: Colors.white,
        buttonBackgroundColor: Colors.blueAccent,
      ),
    );
  }
}
