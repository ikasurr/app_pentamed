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

    try {
      final userId = supabase.auth.currentUser!.id;

      final res = await supabase
          .from('transaksi')
          .select(
            'id, tanggal, total, transaksi_detail(obat_id, jumlah_beli, obat(nama))',
          )
          .eq('user_id', userId)
          .gte('tanggal', tanggalMulai!.toIso8601String())
          .lte('tanggal', tanggalAkhir!.toIso8601String())
          .order('tanggal');

      setState(() {
        laporanData = res;
      });
    } catch (e) {
      print("Gagal ambil laporan detail: $e");
      laporanData = [];
    }

    setState(() => loading = false);
  }

  int _totalTransaksi() {
    return laporanData.fold<int>(0, (total, item) {
      return total + (item['total'] as int);
    });
  }

  Future<void> cetakPDF() async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
          pageFormat: PdfPageFormat.a4,
          buildBackground: (context) => pw.Container(color: PdfColors.white),
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'LAPORAN TRANSAKSI',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Periode: ${DateFormat('dd MMM yyyy').format(tanggalMulai!)} - ${DateFormat('dd MMM yyyy').format(tanggalAkhir!)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),

              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.5,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(5),
                  2: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Tanggal',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Obat yang Dibeli',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...laporanData.map((item) {
                    final tanggal = DateFormat(
                      'dd-MM-yyyy',
                    ).format(DateTime.parse(item['tanggal']));
                    final total = item['total'];

                    final obatList = (item['transaksi_detail'] as List)
                        .map(
                          (d) => '- ${d['obat']['nama']} (${d['jumlah_beli']})',
                        )
                        .join('\n');

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(tanggal),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(obatList),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Rp $total'),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total Pendapatan: Rp ${_totalTransaksi()}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    await Printing.sharePdf(bytes: pdfBytes, filename: 'laporan_transaksi.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final periodeText = (tanggalMulai == null || tanggalAkhir == null)
        ? 'Pilih Rentang Tanggal'
        : '${DateFormat('dd MMM yyyy').format(tanggalMulai!)} - ${DateFormat('dd MMM yyyy').format(tanggalAkhir!)}';

    return Scaffold(
      backgroundColor: const Color(0xFFE0F7F1),
      appBar: AppBar(
        title: const Text('Laporan Transaksi'),
        backgroundColor: const Color(0xFFE0F7F1),
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
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Tanggal')),
                                    DataColumn(label: Text('Obat yang Dibeli')),
                                    DataColumn(label: Text('Total Belanja')),
                                  ],
                                  rows: laporanData.map((item) {
                                    final tanggal = DateFormat(
                                      'dd-MM-yyyy',
                                    ).format(DateTime.parse(item['tanggal']));
                                    final obatList =
                                        (item['transaksi_detail'] as List)
                                            .map(
                                              (d) =>
                                                  '- ${d['obat']['nama']} (${d['jumlah_beli']})',
                                            )
                                            .join('\n');

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(tanggal)),
                                        DataCell(
                                          Text(obatList, softWrap: true),
                                        ),
                                        DataCell(Text('Rp ${item['total']}')),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const Divider(thickness: 1),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Total Pendapatan: Rp ${_totalTransaksi()}',
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
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
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
                    'Cetak',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
