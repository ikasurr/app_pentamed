import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../halaman_awal.dart';

class SupabaseService {
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
    // Mendapatkan URL publik dari gambar yang diupload
    final String publicUrl = supabase.storage
        .from(bucketName)
        .getPublicUrl(fileName);
    return publicUrl;
  }

  Future<List<Map<String, dynamic>>> getObat() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('obat')
        .select()
        .eq('user_id', userId)
    return data;
  }

  Future<void> addObat({
    required String nama,
    required int harga,
    required int stok,
    String? image,
    required String deskripsi,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('obat').insert({
      'user_id': userId,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'image_url': image,
      'deskripsi': deskripsi,
    });
  }

  Future<void> updateObat({
    required int id,
    required String nama,
    required int harga,
    required int stok,
    String? image,
    required String deskripsi,
  }) async {
    final updates = {'nama': nama, 'harga': harga, 'stok':stok,'image_url': image, 'deskripsi': deskripsi};
    await supabase.from('obat').update(updates).eq('id', id);
  }

  Future<void> deleteNote(int id) async {
    await supabase.from('obat').delete().eq('id', id);
  }
}
