import 'package:app_pentamed/page/obat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../services/supabase_service.dart';

class ObatScreen extends StatefulWidget {
  const ObatScreen({super.key});

  @override
  State<ObatScreen> createState() => _ObatScreenState();
}

class _ObatScreenState extends State<ObatScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Obat> _obat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchobats();
  }

  Future<void> _fetchobats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _supabaseService.getObat();
      setState(() {
        _obat = data.map((item) => Obat.fromJson(item)).toList();
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat Obat: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteObat(int id) async {
    try {
      await _supabaseService._deleteObat);
      Get.snackbar(
        'Sukses',
        'Catatan berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _fetchobats(); // Muat ulang daftar catatan
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus catatan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  Widget build(BuildContext context) {
    return scaffold(
       appBar: AppBar(title: const Text('Daftar Obat')),
       body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _obat.isEmpty
              ? const Center(
                child: Text('Anda belum memiliki catatan. Buat satu!'),
              )
              : ListView.builder(
                itemCount: _obat.length,
                itemBuilder: (context, index) {
                  final obat = _obat[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading:
                          obat.image != null
                              ? Image.network(
                                obat.image!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                              : const Icon(Icons.medication_outlined, size: 40),
                      title: Text(
                        obat.nama,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        obat.harga.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              // Tunggu hasil dari halaman edit, jika true, muat ulang
                              final result = await Get.toNamed(
                                AppRoutes.obatForm,
                                arguments: obat,
                              );
                              if (result == true) {
                                _fetchobats();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmation(obat.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed(AppRoutes.obatForm);
          if (result == true) {
            _fetchobats();
          }
        },
        child: const Icon(Icons.add),
      ),
    
    );
  }
}
