import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const Laporan());
}

class Laporan extends StatelessWidget {
  const Laporan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laporan Transaksi',
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const LaporanTransaksiPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LaporanTransaksiPage extends StatefulWidget {
  const LaporanTransaksiPage({super.key});

  @override
  State<LaporanTransaksiPage> createState() => _LaporanTransaksiPageState();
}

class _LaporanTransaksiPageState extends State<LaporanTransaksiPage> {
  DateTime? selectedDate;
  List<dynamic> laporanData = [];
  bool loading = false;

  final supabase = Supabase.instance.client;

  Future<void> pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      ambilDataLaporan();
    }
  }

  Future<void> ambilDataLaporan() async {
    setState(() => loading = true);
    final tanggalFormatted = DateFormat('yyyy-MM-dd').format(selectedDate!);
    final res = await supabase
        .from('laporan')
        .select()
        .eq('tanggal', tanggalFormatted)
        .order('id');

    setState(() {
      laporanData = res;
      loading = false;
    });
  }

  Future<void> cetakPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('LAPORAN TRANSAKSI',
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Periode: ${DateFormat('dd MMMM yyyy').format(selectedDate!)}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['No', 'Keterangan', 'Jumlah'],
              data: [
                for (int i = 0; i < laporanData.length; i++)
                  [
                    '${i + 1}',
                    laporanData[i]['keterangan'],
                    'Rp ${laporanData[i]['jumlah']}'
                  ]
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final tanggalText = selectedDate == null
        ? 'Pilih Tanggal'
        : DateFormat('dd MMMM yyyy').format(selectedDate!);

    return Scaffold(
      backgroundColor: const Color(0xFFE9E6E6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'LAPORAN TRANSAKSI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: pilihTanggal,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Periode: $tanggalText',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
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
                          : ListView.builder(
                              itemCount: laporanData.length,
                              itemBuilder: (context, index) {
                                final item = laporanData[index];
                                return ListTile(
                                  title: Text(item['keterangan']),
                                  subtitle: Text('Jumlah: Rp ${item['jumlah']}'),
                                );
                              },
                            ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: laporanData.isEmpty ? null : cetakPDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 6,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
            ],
          ),
        ),
      ),
    );
  }
}
