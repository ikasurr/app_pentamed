import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../service/supabase_service.dart';

class DetailObat extends StatelessWidget {
  const DetailObat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> obat = Get.arguments;
    final SupabaseService _supabaseService = SupabaseService();

    void _showDeleteConfirmation() {
      Get.defaultDialog(
        title: "Hapus Obat",
        middleText: "Yakin ingin menghapus obat ini?",
        textConfirm: "Hapus",
        textCancel: "Batal",
        confirmTextColor: Colors.white,
        onConfirm: () async {
          Get.back(); // Tutup dialog

          try {
            await _supabaseService.deleteObat(obat['id']);

            Get.snackbar(
              "Sukses",
              "Obat berhasil dihapus",
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );

            // Ganti halaman detail dengan ObatListScreen baru (langsung refresh)
            Get.back(result: true);
          } catch (e) {
            Get.snackbar(
              "Error",
              "Gagal menghapus obat: $e",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F4),
      appBar: AppBar(
        title: const Text('Detail Obat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Gambar Obat
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: obat['img'] != null && obat['img'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        obat['img'],
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    )
                  : const Icon(Icons.medication, size: 100),
            ),
            const SizedBox(height: 20),

            // Deskripsi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    obat['nama'] ?? 'Nama tidak tersedia',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Harga: Rp${obat['harga']}"),
                  const SizedBox(height: 8),
                  Text(
                    "Deskripsi: ${obat['deskripsi'] ?? 'Tidak ada deskripsi'}",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Edit & Hapus
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Get.toNamed(
                      '/obatform',
                      arguments: obat,
                    );
                    if (result == true) {
                      Get.back(); // Kembali & refresh
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _showDeleteConfirmation,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
