import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        setState(() {
          loading = false;
        });
        return;
      }

      final userId = user.id;

      // Jumlah total obat
      final obatRes = await supabase.from('obat').select('id');
      totalObat = obatRes.length;

      // Hari ini (format ISO)
      final hariIni = DateTime.now();
      final mulai = DateTime(
        hariIni.year,
        hariIni.month,
        hariIni.day,
      ).toIso8601String();
      final akhir = hariIni.toIso8601String();

      // Transaksi hari ini
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
      print('Error ambil data dashboard: $e');
    }

    setState(() => loading = false);
  }

  Widget buildCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
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
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
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
                      Colors.teal,
                    ),
                    buildCard(
                      'Transaksi Hari Ini',
                      '$totalTransaksiHariIni',
                      Icons.receipt_long,
                      Colors.orange,
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildCard(
                      'Pendapatan Hari Ini',
                      'Rp $totalPendapatanHariIni',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
