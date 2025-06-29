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
  final _stokController = TextEditingController();
  final _deskripsiController = TextEditingController();

  XFile? _image;
  String? oldImageUrl;
  bool _isLoading = false;
  Obat? obat;

  @override
  void initState() {
    super.initState();
    obat = Get.arguments;
    if (obat != null) {
      _namaController.text = obat!.nama;
      _hargaController.text = obat!.harga.toString();
      _stokController.text = obat!.stok.toString();
      _deskripsiController.text = obat!.deskripsi.toString();
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

    setState(() => _isLoading = true);
    try {
      final userId = _supabaseService.currentUserId;
      String? imageUrl = oldImageUrl;

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
        'harga': int.parse(_hargaController.text),
        'stok': int.parse(_stokController.text),
        'deskripsi': _deskripsiController.text,
        'img': imageUrl,
        'user_id': userId,
      };

      if (obat != null) {
        data['id'] = obat!.id;
      }

      await _supabaseService.upsertObat(data);
      Get.back(result: true, id: 1); // ✅ id ditambahkan
      Get.snackbar(
        'Sukses',
        'Data obat berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
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
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(obat != null ? 'Edit Obat' : 'Tambah Obat')),
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
                      decoration: const InputDecoration(labelText: 'Nama Obat'),
                      validator: (value) =>
                          value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _hargaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Harga'),
                      validator: (value) =>
                          value!.isEmpty ? 'Harga tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _stokController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stok'),
                      validator: (value) =>
                          value!.isEmpty ? 'Stok tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _deskripsiController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: Text(obat != null ? 'Update' : 'Simpan'),
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
