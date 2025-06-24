class Obat {
  int id;
  String nama;
  int harga;
  int stok;
  String? image;
  String deskripsi;

  Obat({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    this.image,
    required this.deskripsi,
  });

  factory Obat.fromJson(Map<String, dynamic> json) {
    return Obat(
      id: json['id'],
      nama: json['nama'],
      harga: json['harga'],
      stok: json['stok'],
      image: json['image'],
      deskripsi: json['deskripsi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'image': image,
      'deskripsi': deskripsi,
    };
  }
}
