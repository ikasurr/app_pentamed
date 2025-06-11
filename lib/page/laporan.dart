import 'package:flutter/material.dart';

void main() {
  runApp(const LaporanTransaksiApp());
}

class LaporanTransaksiApp extends StatelessWidget {
  const LaporanTransaksiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laporan Transaksi',
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: const LaporanTransaksiPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LaporanTransaksiPage extends StatelessWidget {
  const LaporanTransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E6E6),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'LAPORAN TRANSAKSI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.calendar_today, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Periode Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 200,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 8),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Tabel Laporan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 6,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Colors.black38,
                  ),
                  onPressed: () {
                    // TODO: tambahkan fungsi cetak di sini
                  },
                  child: const Text(
                    'Cetak',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
