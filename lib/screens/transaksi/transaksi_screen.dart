import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../service/supabase_service.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final SupabaseService _service = SupabaseService();
  final List<Map<String, dynamic>> _keranjang = [];

  int _total = 0;
  int _bayar = 0;
  int _kembali = 0;

  final TextEditingController _bayarController = TextEditingController();

  /// Hitung ulang total dari _keranjang
  void _hitungTotal() {
    _total = _keranjang.fold<int>(0, (sum, item) {
      final sub = item['subtotal'];
      if (sub is int) {
        return sum + sub;
      }
      // jika bukan int, abaikan
      return sum;
    });
  }

  /// Contoh fungsi untuk menambahkan item ke keranjang
  void tambahItem({
    required String nama,
    required int jumlah,
    required int harga,
  }) {
    final subtotal = jumlah * harga;
    setState(() {
      _keranjang.add({
        'nama': nama,
        'jumlah': jumlah,
        'harga': harga,
        'subtotal': subtotal,
      });
      _hitungTotal(); // langsung recalc
    });
  }

  void _simpanTransaksi() async {
    if (_keranjang.isEmpty) {
      Get.snackbar('Error', 'Keranjang masih kosong');
      return;
    }

    if (_bayar < _total) {
      Get.snackbar('Error', 'Uang bayar kurang');
      return;
    }

    _kembali = _bayar - _total;

    try {
      await _service.insertTransaksi(
        tanggal: DateTime.now(),
        total: _total,
        bayar: _bayar,
        kembali: _kembali,
        keranjang: _keranjang,
      );

      Get.snackbar('Berhasil', 'Transaksi berhasil disimpan');
      setState(() {
        _keranjang.clear();
        _bayarController.clear();
        _total = 0;
        _bayar = 0;
        _kembali = 0;
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan total selalu up-to-date sebelum build UI
    _hitungTotal();

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Keranjang'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _keranjang.length,
                itemBuilder: (context, index) {
                  final item = _keranjang[index];
                  return ListTile(
                    title: Text(item['nama'] ?? ''),
                    subtitle: Text(
                      'Jumlah: ${item['jumlah']}, Harga: ${item['harga']}',
                    ),
                    trailing: Text('Subtotal: ${item['subtotal']}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Total: $_total'),
            const SizedBox(height: 8),
            TextField(
              controller: _bayarController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Bayar'),
              onChanged: (value) {
                setState(() {
                  _bayar = int.tryParse(value) ?? 0;
                  _kembali = _bayar - _total;
                });
              },
            ),
            const SizedBox(height: 8),
            Text('Kembali: $_kembali'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _simpanTransaksi,
              child: const Text('Simpan Transaksi'),
            ),
            const SizedBox(height: 24),
            // Tombol demo: tambah item contoh
            ElevatedButton(
              onPressed: () {
                tambahItem(nama: 'Obat A', jumlah: 2, harga: 15000);
              },
              child: const Text('Tambah Obat A (2 × 15000)'),
            ),
          ],
        ),
      ),
    );
  }
}
