import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../service/supabase_service.dart';

class ObatListScreen extends StatefulWidget {
  const ObatListScreen({Key? key}) : super(key: key);

  @override
  State<ObatListScreen> createState() => _ObatListScreenState();
}

class _ObatListScreenState extends State<ObatListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<dynamic> _obatList = [];
  List<dynamic> _semuaObat = []; // <- Untuk menyimpan data lengkap
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchObat();
  }

  Future<void> _fetchObat() async {
    print("Memanggil ulang _fetchObat()");
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getObat();
      setState(() {
        _semuaObat = data;
        _obatList = data;
      });
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

  void _filterObat(String keyword) {
    final hasil = _semuaObat.where((item) {
      final nama = (item['nama'] ?? '').toString().toLowerCase();
      return nama.contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      _obatList = hasil;
    });
  }

  String formatRupiah(dynamic value) {
    final number = int.tryParse(value.toString()) ?? 0;
    return NumberFormat("#,##0", "id_ID").format(number);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: const Color(0xFFE0F7F1),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterObat,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: 'Cari',
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Get.toNamed('/obatform');
                      if (result == true) _fetchObat();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shadowColor: Colors.black38,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Tambah Obat',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _obatList.isEmpty
                      ? const Center(child: Text('Tidak ditemukan obat'))
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio:
                                    0.9, // <- Ukuran card lebih kecil
                              ),
                          itemCount: _obatList.length,
                          itemBuilder: (context, index) {
                            final item = _obatList[index];
                            return GestureDetector(
                              onTap: () async {
                                final confirm = await Get.dialog(
                                  AlertDialog(
                                    title: const Text("Konfirmasi"),
                                    content: const Text(
                                      "Yakin ingin menghapus obat ini?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Get.back(result: false),
                                        child: const Text("Batal"),
                                      ),
                                      TextButton(
                                        onPressed: () => Get.back(result: true),
                                        child: const Text("Hapus"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  try {
                                    await _supabaseService.deleteObat(
                                      item['id'],
                                    );
                                    _fetchObat();
                                    Get.snackbar(
                                      'Berhasil',
                                      'Obat berhasil dihapus',
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.black.withOpacity(
                                        0.5,
                                      ), // transparan
                                      colorText: Colors.white,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: 12,
                                      duration: const Duration(seconds: 2),
                                      isDismissible: true,
                                    );
                                  } catch (e) {
                                    Get.snackbar(
                                      'Gagal',
                                      'Gagal menghapus obat: $e',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(3, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    item['img'] != null &&
                                            item['img'].toString().isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.network(
                                              item['img'],
                                              height: 85,
                                              width: 85,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.medication,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                    const SizedBox(height: 10),
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
                                      "Rp${formatRupiah(item['harga'])}",
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                      ),
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
      ),
    );
  }
}
