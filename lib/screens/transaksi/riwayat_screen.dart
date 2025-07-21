import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../service/supabase_service.dart'; // sesuaikan dengan path kamu

class RiwayatScreen extends StatelessWidget {
  RiwayatScreen({super.key});

  final SupabaseService _service = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _service.getAllTransaksi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada transaksi."));
          }

          final transaksi = snapshot.data!;
          return ListView.builder(
            itemCount: transaksi.length,
            itemBuilder: (context, i) {
              final t = transaksi[i];
              final tanggal = DateFormat(
                'dd MMM yyyy',
                'id_ID',
              ).format(DateTime.parse(t['tanggal']));
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(
                  "Rp${NumberFormat("#,##0", "id_ID").format(t['total'])}",
                ),
                subtitle: Text(tanggal),
              );
            },
          );
        },
      ),
    );
  }
}
