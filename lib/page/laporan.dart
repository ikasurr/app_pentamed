import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanPage extends StatefulWidget {
  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  DateTimeRange? selectedDateRange;
  List<Map<String, dynamic>> laporanData = [];

  Future<void> fetchLaporanData() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('laporan')
        .select()
        .gte('tanggal', selectedDateRange?.start.toIso8601String() ?? '2000-01-01')
        .lte('tanggal', selectedDateRange?.end.toIso8601String() ?? DateTime.now().toIso8601String());

    setState(() {
      laporanData = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> cetakLaporan() async {
    final pdf = pw.Document();

    final String periode = selectedDateRange == null
        ? 'Semua Periode'
        : '${DateFormat('dd MMM yyyy').format(selectedDateRange!.start)} - '
          '${DateFormat('dd MMM yyyy').format(selectedDateRange!.end)}';

    final data = laporanData.map((laporan) {
      return [
        DateFormat('dd-MM-yyyy').format(DateTime.parse(laporan['tanggal'])),
        laporan['obat'],
        laporan['jumlah'].toString(),
        'Rp ${laporan['total']}'
      ];
    }).toList();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Transaksi Apotek', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Periode: $periode'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Tanggal', 'Obat', 'Jumlah', 'Total'],
                data: data,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    String periodeText = selectedDateRange == null
        ? 'Periode Transaksi'
        : '${DateFormat('dd MMM yyyy').format(selectedDateRange!.start)} - '
          '${DateFormat('dd MMM yyyy').format(selectedDateRange!.end)}';

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 36), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        onTap: (index) {
          // Navigasi sesuai index
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text("LAPORAN TRANSAKSI", style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(height: 20),
            InkWell(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    selectedDateRange = picked;
                  });
                  await fetchLaporanData(); // ambil data dari Supabase
                }
              },
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined),
                  SizedBox(width: 10),
                  Text(periodeText),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: laporanData.isEmpty
                  ? Center(child: Text("Belum ada data"))
                  : ListView.builder(
                      itemCount: laporanData.length,
                      itemBuilder: (context, index) {
                        final item = laporanData[index];
                        return Text('${item['tanggal']} - ${item['obat']} (${item['jumlah']})');
                      },
                    ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: laporanData.isEmpty ? null : cetakLaporan,
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                ),
                child: Text("Cetak"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
