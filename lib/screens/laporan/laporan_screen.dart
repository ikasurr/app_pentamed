import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  DateTime? tanggalMulai;
  DateTime? tanggalAkhir;
  String keyword = '';
  List<dynamic> laporanData = [];
  bool loading = false;

  final supabase = Supabase.instance.client;

  Future<void> pilihTanggalRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        tanggalMulai = picked.start;
        tanggalAkhir = picked.end;
      });
      ambilDataLaporan();
    }
  }

  Future<void> ambilDataLaporan() async {
    if (tanggalMulai == null || tanggalAkhir == null) return;

    setState(() => loading = true);

    final res = await supabase
        .from('laporan')
        .select()
        .gte('tanggal', DateFormat('yyyy-MM-dd').format(tanggalMulai!))
        .lte('tanggal', DateFormat('yyyy-MM-dd').format(tanggalAkhir!))
        .ilike('keterangan', '%$keyword%')
        .order('tanggal');

    setState(() {
      laporanData = res;
      loading = false;
    });
  }

  int _totalTransaksi() {
    return laporanData.fold<int>(0, (total, item) {
      return total + (item['jumlah'] as int);
    });
  }

  Future<void> cetakPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'LAPORAN TRANSAKSI',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Periode: ${DateFormat('dd MMM yyyy').format(tanggalMulai!)} - ${DateFormat('dd MMM yyyy').format(tanggalAkhir!)}',
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['No', 'Tanggal', 'Keterangan', 'Jumlah'],
              data: [
                for (int i = 0; i < laporanData.length; i++)
                  [
                    '${i + 1}',
                    laporanData[i]['tanggal'],
                    laporanData[i]['keterangan'],
                    'Rp ${laporanData[i]['jumlah']}',
                  ],
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Total: Rp ${_totalTransaksi()}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodeText = (tanggalMulai == null || tanggalAkhir == null)
        ? 'Pilih Rentang Tanggal'
        : '${DateFormat('dd MMM yyyy').format(tanggalMulai!)} - ${DateFormat('dd MMM yyyy').format(tanggalAkhir!)}';

    return Scaffold(
      backgroundColor: const Color(0xFFE9E6E6),
      appBar: AppBar(
        title: const Text('Laporan Transaksi'),
        backgroundColor: const Color(0xFFE9E6E6),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: pilihTanggalRange,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      periodeText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari keterangan atau nama...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  keyword = value;
                  ambilDataLaporan();
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 8),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : laporanData.isEmpty
                      ? const Center(child: Text('Tidak ada data.'))
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: laporanData.length,
                                itemBuilder: (context, index) {
                                  final item = laporanData[index];
                                  return ListTile(
                                    title: Text(item['keterangan']),
                                    subtitle: Text(
                                      'Tanggal: ${item['tanggal']} | Jumlah: Rp ${item['jumlah']}',
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Divider(thickness: 1),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Total: Rp ${_totalTransaksi()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: laporanData.isEmpty ? null : cetakPDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Colors.black38,
                ),
                child: const Text(
                  'Cetak PDF',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
