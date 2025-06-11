import 'package:app_pentamed/page/dashboard.dart';
import 'package:app_pentamed/page/login.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HalamanAwal extends StatefulWidget {
  final String pengguna;
  const HalamanAwal({super.key, required this.pengguna});

  @override
  State<HalamanAwal> createState() => _HalamanAwalState();
}

class _HalamanAwalState extends State<HalamanAwal> {
  int _currentIndex = 1;

  final List<Widget> _pages = [Login(), Dashboard()];

  final items = <Widget>[
    Icon(Icons.medical_information, size: 30),
    Icon(Icons.report, size: 30),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(title: Text("Hallo, ${widget.pengguna}")),
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
