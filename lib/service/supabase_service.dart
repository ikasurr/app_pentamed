import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart'; // Untuk akses `supabase` client

class SupabaseService {
  final _client = Supabase.instance.client;

  // Getter user ID
  String get currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }
    return user.id;
  }

  // Upload Gambar (Mobile)
  Future<String> uploadImage(
    File file,
    String bucketName,
    String fileName,
  ) async {
    final bytes = await file.readAsBytes();
    await supabase.storage
        .from(bucketName)
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  // Upload Gambar (Web)
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

    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  // Ambil semua obat milik user
  Future<List<Map<String, dynamic>>> getObat() async {
    final userId = currentUserId;
    final data = await supabase
        .from('obat')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return data;
  }

  // Tambah obat baru
  Future<void> addObat({
    required String nama,
    required String harga,
    required int stok,
    String? img,
    required String deskripsi,
  }) async {
    final userId = currentUserId;
    await supabase.from('obat').insert({
      'user_id': userId,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'img': img,
      'deskripsi': deskripsi,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Update obat (dengan ID String UUID)
  Future<void> updateObat({
    required String id,
    required String nama,
    required String harga,
    required int stok,
    String? img,
    required String deskripsi,
  }) async {
    final userId = currentUserId;
    final updates = {
      'id': id,
      'user_id': userId,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'img': img,
      'deskripsi': deskripsi,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await supabase.from('obat').upsert(updates);
  }

  // Hapus obat (ID UUID bertipe String)
  Future<void> deleteObat(String id) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception("User belum login");

    final response = await Supabase.instance.client
        .from('obat')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);

    print('Response delete: $response');
  }

  // Profil pengguna
  Future<Map<String, dynamic>?> getProfile() async {
    final userId = currentUserId;
    return await supabase.from('user').select().eq('id', userId).single();
  }

  Future<void> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    final userId = currentUserId;
    final updates = {
      'id': userId,
      'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await supabase.from('user').upsert(updates);
  }

  Future<String> uploadAvatar(File file, String bucket, String filename) async {
    final bytes = await file.readAsBytes();
    try {
      await supabase.storage
          .from(bucket)
          .uploadBinary(
            filename,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      return supabase.storage.from(bucket).getPublicUrl(filename);
    } catch (e) {
      throw 'Gagal mengunggah avatar: $e';
    }
  }

  // Upsert umum
  Future<void> upsertObat(Map<String, dynamic> data) async {
    await Supabase.instance.client.from('obat').upsert(data);
  }
}
