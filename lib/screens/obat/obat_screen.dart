// lib/screens/home/obat_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../service/supabase_service.dart';

class ObatListScreen extends StatefulWidget {
  const ObatListScreen({Key? key}) : super(key: key);

  @override
  State<ObatListScreen> createState() => _ObatListScreenState();
}

class _ObatListScreenState extends State<ObatListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<dynamic> _obatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchObat();
  }

  Future<void> _fetchObat() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getObat();
      setState(() => _obatList = data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data obat: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteObat(int id) async {
    try {
      await _supabaseService.deleteObat(id);
      Get.snackbar(
        'Sukses',
        'Data obat berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _fetchObat();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus obat: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showDeleteConfirmation(int id) {
    Get.defaultDialog(
      title: "Hapus Obat",
      middleText: "Apakah Anda yakin ingin menghapus obat ini?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        _deleteObat(id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7F1), // Warna mint background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: 'Cari',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tombol tambah obat
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Get.toNamed('/obatform');
                    if (result == true) _fetchObat();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shadowColor: Colors.grey.withOpacity(0.6),
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tambah Obat',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Grid Obat
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _obatList.isEmpty
                    ? const Center(child: Text('Belum ada data obat'))
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 3 / 4,
                            ),
                        itemCount: _obatList.length,
                        itemBuilder: (context, index) {
                          final item = _obatList[index];
                          return GestureDetector(
                            onTap: () {}, // Aksi opsional
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    offset: Offset(4, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  item['img'] != null &&
                                          item['img'].toString().isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            item['img'],
                                            height: 70,
                                            width: 70,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.medication,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['nama'] ?? '-',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rp${item['harga']}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
