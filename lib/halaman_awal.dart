import 'package:flutter/material.dart';

class HalamanAwal extends StatefulWidget {
  final String pengguna;
  const HalamanAwal({super.key, required this.pengguna});

  @override
  State<HalamanAwal> createState() => _HalamanAwalState();
}

class _HalamanAwalState extends State<HalamanAwal> {
  int _currentIndex = 2;

  final List<Widget> _pages = [];

  final items = <Widget>[
    Icon(Icons.medical_information, size: 30),
    Icon(Icons.report, size: 30),
    Icon(Icons.home, size: 30),
    Icon(Icons.attach_money, size: 30),
    Icon(Icons.manage_accounts, size: 30),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
