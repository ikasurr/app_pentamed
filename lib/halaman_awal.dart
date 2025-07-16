import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:app_pentamed/screens/profile/profile_screen.dart';
import 'package:app_pentamed/screens/obat/obat_screen.dart';
import 'package:app_pentamed/screens/laporan/laporan_screen.dart';
import 'package:app_pentamed/screens/transaksi/transaksi_screen.dart';
import 'package:app_pentamed/screens/home/home_screen.dart';

class HalamanAwal extends StatefulWidget {
  const HalamanAwal({super.key}); // ← tidak butuh parameter pengguna

  @override
  State<HalamanAwal> createState() => _HalamanAwalState();
}

class _HalamanAwalState extends State<HalamanAwal> {
  int _currentIndex = 2;

  // Ambil argument dari Get.arguments saat init
  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _pages = [
    ObatListScreen(),
    TransaksiScreen(),
    HomeScreen(),
    LaporanScreen(),
    ProfileScreen(),
  ];

  final items = <Widget>[
    Icon(Icons.medical_information, size: 30),
    Icon(Icons.credit_card, size: 30),
    Icon(Icons.home, size: 30),
    Icon(Icons.assignment, size: 30),
    Icon(Icons.person, size: 30),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7F1),
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
        buttonBackgroundColor: const Color(0xFFE0F7F1),
      ),
    );
  }
}
