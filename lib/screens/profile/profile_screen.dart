import 'dart:io';
import 'package:app_pentamed/service/supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';
import '../../models/profile_model.dart';
import '../../utils/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  Profile? _profile;
  bool _isLoading = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getProfile();
      if (data != null) {
        setState(() {
          _profile = Profile.fromJson(data);
          _usernameController.text = _profile!.username;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat profil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Username tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _supabaseService.updateProfile(username: _usernameController.text);
      Get.snackbar(
        'Sukses',
        'Profil berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _loadProfile();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (imageFile == null) return;

    setState(() => _isLoading = true);

    try {
      final fileName =
          '${supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      String imageUrl;

      if (kIsWeb) {
        final imageBytes = await imageFile.readAsBytes();
        imageUrl = await _supabaseService.uploadImageBytes(
          imageBytes,
          'avatars',
          fileName,
        );
      } else {
        final file = File(imageFile.path);
        imageUrl = await _supabaseService.uploadImage(
          file,
          'avatars',
          fileName,
        );
      }

      await _supabaseService.updateProfile(
        username: _usernameController.text,
        avatarUrl: imageUrl,
      );

      _loadProfile();
      Get.snackbar(
        'Sukses',
        'Foto berhasil diubah',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black.withOpacity(0.5), // transparan
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        isDismissible: true,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengupload avatar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua kolom password wajib diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Password tidak cocok',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );
      Get.snackbar(
        'Sukses',
        'Password berhasil diubah',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black.withOpacity(0.6),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        isDismissible: true,
      );
      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah password: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFE0F7F1)),
      backgroundColor: const Color(0xFFE0F7F1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
          ? const Center(child: Text('Gagal memuat profil.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _uploadAvatar,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: (_profile?.avatarUrl != null)
                          ? NetworkImage(_profile!.avatarUrl!)
                          : null,
                      child: (_profile?.avatarUrl == null)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _uploadAvatar,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ganti Foto'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: const UnderlineInputBorder(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _updateProfile,
                    label: const Text('Simpan Profil'),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    height: 1,
                    width: 300, //
                    color: Colors.grey.shade400,
                  ),

                  const Text(
                    'Ubah Password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password Baru',
                      border: UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Password',
                      border: UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _changePassword,
                    label: const Text('Ubah Password'),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
