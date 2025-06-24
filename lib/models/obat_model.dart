// lib/models/Obat_model.dart

class Obat {
  final int id;
  final String userId;
  final String nama;
  final int stok;
  final int harga;
  final String? img;
  final String deskripsi;
  final DateTime createdAt;

  Obat({
    required this.id,
    required this.userId,
    required this.nama,
    required this.stok,
    required this.harga,
    this.img,
    required this.deskripsi,
    required this.createdAt,
  });

  factory Obat.fromJson(Map<String, dynamic> json) {
    return Obat(
      id: json['id'],
      userId: json['user_id'],
      nama: json['nama'],
      stok: json['stok'],
      harga: json['harga'],
      img: json['img'],
      deskripsi: json['deskripsi'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'stok': stok,
      'harga': harga,
      'image_url': img,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
