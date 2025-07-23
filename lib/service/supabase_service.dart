import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart'; // Untuk akses supabase client jika diperlukan

class SupabaseService {
  final _client = Supabase.instance.client;

  // Getter user ID
  String get currentUserId {
    final user = _client.auth.currentUser?.id ?? '';
    if (user.isEmpty) {
      throw Exception('User belum login');
    }
    return user;
  }

  // Upload Gambar (Mobile)
  Future<String> uploadImage(
    File file,
    String bucketName,
    String fileName,
  ) async {
    final bytes = await file.readAsBytes();
    await _client.storage
        .from(bucketName)
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    return _client.storage.from(bucketName).getPublicUrl(fileName);
  }

  // Upload Gambar (Web)
  Future<String> uploadImageBytes(
    Uint8List bytes,
    String bucketName,
    String fileName,
  ) async {
    await _client.storage
        .from(bucketName)
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    return _client.storage.from(bucketName).getPublicUrl(fileName);
  }

  // Ambil semua obat milik user
  Future<List<Map<String, dynamic>>> getObat() async {
    final userId = currentUserId;
    final data = await _client
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
    await _client.from('obat').insert({
      'user_id': userId,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'img': img,
      'deskripsi': deskripsi,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Update obat
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
    await _client.from('obat').upsert(updates);
  }

  // Hapus obat
  Future<void> deleteObat(String id) async {
    final userId = currentUserId;
    await _client.from('obat').delete().eq('id', id).eq('user_id', userId);
  }

  // Profil pengguna
  Future<Map<String, dynamic>?> getProfile() async {
    final userId = currentUserId;
    return await _client.from('user').select().eq('id', userId).single();
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
    await _client.from('user').upsert(updates);
  }

  Future<String> uploadAvatar(File file, String bucket, String filename) async {
    final bytes = await file.readAsBytes();
    try {
      await _client.storage
          .from(bucket)
          .uploadBinary(
            filename,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      return _client.storage.from(bucket).getPublicUrl(filename);
    } catch (e) {
      throw 'Gagal mengunggah avatar: $e';
    }
  }

  // Upsert umum
  Future<void> upsertObat(Map<String, dynamic> data) async {
    await _client.from('obat').upsert(data);
  }

  Future<void> insertTransaksi({
    required DateTime tanggal,
    required int total,
    required int bayar,
    required int kembali,
    required List<Map<String, dynamic>> keranjang,
  }) async {
    final userId = currentUserId;

    try {
      // 1. Insert ke tabel transaksi
      final transaksi = await _client
          .from('transaksi')
          .insert({
            'user_id': userId,
            'tanggal': tanggal.toIso8601String(),
            'total': total,
            'pembayaran': bayar,
            'kembalian': kembali,
          })
          .select()
          .single();

      final transaksiId = transaksi['id'];

      // 2. Insert ke transaksi_detail
      for (var item in keranjang) {
        await _client.from('transaksi_detail').insert({
          'transaksi_id': transaksiId,
          'obat_id': item['obat_id'],
          'jumlah_beli': item['jumlah'],
          'harga_satuan': item['harga'],
          'subtotal': item['subtotal'],
        });
      }
    } catch (e) {
      print("Gagal menyimpan transaksi: $e");
      rethrow; // Biar error tetap dilempar ke atas untuk ditangani di UI
    }
  }

  // Ambil semua transaksi user
  Future<List<Map<String, dynamic>>> getAllTransaksi() async {
    final userId = currentUserId;
    final data = await _client
        .from('transaksi')
        .select()
        .eq('user_id', userId)
        .order('tanggal', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  // Ambil transaksi berdasarkan range tanggal
  Future<List<Map<String, dynamic>>> getTransaksiBetween(
    DateTime start,
    DateTime end,
  ) async {
    final userId = currentUserId;
    final data = await _client
        .from('transaksi')
        .select()
        .gte('tanggal', start.toIso8601String())
        .lt('tanggal', end.toIso8601String())
        .eq('user_id', userId)
        .order('tanggal');
    return List<Map<String, dynamic>>.from(data);
  }

  // Ambil detail transaksi
  Future<List<Map<String, dynamic>>> getDetailTransaksi(
    String transaksiId,
  ) async {
    final data = await _client
        .from('transaksi_detail')
        .select()
        .eq('transaksi_id', transaksiId);
    return List<Map<String, dynamic>>.from(data);
  }
}
