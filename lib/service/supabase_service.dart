// lib/services/supabase_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart'; // Untuk akses `supabase` client

class SupabaseService {
  Future<void> upsertObat(Map<String, dynamic> data) async {
    await Supabase.instance.client.from('obat').upsert(data);
  }

  final _client = Supabase.instance.client;

  // Getter user ID
  String get currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }
    return user.id;
  }

  // Upload Gambar (Bekerja untuk Web dan Mobile)
  Future<String> uploadImage(
    File file,
    String bucketName,
    String fileName,
  ) async {
    final bytes = await file.readAsBytes();
    await supaba.storage
        .from(bucketName)
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    // Mendapatkan URL publik dari gambar yang diupload
    final String publicUrl = supabase.storage
        .from(bucketName)
        .getPublicUrl(fileName);
    return publicUrl;
  }

  // Versi lain untuk web menggunakan XFile
  Future<String> uploadImageBytes(
    Uint8List bytes,
    String bucketName,
    String fileName,
  ) async {
    await supabase.storage
        .from(bucketName)
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    final String publicUrl = supabase.storage
        .from(bucketName)
        .getPublicUrl(fileName);
    return publicUrl;
  }

  // --- CRUD Catatan ---
  Future<List<Map<String, dynamic>>> getObat() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('obat')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return data;
  }

  Future<void> addObat({
    required String nama,
    required String harga,
    required int stok,
    String? img,
    required String deskripsi,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('notes').insert({
      'user_id': userId,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'img': img,
      'deskripsi': deskripsi,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateObat({
    required int id,
    required String nama,
    required String harga,
    required int stok,
    String? img,
    required String deskripsi,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final updates = {
      'id': id,
      'user_id': userId,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'img': img,
      'deskripsi': deskripsi,
      'created_at': DateTime.now().toIso8601String(),
    };
    await supabase.from('notes').upsert(updates);
  }

  Future<void> deleteObat(int id) async {
    await supabase.from('obat').delete().eq('id', id);
  }
  // --- Profil Pengguna ---

  Future<Map<String, dynamic>?> getProfile() async {
    final userId = supabase.auth.currentUser!.id;
    return await supabase.from('user').select().eq('id', userId).single();
  }

  Future<void> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final updates = {
      'id': userId,
      'username': username,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
      if (avatarUrl != null)
        'avatar_url': avatarUrl, // <-- hanya kirim jika tidak null
    };

    await supabase.from('user').upsert(updates);
  }

  Future<String> uploadAvatar(File file, String bucket, String filename) async {
    final bytes = await file.readAsBytes();
    final path = filename;

    try {
      await supabase.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Jika berhasil, kembalikan URL publik
      return supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      throw 'Gagal mengunggah avatar: $e';
    }
  }
}
