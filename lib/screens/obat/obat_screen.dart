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
    print("🔥 Memanggil ulang _fetchObat()");
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Optional: lakukan apa pun sebelum keluar
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE0F7F1),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                // Search bar
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
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: 'Cari',
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Tombol tambah
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
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: _obatList.length,
                          itemBuilder: (context, index) {
                            final item = _obatList[index];
                            return GestureDetector(
                              onTap: () async {
                                final result = await Get.toNamed(
                                  '/obatdetail',
                                  arguments: item,
                                );
                                if (result == true) {
                                  _fetchObat(); // Refresh data jika ada perubahan
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
                                padding: const EdgeInsets.all(12),
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
                                              height: 80,
                                              width: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.medication,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                    const SizedBox(height: 12),
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
      ),
    );
  }
}
