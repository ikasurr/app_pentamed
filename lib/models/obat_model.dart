// lib/models/Obat_model.dart

class Obat {
  final int id;
  final String userId;
  final String nama;
  final int harga;
  final String? img;
  final int? stok;
  final DateTime createdAt;

  Obat({
    required this.id,
    required this.userId,
    required this.nama,
    required this.harga,
    this.img,
    this.stok,
    required this.createdAt,
  });

  factory Obat.fromJson(Map<String, dynamic> json) {
    return Obat(
      id: json['id'],
      userId: json['user_id'],
      nama: json['nama'],
      harga: json['harga'],
      img: json['img'],
      stok: json['stok'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'harga': harga,
      'image_url': img,
      'stok': stok,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
