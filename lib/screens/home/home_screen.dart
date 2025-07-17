import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  int totalObat = 0;
  int totalTransaksiHariIni = 0;
  int totalPendapatanHariIni = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    ambilDataDashboard();
  }

  Future<void> ambilDataDashboard() async {
    setState(() => loading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => loading = false);
        return;
      }

      final userId = user.id;

      // Obat
      // Obat
      final obatRes = await supabase
          .from('obat')
          .select('id')
          .eq('user_id', userId); // Filter data obat sesuai user

      totalObat = obatRes.length;

      // Hari ini
      final now = DateTime.now();
      final mulai = DateTime(now.year, now.month, now.day).toIso8601String();
      final akhir = now.toIso8601String();

      final transaksiRes = await supabase
          .from('transaksi')
          .select('total')
          .eq('user_id', userId)
          .gte('tanggal', mulai)
          .lte('tanggal', akhir);

      totalTransaksiHariIni = transaksiRes.length;
      totalPendapatanHariIni = transaksiRes.fold(
        0,
        (sum, item) => sum + (item['total'] as int),
      );
    } catch (e) {
      print('Error dashboard: $e');
    }

    setState(() => loading = false);
  }

  Widget buildCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1), // semi-transparan
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7F1),
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFE0F7F1),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    buildCard(
                      'Total Obat',
                      '$totalObat',
                      Icons.medication_outlined,
                    ),
                    buildCard(
                      'Transaksi Hari Ini',
                      '$totalTransaksiHariIni',
                      Icons.receipt_long,
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildCard(
                      'Pendapatan Hari Ini',
                      'Rp $totalPendapatanHariIni',
                      Icons.attach_money,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
