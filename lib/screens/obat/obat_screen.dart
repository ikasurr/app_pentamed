// lib/screens/home/obat_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../service/supabase_service.dart';

class ObatListScreen extends StatefulWidget {
  const ObatListScreen({super.key});

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
      appBar: AppBar(title: const Text('Kelola Obat')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _obatList.isEmpty
          ? const Center(child: Text('Belum ada data obat'))
          : ListView.builder(
              itemCount: _obatList.length,
              itemBuilder: (context, index) {
                final item = _obatList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading:
                        item['img'] != null && item['img'].toString().isNotEmpty
                        ? Image.network(
                            item['img'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.medication, size: 40),
                    title: Text(
                      item['nama'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Harga: Rp${item['harga']}"),
                        Text(
                          "Stok: ${item['stok']}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(item['deskripsi'] ?? ''),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Get.toNamed(
                              '/obatform',
                              arguments: item,
                            );
                            if (result == true) _fetchObat();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed('/obatform');
          if (result == true) _fetchObat();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
