import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../service/supabase_service.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final SupabaseService _service = SupabaseService();
  List<dynamic> _allObat = [];
  List<dynamic> _filteredObat = [];
  List<Map<String, dynamic>> _keranjang = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _bayarController = TextEditingController();

  int total = 0;
  int kembalian = 0;
  DateTime _tanggal = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchObat();
  }

  Future<void> _fetchObat() async {
    final data = await _service.getObat();
    setState(() {
      _allObat = data;
      _filteredObat = data;
    });
  }

  void _filter(String keyword) {
    final hasil = _allObat.where((obat) {
      return obat['nama'].toString().toLowerCase().contains(
        keyword.toLowerCase(),
      );
    }).toList();

    setState(() => _filteredObat = hasil);
  }

  void _tambahKeNota(Map<String, dynamic> obat) async {
    final jumlahController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        title: const Text("Jumlah Beli"),
        content: TextField(
          controller: jumlahController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Masukkan jumlah beli"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              final jumlah = int.tryParse(jumlahController.text) ?? 0;
              final harga = int.parse(obat['harga'].toString());
              final subtotal = jumlah * harga;

              setState(() {
                _keranjang.add({
                  'obat_id': obat['id'],
                  'nama': obat['nama'],
                  'jumlah': jumlah,
                  'harga': harga,
                  'subtotal': subtotal,
                });
                _hitungTotal();
              });

              Get.back();
            },
            child: const Text("Tambah"),
          ),
        ],
      ),
    );
  }

  void _hitungTotal() {
    total = _keranjang.fold(0, (sum, item) => sum + (item['subtotal'] as int));
    final bayar = int.tryParse(_bayarController.text) ?? 0;
    kembalian = bayar - total;
    setState(() {});
  }

  String formatRupiah(int value) {
    return NumberFormat("#,##0", "id_ID").format(value);
  }

  Future<void> _simpanTransaksi() async {
    try {
      await _service.insertTransaksi(
        tanggal: _tanggal,
        total: total,
        bayar: int.tryParse(_bayarController.text) ?? 0,
        kembali: kembalian,
        keranjang: _keranjang,
      );

      Get.snackbar("Berhasil", "Transaksi berhasil disimpan");
      setState(() {
        _keranjang.clear();
        total = 0;
        kembalian = 0;
        _bayarController.clear();
      });
    } catch (e) {
      Get.snackbar("Gagal", "Gagal menyimpan transaksi: $e");
    }
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              InkWell(
                onTap: _pilihTanggal,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(_tanggal),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filter,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: 'Cari',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filteredObat.length,
                  itemBuilder: (_, i) {
                    final item = _filteredObat[i];
                    return GestureDetector(
                      onTap: () => _tambahKeNota(item),
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            item['img'] != null
                                ? Image.network(item['img'], height: 50)
                                : const Icon(Icons.medical_services),
                            const SizedBox(height: 4),
                            Text(
                              item['nama'],
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "Rp${formatRupiah(int.parse(item['harga'].toString()))}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Nota Transaksi",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          ..._keranjang.map(
                            (item) => ListTile(
                              dense: true,
                              title: Text(item['nama']),
                              subtitle: Text("Jumlah: ${item['jumlah']}"),
                              trailing: Text(
                                "Rp${formatRupiah(item['subtotal'])}",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Rp${formatRupiah(total)}"),
                        ],
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _bayarController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Pembayaran",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _hitungTotal(),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Kembalian:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Rp${formatRupiah(kembalian)}"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _keranjang.isEmpty ? null : _simpanTransaksi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Simpan",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
