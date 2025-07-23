class Obat {
  final String id;
  final String userId;
  final String nama;
  final int harga;
  final String? img;
  final DateTime createdAt;

  Obat({
    required this.id,
    required this.userId,
    required this.nama,
    required this.harga,
    this.img,
    required this.createdAt,
  });

  factory Obat.fromJson(Map<String, dynamic> json) {
    return Obat(
      id: json['id'].toString(),
      userId: json['user_id'] ?? '',
      nama: json['nama'] ?? '',
      harga: json['harga'] is int
          ? json['harga']
          : int.tryParse(json['harga'].toString()) ?? 0,
      img: json['img'],
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama': nama,
      'harga': harga,
      'img': img,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
