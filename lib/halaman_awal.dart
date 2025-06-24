import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'screens/obat/obat_screen.dart';
import 'screens/profile/profile_screen.dart';

class HalamanAwal extends StatefulWidget {
  const HalamanAwal({super.key});

  @override
  State<HalamanAwal> createState() => _HalamanAwalState();
}

class _HalamanAwalState extends State<HalamanAwal> {
  int _currentIndex = 0;

  // Buat widget sekali dan tetap (tidak rebuild)
  final List<Widget> _pages = const [ObatListScreen(), ProfileScreen()];

  final items = <Widget>[
    Icon(Icons.medical_information, size: 30),
    Icon(Icons.person, size: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(title: const Text("Hallo, Admin")),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages, // ✅ Tidak akan dibuild ulang
      ),
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
