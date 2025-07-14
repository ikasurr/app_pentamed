import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:app_pentamed/screens/profile/profile_screen.dart';
import 'package:get/get.dart';
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
  late final String pengguna;

  // Ambil argument dari Get.arguments saat init
  @override
  void initState() {
    super.initState();
    pengguna = (Get.arguments ?? 'Pengguna').toString();
  }

  final List<Widget> _pages = [
    TransaksiScreen(),
    ObatListScreen(),
    HomeScreen(),
    LaporanScreen(),
    ProfileScreen(),
  ];

  final items = <Widget>[
    Icon(Icons.credit_card, size: 30),
    Icon(Icons.medical_information, size: 30),
    Icon(Icons.home, size: 30),
    Icon(Icons.assignment, size: 30),
    Icon(Icons.person, size: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(title: Text("Hallo, $pengguna")),
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
