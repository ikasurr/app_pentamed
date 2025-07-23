import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/obat_model.dart';
import '../../service/supabase_service.dart';

class FormObatScreen extends StatefulWidget {
  const FormObatScreen({super.key});

  @override
  State<FormObatScreen> createState() => _FormObatScreenState();
}

class _FormObatScreenState extends State<FormObatScreen> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseService _supabaseService = SupabaseService();

  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();

  XFile? _image;
  String? oldImageUrl;
  bool _isLoading = false;
  Obat? obat;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      obat = Obat.fromJson(args);
      _namaController.text = obat!.nama;
      _hargaController.text = obat!.harga.toString();
      oldImageUrl = obat!.img;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final harga = int.tryParse(_hargaController.text);
    if (harga == null || harga <= 0) {
      Get.snackbar(
        'Invalid',
        'Harga harus lebih dari 0',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = _supabaseService.currentUserId;
      String? imageUrl = oldImageUrl;

      // Upload image jika ada gambar baru dipilih
      if (_image != null) {
        final fileName = 'obat_${DateTime.now().millisecondsSinceEpoch}.png';
        final bytes = await _image!.readAsBytes();
        imageUrl = await _supabaseService.uploadImageBytes(
          bytes,
          'image',
          fileName,
        );
      }

      final data = {
        'nama': _namaController.text,
        'harga': harga,
        'img': imageUrl,
        'user_id': userId,
      };

      // Tambahkan ID jika edit
      if (obat != null) {
        data['id'] = obat!.id;
      }

      // Insert / update
      await _supabaseService.upsertObat(data);
      Get.back(result: true);
      Get.snackbar(
        'Sukses',
        'Data obat berhasil disimpan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black.withOpacity(0.6),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        isDismissible: true,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan obat: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7F1),
      appBar: AppBar(
        title: Text(obat != null ? 'Edit Obat' : 'Tambah Obat'),
        backgroundColor: const Color(0xFFE0F7F1),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(File(_image!.path))
                            : (oldImageUrl != null
                                      ? NetworkImage(oldImageUrl!)
                                      : null)
                                  as ImageProvider<Object>?,
                        child: (_image == null && oldImageUrl == null)
                            ? const Icon(Icons.camera_alt, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Obat',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hargaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Harga tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: Text(obat != null ? 'Update' : 'Simpan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
