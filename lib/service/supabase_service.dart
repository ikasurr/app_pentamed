import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart'; // Untuk akses supabase client jika diperlukan

// ... import tetap sama

class SupabaseService {
  final _client = Supabase.instance.client;

  String get currentUserId {
    final user = _client.auth.currentUser?.id ?? '';
    if (user.isEmpty) {
      throw Exception('User belum login');
    }
    return user;
  }

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

  Future<List<Map<String, dynamic>>> getObat() async {
    final userId = currentUserId;
    final data = await _client
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

  Future<void> deleteObat(String id) async {
    final userId = currentUserId;
    await _client.from('obat').delete().eq('id', id).eq('user_id', userId);
  }

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
    final response = await _client
        .from('transaksi')
        .insert({
          'user_id': currentUserId,
          'tanggal': tanggal.toIso8601String(),
          'total': total,
          'bayar': bayar,
          'kembali': kembali,
        })
        .select('id')
        .single();

    final transaksiId = response['id'];

    for (var item in keranjang) {
      await _client.from('transaksi_detail').insert({
        'transaksi_id': transaksiId,
        'obat_id': item['obat_id'],
        'jumlah_beli': item['jumlah'],
        'harga_satuan': item['harga'],
        'subtotal': item['subtotal'],
      });

      await kurangiStokObat(item['obat_id'], item['jumlah']);
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransaksi() async {
    final userId = currentUserId;
    final data = await _client
        .from('transaksi')
        .select()
        .eq('user_id', userId)
        .order('tanggal', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

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

  Future<List<Map<String, dynamic>>> getDetailTransaksi(
    String transaksiId,
  ) async {
    final data = await _client
        .from('transaksi_detail')
        .select()
        .eq('transaksi_id', transaksiId);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> kurangiStokObat(int obatId, int jumlahBeli) async {
    final response = await _client
        .from('obat')
        .select('stok')
        .eq('id', obatId)
        .single();

    final stokSekarang = response['stok'] ?? 0;
    final stokBaru = stokSekarang - jumlahBeli;

    if (stokBaru < 0) {
      throw Exception("Stok tidak mencukupi");
    }

    await _client.from('obat').update({'stok': stokBaru}).eq('id', obatId);
  }
}
