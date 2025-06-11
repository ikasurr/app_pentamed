import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_pentamed/main.dart';
import 'page/laporan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://your-project-id.supabase.co', // Ganti dengan URL Supabase kamu
    anonKey: 'your-anon-key', // Ganti dengan anon key kamu
  );

  runApp(MyApp());
}

/// Tambahkan MyApp sebagai class global agar bisa digunakan juga di widget_test.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // tambahkan constructor const

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laporan Apotek',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: LaporanPage(),
    );
  }
}
